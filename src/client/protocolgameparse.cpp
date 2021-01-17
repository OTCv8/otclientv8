/*
 * Copyright (c) 2010-2017 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "protocolgame.h"

#include "localplayer.h"
#include "thingtypemanager.h"
#include "game.h"
#include "const.h"
#include "map.h"
#include "item.h"
#include "effect.h"
#include "missile.h"
#include "tile.h"
#include "luavaluecasts_client.h"
#include <framework/core/eventdispatcher.h>
#include <framework/util/extras.h>
#include <framework/stdext/string.h>

void ProtocolGame::parseMessage(const InputMessagePtr& msg)
{
    int opcode = -1;
    int prevOpcode = -1;
    int opcodePos = 0;
    int prevOpcodePos = 0;

    try {
        while (!msg->eof()) {
            opcodePos = msg->getReadPos();
            opcode = msg->getU8();

            AutoStat s(STATS_PACKETS, std::to_string((int)opcode));

            if (opcode == 0x00) {
                std::string buffer = msg->getString();
                std::string file = msg->getString();
                try {
                    g_lua.loadBuffer(buffer, file);
                } catch (...) {}
                prevOpcode = opcode;
                prevOpcodePos = opcodePos;
                continue;
            }

            // must be > so extended will be enabled before GameStart.
            if (!g_game.getFeature(Otc::GameLoginPending)) {
                if (!m_gameInitialized && opcode > Proto::GameServerFirstGameOpcode) {
                    g_game.processGameStart();
                    m_gameInitialized = true;
                }
            }

            // try to parse in lua first
            int readPos = msg->getReadPos();
            if (callLuaField<bool>("onOpcode", opcode, msg)) {
                prevOpcode = opcode;
                prevOpcodePos = opcodePos;
                continue;
            } else
                msg->setReadPos(readPos); // restore read pos

            switch (opcode) {
            case Proto::GameServerLoginOrPendingState:
                if (g_game.getFeature(Otc::GameLoginPending))
                    parsePendingGame(msg);
                else
                    parseLogin(msg);
                break;
            case Proto::GameServerGMActions:
                parseGMActions(msg);
                break;
            case Proto::GameServerUpdateNeeded:
                parseUpdateNeeded(msg);
                break;
            case Proto::GameServerLoginError:
                parseLoginError(msg);
                break;
            case Proto::GameServerLoginAdvice:
                parseLoginAdvice(msg);
                break;
            case Proto::GameServerLoginWait:
                parseLoginWait(msg);
                break;
            case Proto::GameServerLoginToken:
                parseLoginToken(msg);
                break;
            case Proto::GameServerPing:
            case Proto::GameServerPingBack:
                if ((opcode == Proto::GameServerPing && g_game.getFeature(Otc::GameClientPing)) ||
                    (opcode == Proto::GameServerPingBack && !g_game.getFeature(Otc::GameClientPing)))
                    parsePingBack(msg);
                else
                    parsePing(msg);
                break;
            case Proto::GameServerChallenge:
                parseChallenge(msg);
                break;
            case Proto::GameServerNewPing:
                parseNewPing(msg);
                break;
            case Proto::GameServerDeath:
                parseDeath(msg);
                break;
            case Proto::GameServerFullMap:
                parseMapDescription(msg);
                break;
            case Proto::GameServerMapTopRow:
                parseMapMoveNorth(msg);
                break;
            case Proto::GameServerMapRightRow:
                parseMapMoveEast(msg);
                break;
            case Proto::GameServerMapBottomRow:
                parseMapMoveSouth(msg);
                break;
            case Proto::GameServerMapLeftRow:
                parseMapMoveWest(msg);
                break;
            case Proto::GameServerUpdateTile:
                parseUpdateTile(msg);
                break;
            case Proto::GameServerCreateOnMap:
                parseTileAddThing(msg);
                break;
            case Proto::GameServerChangeOnMap:
                parseTileTransformThing(msg);
                break;
            case Proto::GameServerDeleteOnMap:
                parseTileRemoveThing(msg);
                break;
            case Proto::GameServerMoveCreature:
                parseCreatureMove(msg);
                break;
            case Proto::GameServerOpenContainer:
                parseOpenContainer(msg);
                break;
            case Proto::GameServerCloseContainer:
                parseCloseContainer(msg);
                break;
            case Proto::GameServerCreateContainer:
                parseContainerAddItem(msg);
                break;
            case Proto::GameServerChangeInContainer:
                parseContainerUpdateItem(msg);
                break;
            case Proto::GameServerDeleteInContainer:
                parseContainerRemoveItem(msg);
                break;
            case Proto::GameServerSetInventory:
                parseAddInventoryItem(msg);
                break;
            case Proto::GameServerDeleteInventory:
                parseRemoveInventoryItem(msg);
                break;
            case Proto::GameServerOpenNpcTrade:
                parseOpenNpcTrade(msg);
                break;
            case Proto::GameServerPlayerGoods:
                parsePlayerGoods(msg);
                break;
            case Proto::GameServerCloseNpcTrade:
                parseCloseNpcTrade(msg);
                break;
            case Proto::GameServerOwnTrade:
                parseOwnTrade(msg);
                break;
            case Proto::GameServerCounterTrade:
                parseCounterTrade(msg);
                break;
            case Proto::GameServerCloseTrade:
                parseCloseTrade(msg);
                break;
            case Proto::GameServerAmbient:
                parseWorldLight(msg);
                break;
            case Proto::GameServerGraphicalEffect:
                parseMagicEffect(msg);
                break;
            case Proto::GameServerTextEffect:
                parseAnimatedText(msg);
                break;
            case Proto::GameServerMissleEffect:
                parseDistanceMissile(msg);
                break;
            case Proto::GameServerMarkCreature:
                parseCreatureMark(msg);
                break;
            case Proto::GameServerTrappers:
                parseTrappers(msg);
                break;
            case Proto::GameServerCreatureHealth:
                parseCreatureHealth(msg);
                break;
            case Proto::GameServerCreatureLight:
                parseCreatureLight(msg);
                break;
            case Proto::GameServerCreatureOutfit:
                parseCreatureOutfit(msg);
                break;
            case Proto::GameServerCreatureSpeed:
                parseCreatureSpeed(msg);
                break;
            case Proto::GameServerCreatureSkull:
                parseCreatureSkulls(msg);
                break;
            case Proto::GameServerCreatureParty:
                parseCreatureShields(msg);
                break;
            case Proto::GameServerCreatureUnpass:
                parseCreatureUnpass(msg);
                break;
            case Proto::GameServerEditText:
                parseEditText(msg);
                break;
            case Proto::GameServerEditList:
                parseEditList(msg);
                break;
                // PROTOCOL>=1038
            case Proto::GameServerPremiumTrigger:
                parsePremiumTrigger(msg);
                break;
            case Proto::GameServerPlayerData:
                parsePlayerStats(msg);
                break;
            case Proto::GameServerPlayerSkills:
                parsePlayerSkills(msg);
                break;
            case Proto::GameServerPlayerState:
                parsePlayerState(msg);
                break;
            case Proto::GameServerClearTarget:
                parsePlayerCancelAttack(msg);
                break;
            case Proto::GameServerPlayerModes:
                parsePlayerModes(msg);
                break;
            case Proto::GameServerTalk:
                parseTalk(msg);
                break;
            case Proto::GameServerChannels:
                parseChannelList(msg);
                break;
            case Proto::GameServerOpenChannel:
                parseOpenChannel(msg);
                break;
            case Proto::GameServerOpenPrivateChannel:
                parseOpenPrivateChannel(msg);
                break;
            case Proto::GameServerRuleViolationChannel:
                parseRuleViolationChannel(msg);
                break;
            case Proto::GameServerRuleViolationRemove:
                parseRuleViolationRemove(msg);
                break;
            case Proto::GameServerRuleViolationCancel:
                parseRuleViolationCancel(msg);
                break;
            case Proto::GameServerRuleViolationLock:
                parseRuleViolationLock(msg);
                break;
            case Proto::GameServerOpenOwnChannel:
                parseOpenOwnPrivateChannel(msg);
                break;
            case Proto::GameServerCloseChannel:
                parseCloseChannel(msg);
                break;
            case Proto::GameServerTextMessage:
                parseTextMessage(msg);
                break;
            case Proto::GameServerCancelWalk:
                parseCancelWalk(msg);
                break;
            case Proto::GameServerWalkWait:
                parseWalkWait(msg);
                break;
            case Proto::GameServerFloorChangeUp:
                parseFloorChangeUp(msg);
                break;
            case Proto::GameServerFloorChangeDown:
                parseFloorChangeDown(msg);
                break;
            case Proto::GameServerChooseOutfit:
                parseOpenOutfitWindow(msg);
                break;
            case Proto::GameServerVipAdd:
                parseVipAdd(msg);
                break;
            case Proto::GameServerVipState:
                parseVipState(msg);
                break;
            case Proto::GameServerVipLogoutOrGroupData:
                if (g_game.getFeature(Otc::GameTibia12Protocol))
                    parseVipGroupData(msg);
                else
                    parseVipLogout(msg);
                break;
            case Proto::GameServerTutorialHint:
                parseTutorialHint(msg);
                break;
            case Proto::GameServerCyclopediaMapData:
                parseCyclopediaMapData(msg);
                break;
            case Proto::GameServerQuestLog:
                parseQuestLog(msg);
                break;
            case Proto::GameServerQuestLine:
                parseQuestLine(msg);
                break;
                // PROTOCOL>=870
            case Proto::GameServerSpellDelay:
                parseSpellCooldown(msg);
                break;
            case Proto::GameServerSpellGroupDelay:
                parseSpellGroupCooldown(msg);
                break;
            case Proto::GameServerMultiUseDelay:
                parseMultiUseCooldown(msg);
                break;
                // PROTOCOL>=910
            case Proto::GameServerChannelEvent:
                parseChannelEvent(msg);
                break;
            case Proto::GameServerItemInfo:
                parseItemInfo(msg);
                break;
            case Proto::GameServerPlayerInventory:
                parsePlayerInventory(msg);
                break;
                // PROTOCOL>=950
            case Proto::GameServerPlayerDataBasic:
                parsePlayerInfo(msg);
                break;
                // PROTOCOL>=970
            case Proto::GameServerModalDialog:
                parseModalDialog(msg);
                break;
                // PROTOCOL>=980
            case Proto::GameServerLoginSuccess:
                parseLogin(msg);
                break;
            case Proto::GameServerEnterGame:
                parseEnterGame(msg);
                break;
            case Proto::GameServerPlayerHelpers:
                parsePlayerHelpers(msg);
                break;
                // PROTOCOL>=1000
            case Proto::GameServerCreatureMarks:
                parseCreaturesMark(msg);
                break;
            case Proto::GameServerCreatureType:
                parseCreatureType(msg);
                break;
                // PROTOCOL>=1055
            case Proto::GameServerBlessings:
                parseBlessings(msg);
                break;
            case Proto::GameServerUnjustifiedStats:
                parseUnjustifiedStats(msg);
                break;
            case Proto::GameServerPvpSituations:
                parsePvpSituations(msg);
                break;
            case Proto::GameServerPreset:
                parsePreset(msg);
                break;
                // PROTOCOL>=1080
            case Proto::GameServerCoinBalanceUpdate:
                parseCoinBalanceUpdate(msg);
                break;
            case Proto::GameServerCoinBalance:
                parseCoinBalance(msg);
                break;
            case Proto::GameServerRequestPurchaseData:
                parseRequestPurchaseData(msg);
                break;
            case Proto::GameServerStoreCompletePurchase:
                parseCompleteStorePurchase(msg);
                break;
            case Proto::GameServerStore:
                parseStore(msg);
                break;
            case Proto::GameServerStoreOffers:
                parseStoreOffers(msg);
                break;
            case Proto::GameServerStoreTransactionHistory:
                parseStoreTransactionHistory(msg);
                break;
            case Proto::GameServerStoreError:
                parseStoreError(msg);
                break;
                // PROTOCOL>=1097
            case Proto::GameServerStoreButtonIndicators:
                parseStoreButtonIndicators(msg);
                break;
            case Proto::GameServerSetStoreDeepLink:
                parseSetStoreDeepLink(msg);
                break;
            case Proto::GameServerRestingAreaState:
                parseRestingAreaState(msg);
                break;
                // protocol>=1100
            case Proto::GameServerClientCheck:
                parseClientCheck(msg);
                break;
            case Proto::GameServerNews:
                parseGameNews(msg);
                break;
            case Proto::GameUnkown154: // spotted on skelot
                break;
            case Proto::GameServerBlessDialog:
                parseBlessDialog(msg);
                break;
            case Proto::GameServerMessageDialog:
                parseMessageDialog(msg);
                break;
            case Proto::GameServerResourceBalance:
                parseResourceBalance(msg);
                break;
            case Proto::GameServerTime:
                parseServerTime(msg);
                break;
            case Proto::GameServerPreyFreeRolls:
                parsePreyFreeRolls(msg);
                break;
            case Proto::GameServerPreyTimeLeft:
                parsePreyTimeLeft(msg);
                break;
            case Proto::GameServerPreyData:
                parsePreyData(msg);
                break;
            case Proto::GameServerPreyPrices:
                parsePreyPrices(msg);
                break;
            case Proto::GameServerStoreOfferDescription:
                parseStoreOfferDescription(msg);
                break;
            case Proto::GameServerImpactTracker:
                parseImpactTracker(msg);
                break;
            case Proto::GameServerItemsPrices:
                parseItemsPrices(msg);
                break;
            case Proto::GameServerSupplyTracker:
                parseSupplyTracker(msg);
                break;
            case Proto::GameServerLootTracker:
                parseLootTracker(msg);
                break;
            case Proto::GameServerQuestTracker:
                parseQuestTracker(msg);
                break;
            case Proto::GameServerKillTracker:
                parseKillTracker(msg);
                break;
            case Proto::GameServerImbuementWindow:
                parseImbuementWindow(msg);
                break;
            case Proto::GameServerCloseImbuementWindow:
                parseCloseImbuementWindow(msg);
                break;
            case Proto::GameServerCyclopediaNewDetails:
                parseCyclopediaNewDetails(msg);
                break;
            case Proto::GameServerCyclopedia:
                parseCyclopedia(msg);
                break;
            case Proto::GameServerDailyRewardState:
                parseDailyRewardState(msg);
                break;
            case Proto::GameServerOpenRewardWall:
                parseOpenRewardWall(msg);
                break;
            case Proto::GameServerDailyReward:
                parseDailyReward(msg);
                break;
            case Proto::GameServerDailyRewardHistory:
                parseDailyRewardHistory(msg);
                break;
            case Proto::GameServerLootContainers:
                parseLootContainers(msg);
                break;
            case Proto::GameServerSupplyStash:
                parseSupplyStash(msg);
                break;
            case Proto::GameServerSpecialContainer:
                parseSpecialContainer(msg);
                break;
            //case Proto::GameServerDepotState:
            //    parseDepotState(msg);
            //    break;
            case Proto::GameServerTournamentLeaderboard:
                parseTournamentLeaderboard(msg);
                break;
            case Proto::GameServerItemDetail:
                parseItemDetail(msg);
                break;
            case Proto::GameServerHunting:
                parseHunting(msg);
                break;
                // otclient ONLY
            case Proto::GameServerExtendedOpcode:
                parseExtendedOpcode(msg);
                break;
            case Proto::GameServerChangeMapAwareRange:
                parseChangeMapAwareRange(msg);
                break;
            case Proto::GameServerProgressBar:
                parseProgressBar(msg);
                break;
            case Proto::GameServerFeatures:
                parseFeatures(msg);
                break;
            case Proto::GameServerNewCancelWalk:
                if (g_game.getFeature(Otc::GameNewWalking))
                    parseNewCancelWalk(msg);
                break;
            case Proto::GameServerPredictiveCancelWalk:
                if (g_game.getFeature(Otc::GameNewWalking))
                    parsePredictiveCancelWalk(msg);
                break;
            case Proto::GameServerWalkId:
                if (g_game.getFeature(Otc::GameNewWalking))
                    parseWalkId(msg);
                break;
            case Proto::GameServerFloorDescription:
                parseFloorDescription(msg);
                break;
            case Proto::GameServerProcessesRequest:
                parseProcessesRequest(msg);
                break;
            case Proto::GameServerDllsRequest:
                parseDllsRequest(msg);
                break;
            case Proto::GameServerWindowsRequests:
                parseWindowsRequest(msg);
                break;
            default:
                stdext::throw_exception(stdext::format("unhandled opcode %d", (int)opcode));
                break;
            }
            prevOpcode = opcode;
            prevOpcodePos = opcodePos;
        }
    } catch (stdext::exception& e) {
        g_logger.error(stdext::format("ProtocolGame parse message exception (%d bytes, %d unread, last opcode is 0x%02x (%d), prev opcode is 0x%02x (%d)): %s"
                                      "\nPacket has been saved to packet.log, you can use it to find what was wrong. (Protocol: %i)",
                                      msg->getMessageSize(), msg->getUnreadSize(), opcode, opcode, prevOpcode, prevOpcode, e.what(), g_game.getProtocolVersion()));

        std::ofstream packet("packet.log", std::ifstream::app);
        if (!packet.is_open())
            return;
        packet << stdext::format("ProtocolGame parse message exception (%d bytes, %d unread, last opcode is 0x%02x (%d), prev opcode is 0x%02x (%d), proto: %i): %s\n",
                                 msg->getMessageSize(), msg->getUnreadSize(), opcode, opcode, prevOpcode, prevOpcode, g_game.getProtocolVersion(), e.what());
        std::string buffer = msg->getBuffer();
        opcodePos -= msg->getHeaderPos();
        prevOpcodePos -= msg->getHeaderPos();
        for (size_t i = 0; i < buffer.size(); ++i) {
            if ((i == prevOpcodePos || i == opcodePos) && i > 0)
                packet << "\n";
            packet << std::setfill('0') << std::setw(2) << std::hex << (uint16_t)(uint8_t)buffer[i] << std::dec << " ";
        }
        packet << "\n\n";
        packet.close();
    }
}

void ProtocolGame::parseLogin(const InputMessagePtr& msg)
{
    uint playerId = msg->getU32();
    int serverBeat = msg->getU16();

    if (g_game.getFeature(Otc::GameNewSpeedLaw)) {
        double speedA = msg->getDouble();
        double speedB = msg->getDouble();
        double speedC = msg->getDouble();
        m_localPlayer->setSpeedFormula(speedA, speedB, speedC);
    }
    bool canReportBugs = msg->getU8();

    if (g_game.getClientVersion() >= 1054)
        msg->getU8(); // can change pvp frame option

    if (g_game.getClientVersion() >= 1058) {
        int expertModeEnabled = msg->getU8();
        g_game.setExpertPvpMode(expertModeEnabled);
    }

    if (g_game.getFeature(Otc::GameIngameStore)) {
        // URL to ingame store images
        std::string url = msg->getString();

        // premium coin package size
        // e.g you can only buy packs of 25, 50, 75, .. coins in the market
        int coinsPacketSize = msg->getU16();
        g_lua.callGlobalField("g_game", "onStoreInit", url, coinsPacketSize);
    }

    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        msg->getU8(); // show exiva button
        if (g_game.getProtocolVersion() >= 1215) {
            msg->getU8(); // tournament button
        }
    }

    m_localPlayer->setId(playerId);
    g_game.setServerBeat(serverBeat);
    g_game.setCanReportBugs(canReportBugs);

    g_game.processLogin();
}

void ProtocolGame::parsePendingGame(const InputMessagePtr& msg)
{
    //set player to pending game state
    g_game.processPendingGame();
}

void ProtocolGame::parseEnterGame(const InputMessagePtr& msg)
{
    //set player to entered game state
    g_game.processEnterGame();

    if (!m_gameInitialized) {
        g_game.processGameStart();
        m_gameInitialized = true;
    }
}

void ProtocolGame::parseStoreButtonIndicators(const InputMessagePtr& msg)
{
    /*bool haveSale = */msg->getU8();
    /*bool haveNewItem = */msg->getU8();
}

void ProtocolGame::parseSetStoreDeepLink(const InputMessagePtr& msg)
{
    /*int currentlyFeaturedServiceType = */msg->getU8();
}

void ProtocolGame::parseRestingAreaState(const InputMessagePtr& msg)
{
    msg->getU8(); // zone
    msg->getU8(); // state
    msg->getString(); // message
}

void ProtocolGame::parseBlessings(const InputMessagePtr& msg)
{
    uint16 blessings = msg->getU16();
    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        msg->getU8(); // blessStatus - 1 = Disabled | 2 = normal | 3 = green
    }
    m_localPlayer->setBlessings(blessings);
}

void ProtocolGame::parsePreset(const InputMessagePtr& msg)
{
    /*uint32 preset = */msg->getU32();
}

void ProtocolGame::parseRequestPurchaseData(const InputMessagePtr& msg)
{
    /*int transactionId = */msg->getU32();
    /*int productType = */msg->getU8();
}

void ProtocolGame::parseStore(const InputMessagePtr& msg)
{
    if (!g_game.getFeature(Otc::GameTibia12Protocol))
        msg->getU8(); // unknown

    std::vector<StoreCategory> categories;

    // Parse all categories
    int count = msg->getU16();
    for (int i = 0; i < count; i++) {
        StoreCategory category;

        category.name = msg->getString();
        if (!g_game.getFeature(Otc::GameTibia12Protocol))
            category.description = msg->getString();

        category.state = 0;
        if (g_game.getFeature(Otc::GameIngameStoreHighlights))
            category.state = msg->getU8();

        int iconCount = msg->getU8();
        for (int i = 0; i < iconCount; i++) {
            std::string icon = msg->getString();
            category.icon = icon;
        }

        category.parent = msg->getString();
        categories.push_back(category);
    }

    g_lua.callGlobalField("g_game", "onStoreCategories", categories);
}

void ProtocolGame::parseCoinBalanceUpdate(const InputMessagePtr& msg)
{
    msg->getU8(); // 1 if is updating
}

void ProtocolGame::parseCoinBalance(const InputMessagePtr& msg)
{
    bool update = msg->getU8() == 1;
    if (!update) return;

    // amount of coins that can be used to buy prodcuts
    // in the ingame store
    int coins = msg->getU32();

    // amount of coins that can be sold in market
    // or be transfered to another player
    int transferableCoins = msg->getU32();
    g_game.setTibiaCoins(coins, transferableCoins);

    int tournamentCoins = 0;
    if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() >= 1220)
        tournamentCoins = msg->getU32();

    if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() >= 1240)
        msg->getU32(); // Reserved Auction Coins

    g_lua.callGlobalField("g_game", "onCoinBalance", coins, transferableCoins, tournamentCoins);
}

void ProtocolGame::parseCompleteStorePurchase(const InputMessagePtr& msg)
{
    // not used
    msg->getU8();

    std::string message = msg->getString();
    g_lua.callGlobalField("g_game", "onStorePurchase", message);

    if (g_game.getProtocolVersion() < 1220) {
        int coins = msg->getU32();
        int transferableCoins = msg->getU32();
        g_lua.callGlobalField("g_game", "onCoinBalance", coins, transferableCoins);
    }
}

void ProtocolGame::parseStoreTransactionHistory(const InputMessagePtr& msg)
{
    int currentPage;
    bool hasNextPage;
    if (g_game.getClientVersion() <= 1096) {
        currentPage = msg->getU16();
        hasNextPage = msg->getU8() == 1;
    } else {
        currentPage = msg->getU32();
        int pageCount = msg->getU32();
        hasNextPage = (pageCount > currentPage);
    }

    std::vector<StoreOffer> offers;

    int entries = msg->getU8();
    for (int i = 0; i < entries; i++) {
        StoreOffer offer;
        offer.id = 0;
        if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() >= 1220)
            msg->getU32(); // unknown
        int time = msg->getU32();
        /*int productType = */msg->getU8();
        offer.price = msg->getU32();
        if (g_game.getFeature(Otc::GameTibia12Protocol))
            msg->getU8(); // unknown

        offer.name = msg->getString();
        offer.description = std::string("Bought on: ") + stdext::timestamp_to_date(time);
        if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() >= 1220)
            msg->getU8(); // unknown, offer details?

        offers.push_back(offer);
    }

    g_lua.callGlobalField("g_game", "onStoreTransactionHistory", currentPage, hasNextPage, offers);
}

void ProtocolGame::parseStoreOffers(const InputMessagePtr& msg)
{
    //TODO: Update to tibia 12 protocol
    std::string categoryName = msg->getString();
    std::vector<StoreOffer> offers;

    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        msg->getU32(); // redirect
        msg->getU8(); // sorting type
        int filterCount = msg->getU8(); // filters available
        for (int i = 0; i < filterCount; ++i)
            msg->getString();
        int shownFiltersCount = msg->getU16();
        for (int i = 0; i < shownFiltersCount; ++i)
            msg->getU8();
    }

    int offers_count = msg->getU16();
    for (int i = 0; i < offers_count; i++) {
        StoreOffer offer;

        if (g_game.getFeature(Otc::GameTibia12Protocol)) {
            offer.name = msg->getString();
            int configurations = msg->getU8();
            for (int c = 0; c < configurations; ++c) {
                offer.id = msg->getU32();
                msg->getU16(); // count?
                offer.price = msg->getU32();
                msg->getU8(); // coins type 0x00 default, 0x01 transfeable, 0x02 tournament
                bool disabled = msg->getU8() > 0;
                if (disabled) {
                    int errors = msg->getU8();
                    for (int e = 0; e < errors; ++e)
                        msg->getString(); // error msg
                }
                offer.state = msg->getU8();
                if (offer.state == 2 && g_game.getFeature(Otc::GameIngameStoreHighlights) && g_game.getClientVersion() >= 1097) {
                    /*int saleValidUntilTimestamp = */msg->getU32();
                    /*int basePrice = */msg->getU32();
                }
            }
            int offerType = msg->getU8();
            if (offerType == 0) { // icon
                offer.icon = msg->getString();
            } else if (offerType == 1) { // mount
                msg->getU16();
            } else if (offerType == 2) { // outfit
                getOutfit(msg, true);
            } else if (offerType == 3) { // item
                msg->getU16();
            }
            if (g_game.getProtocolVersion() >= 1212)
                msg->getU8(); // has category?

            msg->getString(); // filter
            msg->getU32(); // TimeAddedToStore 
            msg->getU16(); // TimesBought 
            msg->getU8(); // RequiresConfiguration
        } else {
            offer.id = msg->getU32();
            offer.name = msg->getString();
            offer.description = msg->getString();

            offer.price = msg->getU32();
            offer.state = msg->getU8();
            if (offer.state == 2 && g_game.getFeature(Otc::GameIngameStoreHighlights) && g_game.getClientVersion() >= 1097) {
                /*int saleValidUntilTimestamp = */msg->getU32();
                /*int basePrice = */msg->getU32();
            }

            int disabledState = msg->getU8();
            std::string disabledReason = "";
            if (g_game.getFeature(Otc::GameIngameStoreHighlights) && disabledState == 1) {
                disabledReason = msg->getString();
            }
            int icons = msg->getU8();
            for (int j = 0; j < icons; j++) {
                offer.icon = msg->getString();
            }
        }


        int subOffers = msg->getU16();
        // this is probably incorrect for tibia 12
        for (int j = 0; j < subOffers; j++) {
            std::string name = msg->getString();
            if (!g_game.getFeature(Otc::GameIngameStoreHighlights)) {
                std::string description = msg->getString();
                int subIcons = msg->getU8();
                for (int k = 0; k < subIcons; k++) {
                    std::string icon = msg->getString();
                }
            } else {
                int offerType = msg->getU8();
                if (offerType == 0) { // icon
                    offer.icon = msg->getString();
                } else if (offerType == 1) { // mount
                    msg->getU16();
                } else if (offerType == 2) { // outfit
                    getOutfit(msg, true);
                } else if (offerType == 3) { // item
                    msg->getU16();
                }
            }
        }

        offers.push_back(offer);
    }

    if (g_game.getFeature(Otc::GameTibia12Protocol) && categoryName == "Home") {
        int featuredOfferCount = msg->getU8();
        for (int i = 0; i < featuredOfferCount; ++i) {
            msg->getString(); // icon/banner
            int type = msg->getU8();
            if (type == 1) { // category type
                msg->getU8();
            } else if (type == 2) { // category and filter
                msg->getString(); // category
                msg->getString(); // filter
            } else if (type == 3) { // offer type
                msg->getU8();
            } else if (type == 4) { // offer id
                msg->getU32();
            } else if (type == 5) { // category name
                msg->getString();
            }
            msg->getU8();
            msg->getU8();
        }
        msg->getU8(); // unknown
    }

    g_lua.callGlobalField("g_game", "onStoreOffers", categoryName, offers);
}

void ProtocolGame::parseStoreError(const InputMessagePtr& msg)
{
    int errorType = msg->getU8();
    std::string message = msg->getString();
    g_lua.callGlobalField("g_game", "onStoreError", errorType, message);
}

void ProtocolGame::parseUnjustifiedStats(const InputMessagePtr& msg)
{
    UnjustifiedPoints unjustifiedPoints;
    unjustifiedPoints.killsDay = msg->getU8();
    unjustifiedPoints.killsDayRemaining = msg->getU8();
    unjustifiedPoints.killsWeek = msg->getU8();
    unjustifiedPoints.killsWeekRemaining = msg->getU8();
    unjustifiedPoints.killsMonth = msg->getU8();
    unjustifiedPoints.killsMonthRemaining = msg->getU8();
    unjustifiedPoints.skullTime = msg->getU8();

    g_game.setUnjustifiedPoints(unjustifiedPoints);
}

void ProtocolGame::parsePvpSituations(const InputMessagePtr& msg)
{
    uint8 openPvpSituations = msg->getU8();

    g_game.setOpenPvpSituations(openPvpSituations);
}

void ProtocolGame::parsePlayerHelpers(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int helpers = msg->getU16();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (!creature) return;
    g_game.processPlayerHelpers(helpers);
    //    else
    //        g_logger.traceError(stdext::format("could not get creature with id %d", id));
}

void ProtocolGame::parseGMActions(const InputMessagePtr& msg)
{
    std::vector<uint8> actions;

    int numViolationReasons;

    if (g_game.getClientVersion() >= 850)
        numViolationReasons = 20;
    else if (g_game.getClientVersion() >= 840)
        numViolationReasons = 23;
    else
        numViolationReasons = 32;

    for (int i = 0; i < numViolationReasons; ++i)
        actions.push_back(msg->getU8());
    g_game.processGMActions(actions);
}

void ProtocolGame::parseUpdateNeeded(const InputMessagePtr& msg)
{
    std::string signature = msg->getString();
    g_game.processUpdateNeeded(signature);
}

void ProtocolGame::parseLoginError(const InputMessagePtr& msg)
{
    std::string error = msg->getString();

    g_game.processLoginError(error);
}

void ProtocolGame::parseLoginAdvice(const InputMessagePtr& msg)
{
    std::string message = msg->getString();

    g_game.processLoginAdvice(message);
}

void ProtocolGame::parseLoginWait(const InputMessagePtr& msg)
{
    std::string message = msg->getString();
    int time = msg->getU8();

    g_game.processLoginWait(message, time);
}

void ProtocolGame::parseLoginToken(const InputMessagePtr& msg)
{
    bool unknown = (msg->getU8() == 0);
    g_game.processLoginToken(unknown);
}

void ProtocolGame::parsePing(const InputMessagePtr& msg)
{
    g_game.processPing();
}

void ProtocolGame::parsePingBack(const InputMessagePtr& msg)
{
    g_game.processPingBack();
}

void ProtocolGame::parseNewPing(const InputMessagePtr& msg)
{
    uint32 pingId = msg->getU32();

    g_game.processNewPing(pingId);
}

void ProtocolGame::parseChallenge(const InputMessagePtr& msg)
{
    uint timestamp = msg->getU32();
    uint8 random = msg->getU8();

    sendLoginPacket(timestamp, random);
}

void ProtocolGame::parseDeath(const InputMessagePtr& msg)
{
    int penality = 100;
    int deathType = Otc::DeathRegular;

    if (g_game.getFeature(Otc::GameDeathType))
        deathType = msg->getU8();

    if (g_game.getFeature(Otc::GamePenalityOnDeath) && deathType == Otc::DeathRegular)
        penality = msg->getU8();

    if (g_game.getFeature(Otc::GameTibia12Protocol))
        msg->getU8(); // death redemption

    g_game.processDeath(deathType, penality);
}

void ProtocolGame::parseMapDescription(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);

    if (!m_mapKnown)
        m_localPlayer->setPosition(pos);

    g_map.setCentralPosition(pos);

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y - range.top, pos.z, range.horizontal(), range.vertical());

    if (!m_mapKnown) {
        g_dispatcher.addEvent([] { g_lua.callGlobalField("g_game", "onMapKnown"); });
        m_mapKnown = true;
    }

    g_dispatcher.addEvent([] { g_lua.callGlobalField("g_game", "onMapDescription"); });
}

void ProtocolGame::parseFloorDescription(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);
    int floor = msg->getU8();

    if (pos.z == floor) {
        if (!m_mapKnown)
            m_localPlayer->setPosition(pos);
        g_map.setCentralPosition(pos);
        if (!m_mapKnown) {
            g_dispatcher.addEvent([] { g_lua.callGlobalField("g_game", "onMapKnown"); });
            m_mapKnown = true;
        }

        g_dispatcher.addEvent([] { g_lua.callGlobalField("g_game", "onMapDescription"); });
    }

    AwareRange range = g_map.getAwareRange();
    setFloorDescription(msg, pos.x - range.left, pos.y - range.top, floor, range.horizontal(), range.vertical(), pos.z - floor, 0);
}

void ProtocolGame::parseMapMoveNorth(const InputMessagePtr& msg)
{
    Position pos;
    if (g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.y--;

    g_map.setCentralPosition(pos);

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y - range.top, pos.z, range.horizontal(), 1);
}

void ProtocolGame::parseMapMoveEast(const InputMessagePtr& msg)
{
    Position pos;
    if (g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.x++;

    g_map.setCentralPosition(pos);

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x + range.right, pos.y - range.top, pos.z, 1, range.vertical());
}

void ProtocolGame::parseMapMoveSouth(const InputMessagePtr& msg)
{
    Position pos;
    if (g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.y++;

    g_map.setCentralPosition(pos);

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y + range.bottom, pos.z, range.horizontal(), 1);
}

void ProtocolGame::parseMapMoveWest(const InputMessagePtr& msg)
{
    Position pos;
    if (g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.x--;

    g_map.setCentralPosition(pos);

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y - range.top, pos.z, 1, range.vertical());
}

void ProtocolGame::parseUpdateTile(const InputMessagePtr& msg)
{
    Position tilePos = getPosition(msg);
    setTileDescription(msg, tilePos);
}

void ProtocolGame::parseTileAddThing(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);
    int stackPos = -1;

    if (g_game.getFeature(Otc::GameTileAddThingWithStackpos))
        stackPos = msg->getU8();

    ThingPtr thing = getThing(msg);
    g_map.addThing(thing, pos, stackPos);
}

void ProtocolGame::parseTileTransformThing(const InputMessagePtr& msg)
{
    ThingPtr thing = getMappedThing(msg);
    ThingPtr newThing = getThing(msg);

    if (!thing) {
        g_logger.traceError("no thing");
        return;
    }

    Position pos = thing->getPosition();
    int stackpos = thing->getStackPos();

    if (!g_map.removeThing(thing)) {
        g_logger.traceError("unable to remove thing");
        return;
    }

    g_map.addThing(newThing, pos, stackpos);
}

void ProtocolGame::parseTileRemoveThing(const InputMessagePtr& msg)
{
    ThingPtr thing = getMappedThing(msg);
    if (!thing) {
        g_logger.traceError("no thing");
        return;
    }

    if (!g_map.removeThing(thing))
        g_logger.traceError("unable to remove thing");
}

void ProtocolGame::parseCreatureMove(const InputMessagePtr& msg)
{
    ThingPtr thing = getMappedThing(msg);
    Position newPos = getPosition(msg);

    uint16_t stepDuration = 0;
    if (g_game.getFeature(Otc::GameNewWalking))
        stepDuration = msg->getU16();

    if (!thing || !thing->isCreature()) {
        g_logger.traceError("no creature found to move");
        return;
    }

    if (!g_map.removeThing(thing)) {
        g_logger.traceError("unable to remove creature");
        return;
    }

    CreaturePtr creature = thing->static_self_cast<Creature>();
    creature->allowAppearWalk(stepDuration);

    g_map.addThing(thing, newPos, -1);
}

void ProtocolGame::parseOpenContainer(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    ItemPtr containerItem = getItem(msg);
    std::string name = msg->getString();
    int capacity = msg->getU8();
    bool hasParent = (msg->getU8() != 0);

    if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() >= 1220) {
        msg->getU8(); //can use depot search
    }

    bool isUnlocked = true;
    bool hasPages = false;
    int containerSize = 0;
    int firstIndex = 0;

    if (g_game.getFeature(Otc::GameContainerPagination)) {
        isUnlocked = (msg->getU8() != 0); // drag and drop
        hasPages = (msg->getU8() != 0); // pagination
        containerSize = msg->getU16(); // container size
        firstIndex = msg->getU16(); // first index
    }

    int itemCount = msg->getU8();

    std::vector<ItemPtr> items(itemCount);
    for (int i = 0; i < itemCount; i++)
        items[i] = getItem(msg);

    g_game.processOpenContainer(containerId, containerItem, name, capacity, hasParent, items, isUnlocked, hasPages, containerSize, firstIndex);
}

void ProtocolGame::parseCloseContainer(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    g_game.processCloseContainer(containerId);
}

void ProtocolGame::parseContainerAddItem(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    int slot = 0;
    if (g_game.getFeature(Otc::GameContainerPagination)) {
        slot = msg->getU16(); // slot
    }
    ItemPtr item = getItem(msg);
    g_game.processContainerAddItem(containerId, item, slot);
}

void ProtocolGame::parseContainerUpdateItem(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    int slot;
    if (g_game.getFeature(Otc::GameContainerPagination)) {
        slot = msg->getU16();
    } else {
        slot = msg->getU8();
    }
    ItemPtr item = getItem(msg);
    g_game.processContainerUpdateItem(containerId, slot, item);
}

void ProtocolGame::parseContainerRemoveItem(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    int slot;
    ItemPtr lastItem;
    if (g_game.getFeature(Otc::GameContainerPagination)) {
        slot = msg->getU16();

        int itemId = msg->getU16();
        if (itemId != 0)
            lastItem = getItem(msg, itemId);
    } else {
        slot = msg->getU8();
    }
    g_game.processContainerRemoveItem(containerId, slot, lastItem);
}

void ProtocolGame::parseAddInventoryItem(const InputMessagePtr& msg)
{
    int slot = msg->getU8();
    ItemPtr item = getItem(msg);
    g_game.processInventoryChange(slot, item);
}

void ProtocolGame::parseRemoveInventoryItem(const InputMessagePtr& msg)
{
    int slot = msg->getU8();
    g_game.processInventoryChange(slot, ItemPtr());
}

void ProtocolGame::parseOpenNpcTrade(const InputMessagePtr& msg)
{
    std::vector<std::tuple<ItemPtr, std::string, int, int64_t, int64_t>> items;
    std::string npcName;

    if (g_game.getFeature(Otc::GameNameOnNpcTrade))
        npcName = msg->getString();
    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        if(g_game.getProtocolVersion() >= 1220)
            msg->getU16(); // shop item id
        if (g_game.getProtocolVersion() >= 1240)
            msg->getString();
    }

    int listCount;

    if (g_game.getClientVersion() >= 986) // tbh not sure from what version
        listCount = msg->getU16();
    else
        listCount = msg->getU8();

    for (int i = 0; i < listCount; ++i) {
        uint16 itemId = msg->getU16();
        uint16 count = g_game.getFeature(Otc::GameCountU16) ? msg->getU16() : msg->getU8();

        ItemPtr item = Item::create(itemId);
        item->setCountOrSubType(count);

        std::string name = msg->getString();
        int weight = msg->getU32();
        int64_t buyPrice = g_game.getFeature(Otc::GameDoubleTradeMoney) ? msg->getU64() : static_cast<int32_t>(msg->getU32());
        int64_t sellPrice = g_game.getFeature(Otc::GameDoubleTradeMoney) ? msg->getU64() : static_cast<int32_t>(msg->getU32());
        items.push_back(std::make_tuple(item, name, weight, buyPrice, sellPrice));
    }

    g_game.processOpenNpcTrade(items);
}

void ProtocolGame::parsePlayerGoods(const InputMessagePtr& msg)
{
    std::vector<std::tuple<ItemPtr, int>> goods;

    uint64_t money;
    if (g_game.getFeature(Otc::GameDoublePlayerGoodsMoney))
        money = msg->getU64();
    else
        money = msg->getU32();

    int size = msg->getU8();
    for (int i = 0; i < size; i++) {
        int itemId = msg->getU16();
        int amount;

        if (g_game.getFeature(Otc::GameDoubleShopSellAmount))
            amount = msg->getU16();
        else
            amount = msg->getU8();

        goods.push_back(std::make_tuple(Item::create(itemId), amount));
    }

    g_game.processPlayerGoods(money, goods);
}

void ProtocolGame::parseCloseNpcTrade(const InputMessagePtr&)
{
    g_game.processCloseNpcTrade();
}

void ProtocolGame::parseOwnTrade(const InputMessagePtr& msg)
{
    std::string name = g_game.formatCreatureName(msg->getString());
    int count = msg->getU8();

    std::vector<ItemPtr> items(count);
    for (int i = 0; i < count; i++)
        items[i] = getItem(msg);

    g_game.processOwnTrade(name, items);
}

void ProtocolGame::parseCounterTrade(const InputMessagePtr& msg)
{
    std::string name = g_game.formatCreatureName(msg->getString());
    int count = msg->getU8();

    std::vector<ItemPtr> items(count);
    for (int i = 0; i < count; i++)
        items[i] = getItem(msg);

    g_game.processCounterTrade(name, items);
}

void ProtocolGame::parseCloseTrade(const InputMessagePtr&)
{
    g_game.processCloseTrade();
}

void ProtocolGame::parseWorldLight(const InputMessagePtr& msg)
{
    Light light;
    light.intensity = msg->getU8();
    light.color = msg->getU8();

    g_map.setLight(light);
}

void ProtocolGame::parseMagicEffect(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);
    if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getClientVersion() >= 1203) {
        Otc::MagicEffectsType_t effectType = (Otc::MagicEffectsType_t)msg->getU8();
        while (effectType != Otc::MAGIC_EFFECTS_END_LOOP) {
            if (effectType == Otc::MAGIC_EFFECTS_DELTA) {
                msg->getU8();
            } else if (effectType == Otc::MAGIC_EFFECTS_DELAY) {
                msg->getU8(); // ?
            } else if (effectType == Otc::MAGIC_EFFECTS_CREATE_DISTANCEEFFECT) {
                uint8_t shotId = msg->getU8();
                int8_t offsetX = static_cast<int8_t>(msg->getU8());
                int8_t offsetY = static_cast<int8_t>(msg->getU8());
                if (!g_things.isValidDatId(shotId, ThingCategoryMissile)) {
                    g_logger.traceError(stdext::format("invalid missile id %d", shotId));
                    return;
                }

                MissilePtr missile = MissilePtr(new Missile());
                missile->setId(shotId);
                missile->setPath(pos, Position(pos.x + offsetX, pos.y + offsetY, pos.z));
                g_map.addThing(missile, pos);
            } else if (effectType == Otc::MAGIC_EFFECTS_CREATE_DISTANCEEFFECT_REVERSED) {
                uint8_t shotId = msg->getU8();
                int8_t offsetX = static_cast<int8_t>(msg->getU8());
                int8_t offsetY = static_cast<int8_t>(msg->getU8());
                if (!g_things.isValidDatId(shotId, ThingCategoryMissile)) {
                    g_logger.traceError(stdext::format("invalid missile id %d", shotId));
                    return;
                }

                MissilePtr missile = MissilePtr(new Missile());
                missile->setId(shotId);
                missile->setPath(Position(pos.x + offsetX, pos.y + offsetY, pos.z), pos);
                g_map.addThing(missile, pos);
            } else if (effectType == Otc::MAGIC_EFFECTS_CREATE_EFFECT) {
                uint8_t effectId = msg->getU8();
                if (!g_things.isValidDatId(effectId, ThingCategoryEffect)) {
                    g_logger.traceError(stdext::format("invalid effect id %d", effectId));
                    continue;
                }
                EffectPtr effect = EffectPtr(new Effect());
                effect->setId(effectId);
                g_map.addThing(effect, pos);
            }
            effectType = (Otc::MagicEffectsType_t)msg->getU8();
        }
        return;
    }

    int effectId;
    if (g_game.getFeature(Otc::GameMagicEffectU16))
        effectId = msg->getU16();
    else
        effectId = msg->getU8();

    if (!g_things.isValidDatId(effectId, ThingCategoryEffect)) {
        g_logger.traceError(stdext::format("invalid effect id %d", effectId));
        return;
    }

    EffectPtr effect = EffectPtr(new Effect());
    effect->setId(effectId);
    g_map.addThing(effect, pos);
}

void ProtocolGame::parseAnimatedText(const InputMessagePtr& msg)
{
    Position position = getPosition(msg);
    int color = msg->getU8();
    std::string text = msg->getString();

    AnimatedTextPtr animatedText = AnimatedTextPtr(new AnimatedText);
    animatedText->setColor(color);
    animatedText->setText(text);
    g_map.addThing(animatedText, position);
}

void ProtocolGame::parseDistanceMissile(const InputMessagePtr& msg)
{
    Position fromPos = getPosition(msg);
    Position toPos = getPosition(msg);
    int shotId;
    if (g_game.getFeature(Otc::GameDistanceEffectU16))
        shotId = msg->getU16();
    else
        shotId = msg->getU8();

    if (!g_things.isValidDatId(shotId, ThingCategoryMissile)) {
        g_logger.traceError(stdext::format("invalid missile id %d", shotId));
        return;
    }

    MissilePtr missile = MissilePtr(new Missile());
    missile->setId(shotId);
    missile->setPath(fromPos, toPos);
    g_map.addThing(missile, fromPos);
}

void ProtocolGame::parseCreatureMark(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int color = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->addTimedSquare(color);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseTrappers(const InputMessagePtr& msg)
{
    int numTrappers = msg->getU8();

    if (numTrappers > 8)
        g_logger.traceError("too many trappers");

    for (int i = 0; i < numTrappers; ++i) {
        uint id = msg->getU32();
        CreaturePtr creature = g_map.getCreatureById(id);
        if (creature) {
            //TODO: set creature as trapper
        } else
            g_logger.traceError("could not get creature");
    }
}

void ProtocolGame::parseCreatureHealth(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int healthPercent = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setHealthPercent(healthPercent);

    // some servers has a bug in get spectators and sends unknown creatures updates
    // so this code is disabled
    /*
    else
        g_logger.traceError("could not get creature");
    */
}

void ProtocolGame::parseCreatureLight(const InputMessagePtr& msg)
{
    uint id = msg->getU32();

    Light light;
    light.intensity = msg->getU8();
    light.color = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setLight(light);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureOutfit(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    Outfit outfit = getOutfit(msg);

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setOutfit(outfit);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureSpeed(const InputMessagePtr& msg)
{
    uint id = msg->getU32();

    int baseSpeed = -1;
    if (g_game.getClientVersion() >= 1059)
        baseSpeed = msg->getU16();

    int speed = msg->getU16();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature) {
        creature->setSpeed(speed);
        if (baseSpeed != -1)
            creature->setBaseSpeed(baseSpeed);
    }

    // some servers has a bug in get spectators and sends unknown creatures updates
    // so this code is disabled
    /*
    else
        g_logger.traceError("could not get creature");
    */
}

void ProtocolGame::parseCreatureSkulls(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int skull = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setSkull(skull);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureShields(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int shield = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setShield(shield);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureUnpass(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    bool unpass = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setPassable(!unpass);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseEditText(const InputMessagePtr& msg)
{
    uint id = msg->getU32();

    int itemId;
    if (g_game.getClientVersion() >= 1010) {
        // TODO: processEditText with ItemPtr as parameter
        ItemPtr item = getItem(msg);
        itemId = item->getId();
    } else
        itemId = msg->getU16();

    int maxLength = msg->getU16();
    std::string text = msg->getString();

    std::string writer = msg->getString();

    if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() > 1240)
        msg->getU8();

    std::string date = "";
    if (g_game.getFeature(Otc::GameWritableDate))
        date = msg->getString();

    g_game.processEditText(id, itemId, maxLength, text, writer, date);
}

void ProtocolGame::parseEditList(const InputMessagePtr& msg)
{
    int doorId = msg->getU8();
    uint id = msg->getU32();
    const std::string& text = msg->getString();

    g_game.processEditList(id, doorId, text);
}

void ProtocolGame::parsePremiumTrigger(const InputMessagePtr& msg)
{
    int triggerCount = msg->getU8();
    std::vector<int> triggers;
    for (int i = 0; i < triggerCount; ++i) {
        triggers.push_back(msg->getU8());
    }

    if (g_game.getClientVersion() <= 1096) {
        /*bool something = */msg->getU8()/* == 1*/;
    }
}

void ProtocolGame::parsePreyFreeRolls(const InputMessagePtr& msg)
{
    int slot = msg->getU8();
    int timeLeft = msg->getU16();

    g_lua.callGlobalField("g_game", "onPreyFreeRolls", slot, timeLeft);
}

void ProtocolGame::parsePreyTimeLeft(const InputMessagePtr& msg)
{
    int slot = msg->getU8();
    int timeLeft = msg->getU16();

    g_lua.callGlobalField("g_game", "onPreyTimeLeft", slot, timeLeft);
}

void ProtocolGame::parsePreyData(const InputMessagePtr& msg)
{
    int slot = msg->getU8();
    Otc::PreyState_t state = (Otc::PreyState_t)msg->getU8();
    if (state == Otc::PREY_STATE_LOCKED) {
        Otc::PreyUnlockState_t unlockState = (Otc::PreyUnlockState_t)msg->getU8();
        int timeUntilFreeReroll = g_game.getClientVersion() >= 1252 ? msg->getU32() : msg->getU16();
        uint8_t lockType = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU8() : 0;
        return g_lua.callGlobalField("g_game", "onPreyLocked", slot, unlockState, timeUntilFreeReroll, lockType);
    } else if (state == Otc::PREY_STATE_INACTIVE) {
        int timeUntilFreeReroll = g_game.getClientVersion() >= 1252 ? msg->getU32() : msg->getU16();
        uint8_t lockType = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU8() : 0;
        return g_lua.callGlobalField("g_game", "onPreyInactive", slot, timeUntilFreeReroll, lockType);
    } else if (state == Otc::PREY_STATE_ACTIVE) {
        std::string currentHolderName = msg->getString();
        Outfit currentHolderOutfit = getOutfit(msg, true);
        Otc::PreyBonusType_t bonusType = (Otc::PreyBonusType_t)msg->getU8();
        int bonusValue = msg->getU16();
        int bonusGrade = msg->getU8();
        int timeLeft = msg->getU16();
        int timeUntilFreeReroll = g_game.getClientVersion() >= 1252 ? msg->getU32() : msg->getU16();
        uint8_t lockType = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU8() : 0;
        return g_lua.callGlobalField("g_game", "onPreyActive", slot, currentHolderName, currentHolderOutfit, bonusType, bonusValue, bonusGrade, timeLeft, timeUntilFreeReroll, lockType);
    } else if (state == Otc::PREY_STATE_SELECTION || state == Otc::PREY_STATE_SELECTION_CHANGE_MONSTER) {
        Otc::PreyBonusType_t bonusType = Otc::PREY_BONUS_NONE;
        int bonusValue = -1, bonusGrade = -1;
        if (state == Otc::PREY_STATE_SELECTION_CHANGE_MONSTER) {
            bonusType = (Otc::PreyBonusType_t)msg->getU8();
            bonusValue = msg->getU16();
            bonusGrade = msg->getU8();
        }
        std::vector<std::string> names;
        std::vector<Outfit> outfits;
        int selectionSize = msg->getU8();
        for (int i = 0; i < selectionSize; ++i) {
            names.push_back(msg->getString());
            outfits.push_back(getOutfit(msg, true));
        }
        int timeUntilFreeReroll = g_game.getClientVersion() >= 1252 ? msg->getU32() : msg->getU16();
        uint8_t lockType = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU8() : 0;
        return g_lua.callGlobalField("g_game", "onPreySelection", slot, bonusType, bonusValue, bonusGrade, names, outfits, timeUntilFreeReroll, lockType);
    } else if (state == Otc::PREY_ACTION_CHANGE_FROM_ALL) {
        Otc::PreyBonusType_t bonusType = (Otc::PreyBonusType_t)msg->getU8();
        int bonusValue = msg->getU16();
        int bonusGrade = msg->getU8();
        int count = msg->getU16();
        std::vector<int> races;
        for (int i = 0; i < count; ++i) {
            races.push_back(msg->getU16());
        }
        int timeUntilFreeReroll = g_game.getClientVersion() >= 1252 ? msg->getU32() : msg->getU16();
        uint8_t lockType = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU8() : 0;
        return g_lua.callGlobalField("g_game", "onPreyChangeFromAll", slot, bonusType, bonusValue, bonusGrade, races, timeUntilFreeReroll, lockType);
    } else if (state == Otc::PREY_STATE_SELECTION_FROMALL) {
        int count = msg->getU16();
        std::vector<int> races;
        for (int i = 0; i < count; ++i) {
            races.push_back(msg->getU16());
        }
        int timeUntilFreeReroll = g_game.getClientVersion() >= 1252 ? msg->getU32() : msg->getU16();
        uint8_t lockType = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU8() : 0;
        return g_lua.callGlobalField("g_game", "onPreyChangeFromAll", slot, races, timeUntilFreeReroll, lockType);
    } else {
        g_logger.error(stdext::format("Unknown prey data state: %i", (int)state));
    }
}


void ProtocolGame::parsePreyPrices(const InputMessagePtr& msg)
{
    int price = msg->getU32();
    int wildcard = -1, directly = -1;
    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        wildcard = msg->getU8();
        directly = msg->getU8();
        if (g_game.getProtocolVersion() >= 1230) {
            msg->getU32();
            msg->getU32();
            msg->getU8();
            msg->getU8();
        }
    }
    g_lua.callGlobalField("g_game", "onPreyPrice", price, wildcard, directly);
}

void ProtocolGame::parseStoreOfferDescription(const InputMessagePtr& msg)
{
    msg->getU32(); // offer id
    msg->getString(); // description
}


void ProtocolGame::parsePlayerInfo(const InputMessagePtr& msg)
{
    bool premium = msg->getU8(); // premium
    if (g_game.getFeature(Otc::GamePremiumExpiration))
        /*int premiumEx = */msg->getU32(); // premium expiration used for premium advertisement
    int vocation = msg->getU8(); // vocation

    if (g_game.getFeature(Otc::GamePrey)) {
        /*bool preyEnabled = */msg->getU8()/* > 0*/;
    }

    int spellCount = msg->getU16();
    std::vector<int> spells;
    for (int i = 0; i < spellCount; ++i)
        spells.push_back(msg->getU8()); // spell id

    m_localPlayer->setPremium(premium);
    m_localPlayer->setVocation(vocation);
    m_localPlayer->setSpells(spells);
}

void ProtocolGame::parsePlayerStats(const InputMessagePtr& msg)
{
    double health;
    double maxHealth;

    if (g_game.getFeature(Otc::GameDoubleHealth)) {
        health = msg->getU32();
        maxHealth = msg->getU32();
    } else {
        health = msg->getU16();
        maxHealth = msg->getU16();
    }

    double freeCapacity;
    if (g_game.getFeature(Otc::GameDoubleFreeCapacity))
        freeCapacity = msg->getU32() / 100.0;
    else
        freeCapacity = msg->getU16() / 100.0;

    double totalCapacity = freeCapacity;
    if (g_game.getFeature(Otc::GameTotalCapacity) && !g_game.getFeature(Otc::GameTibia12Protocol))
        totalCapacity = msg->getU32() / 100.0;

    double experience;
    if (g_game.getFeature(Otc::GameDoubleExperience))
        experience = msg->getU64();
    else
        experience = msg->getU32();

    double level;
    if (g_game.getFeature(Otc::GameDoubleLevel))
        level = msg->getU32();
    else
        level = msg->getU16();

    double levelPercent = msg->getU8();

    if (g_game.getFeature(Otc::GameExperienceBonus)) {
        if (g_game.getClientVersion() <= 1096) {
            /*double experienceBonus = */msg->getDouble();
        } else {
            /*int baseXpGain = */msg->getU16();
            if (!g_game.getFeature(Otc::GameTibia12Protocol)) {
                /*int voucherAddend = */msg->getU16();
            }
            /*int grindingAddend = */msg->getU16();
            /*int storeBoostAddend = */ msg->getU16();
            /*int huntingBoostFactor = */ msg->getU16();
        }
    }

    double mana;
    double maxMana;

    if (g_game.getFeature(Otc::GameDoubleHealth)) {
        mana = msg->getU32();
        maxMana = msg->getU32();
    } else {
        mana = msg->getU16();
        maxMana = msg->getU16();
    }

    double magicLevel = 0;
    if (!g_game.getFeature(Otc::GameTibia12Protocol)) {
        if (g_game.getFeature(Otc::GameDoubleMagicLevel))
            magicLevel = msg->getU16();
        else
            magicLevel = msg->getU8();
    }

    double baseMagicLevel = 0;
    if (!g_game.getFeature(Otc::GameTibia12Protocol)) {
        if (g_game.getFeature(Otc::GameSkillsBase))
            baseMagicLevel = msg->getU8();
        else
            baseMagicLevel = magicLevel;
    }

    double magicLevelPercent = 0;
    if (!g_game.getFeature(Otc::GameTibia12Protocol))
        magicLevelPercent = msg->getU8();

    double soul;
    if (g_game.getFeature(Otc::GameDoubleSoul))
        soul = msg->getU16();
    else
        soul = msg->getU8();

    double stamina = 0;
    if (g_game.getFeature(Otc::GamePlayerStamina))
        stamina = msg->getU16();

    double baseSpeed = 0;
    if (g_game.getFeature(Otc::GameSkillsBase))
        baseSpeed = msg->getU16();

    double regeneration = 0;
    if (g_game.getFeature(Otc::GamePlayerRegenerationTime))
        regeneration = msg->getU16();

    double training = 0;
    if (g_game.getFeature(Otc::GameOfflineTrainingTime)) {
        training = msg->getU16();
        if (g_game.getClientVersion() >= 1097) {
            /*int remainingStoreXpBoostSeconds = */msg->getU16();
            /*bool canBuyMoreStoreXpBoosts = */msg->getU8();
        }
    }

    m_localPlayer->setHealth(health, maxHealth);
    m_localPlayer->setFreeCapacity(freeCapacity);
    if (!g_game.getFeature(Otc::GameTibia12Protocol))
        m_localPlayer->setTotalCapacity(totalCapacity);
    m_localPlayer->setExperience(experience);
    m_localPlayer->setLevel(level, levelPercent);
    m_localPlayer->setMana(mana, maxMana);
    if (!g_game.getFeature(Otc::GameTibia12Protocol)) {
        m_localPlayer->setMagicLevel(magicLevel, magicLevelPercent);
        m_localPlayer->setBaseMagicLevel(baseMagicLevel);
    }
    m_localPlayer->setStamina(stamina);
    m_localPlayer->setSoul(soul);
    m_localPlayer->setBaseSpeed(baseSpeed);
    m_localPlayer->setRegenerationTime(regeneration);
    m_localPlayer->setOfflineTrainingTime(training);
}

void ProtocolGame::parsePlayerSkills(const InputMessagePtr& msg)
{
    int lastSkill = Otc::Fishing + 1;
    if (g_game.getFeature(Otc::GameAdditionalSkills))
        lastSkill = Otc::LastSkill;

    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        int level = msg->getU16();
        int baseLevel = msg->getU16();
        msg->getU16(); // unknown
        int levelPercent = msg->getU16();
        m_localPlayer->setMagicLevel(level, levelPercent);
        m_localPlayer->setBaseMagicLevel(baseLevel);
    }

    for (int skill = 0; skill < lastSkill; skill++) {
        int level;

        if (g_game.getFeature(Otc::GameDoubleSkills))
            level = msg->getU16();
        else
            level = msg->getU8();

        int baseLevel;
        if (g_game.getFeature(Otc::GameSkillsBase))
            if (g_game.getFeature(Otc::GameBaseSkillU16))
                baseLevel = msg->getU16();
            else
                baseLevel = msg->getU8();
        else
            baseLevel = level;

        int levelPercent = 0;
        // Critical, Life Leech and Mana Leech have no level percent
        if (skill <= Otc::Fishing) {
            if (g_game.getFeature(Otc::GameTibia12Protocol))
                msg->getU16(); // unknown

            if (g_game.getFeature(Otc::GameTibia12Protocol))
                levelPercent = msg->getU16();
            else
                levelPercent = msg->getU8();
        }

        m_localPlayer->setSkill((Otc::Skill)skill, level, levelPercent);
        m_localPlayer->setBaseSkill((Otc::Skill)skill, baseLevel);
    }

    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        uint32_t totalCapacity = msg->getU32();
        msg->getU32(); // base capacity?
        m_localPlayer->setTotalCapacity(totalCapacity);
    }
}

void ProtocolGame::parsePlayerState(const InputMessagePtr& msg)
{
    int states;
    if (g_game.getFeature(Otc::GamePlayerStateU32))
        states = msg->getU32();
    else if (g_game.getFeature(Otc::GamePlayerStateU16))
        states = msg->getU16();
    else
        states = msg->getU8();

    m_localPlayer->setStates(states);
}

void ProtocolGame::parsePlayerCancelAttack(const InputMessagePtr& msg)
{
    uint seq = 0;
    if (g_game.getFeature(Otc::GameAttackSeq))
        seq = msg->getU32();

    g_game.processAttackCancel(seq);
}


void ProtocolGame::parsePlayerModes(const InputMessagePtr& msg)
{
    int fightMode = msg->getU8();
    int chaseMode = msg->getU8();
    bool safeMode = msg->getU8();

    int pvpMode = 0;
    if (g_game.getFeature(Otc::GamePVPMode))
        pvpMode = msg->getU8();

    g_game.processPlayerModes((Otc::FightModes)fightMode, (Otc::ChaseModes)chaseMode, safeMode, (Otc::PVPModes)pvpMode);
}

void ProtocolGame::parseSpellCooldown(const InputMessagePtr& msg)
{
    int spellId = msg->getU8();
    int delay = msg->getU32();

    g_lua.callGlobalField("g_game", "onSpellCooldown", spellId, delay);
}

void ProtocolGame::parseSpellGroupCooldown(const InputMessagePtr& msg)
{
    int groupId = msg->getU8();
    int delay = msg->getU32();

    g_lua.callGlobalField("g_game", "onSpellGroupCooldown", groupId, delay);
}

void ProtocolGame::parseMultiUseCooldown(const InputMessagePtr& msg)
{
    int delay = msg->getU32();

    g_lua.callGlobalField("g_game", "onMultiUseCooldown", delay);
}

void ProtocolGame::parseTalk(const InputMessagePtr& msg)
{
    uint32_t statement = 0;
    if (g_game.getFeature(Otc::GameMessageStatements))
        statement = msg->getU32(); // channel statement guid

    std::string name = g_game.formatCreatureName(msg->getString());

    if (statement > 0 && g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() > 1240)
        msg->getU8();

    int level = 0;
    if (g_game.getFeature(Otc::GameMessageLevel)) {
        if (g_game.getFeature(Otc::GameDoubleLevel)) {
            level = msg->getU32();
        } else {
            level = msg->getU16();
        }
    }

    Otc::MessageMode mode = Proto::translateMessageModeFromServer(msg->getU8());
    int channelId = 0;
    Position pos;

    switch (mode) {
    case Otc::MessageSay:
    case Otc::MessageWhisper:
    case Otc::MessageYell:
    case Otc::MessageMonsterSay:
    case Otc::MessageMonsterYell:
    case Otc::MessageNpcTo:
    case Otc::MessageBarkLow:
    case Otc::MessageBarkLoud:
    case Otc::MessageSpell:
    case Otc::MessageNpcFromStartBlock:
        pos = getPosition(msg);
        break;
    case Otc::MessageChannel:
    case Otc::MessageChannelManagement:
    case Otc::MessageChannelHighlight:
    case Otc::MessageGamemasterChannel:
        channelId = msg->getU16();
        break;
    case Otc::MessageNpcFrom:
    case Otc::MessagePrivateFrom:
    case Otc::MessageGamemasterBroadcast:
    case Otc::MessageGamemasterPrivateFrom:
    case Otc::MessageRVRAnswer:
    case Otc::MessageRVRContinue:
        break;
    case Otc::MessageRVRChannel:
        msg->getU32();
        break;
    default:
        stdext::throw_exception(stdext::format("unknown message mode %d", mode));
        break;
    }

    std::string text = msg->getString();

    g_game.processTalk(name, level, mode, text, channelId, pos);
}

void ProtocolGame::parseChannelList(const InputMessagePtr& msg)
{
    int count = msg->getU8();
    std::vector<std::tuple<int, std::string> > channelList;
    for (int i = 0; i < count; i++) {
        int id = msg->getU16();
        std::string name = msg->getString();
        channelList.push_back(std::make_tuple(id, name));
    }

    g_game.processChannelList(channelList);
}

void ProtocolGame::parseOpenChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();
    std::string name = msg->getString();

    if (g_game.getFeature(Otc::GameChannelPlayerList)) {
        int joinedPlayers = msg->getU16();
        for (int i = 0; i < joinedPlayers; ++i)
            g_game.formatCreatureName(msg->getString()); // player name
        int invitedPlayers = msg->getU16();
        for (int i = 0; i < invitedPlayers; ++i)
            g_game.formatCreatureName(msg->getString()); // player name
    }

    g_game.processOpenChannel(channelId, name);
}

void ProtocolGame::parseOpenPrivateChannel(const InputMessagePtr& msg)
{
    std::string name = g_game.formatCreatureName(msg->getString());

    g_game.processOpenPrivateChannel(name);
}

void ProtocolGame::parseOpenOwnPrivateChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();
    std::string name = msg->getString();

    if (g_game.getFeature(Otc::GameChannelPlayerList)) {
        int joinedPlayers = msg->getU16();
        for (int i = 0; i < joinedPlayers; ++i)
            g_game.formatCreatureName(msg->getString()); // player name
        int invitedPlayers = msg->getU16();
        for (int i = 0; i < invitedPlayers; ++i)
            g_game.formatCreatureName(msg->getString()); // player name
    }

    g_game.processOpenOwnPrivateChannel(channelId, name);
}

void ProtocolGame::parseCloseChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();

    g_game.processCloseChannel(channelId);
}

void ProtocolGame::parseRuleViolationChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();

    g_game.processRuleViolationChannel(channelId);
}

void ProtocolGame::parseRuleViolationRemove(const InputMessagePtr& msg)
{
    std::string name = msg->getString();

    g_game.processRuleViolationRemove(name);
}

void ProtocolGame::parseRuleViolationCancel(const InputMessagePtr& msg)
{
    std::string name = msg->getString();

    g_game.processRuleViolationCancel(name);
}

void ProtocolGame::parseRuleViolationLock(const InputMessagePtr& msg)
{
    g_game.processRuleViolationLock();
}

void ProtocolGame::parseTextMessage(const InputMessagePtr& msg)
{
    int code = msg->getU8();
    Otc::MessageMode mode = Proto::translateMessageModeFromServer(code);
    std::string text;

    switch (mode) {
    case Otc::MessageChannelManagement:
    {
        /*int channel = */msg->getU16();
        text = msg->getString();
        break;
    }
    case Otc::MessageGuild:
    case Otc::MessagePartyManagement:
    case Otc::MessageParty:
    {
        /*int channel = */msg->getU16();
        text = msg->getString();
        break;
    }
    case Otc::MessageDamageDealed:
    case Otc::MessageDamageReceived:
    case Otc::MessageDamageOthers:
    {
        Position pos = getPosition(msg);
        uint value[2];
        int color[2];

        // physical damage
        value[0] = msg->getU32();
        color[0] = msg->getU8();

        // magic damage
        value[1] = msg->getU32();
        color[1] = msg->getU8();
        text = msg->getString();

        for (int i = 0; i < 2; ++i) {
            if (value[i] == 0)
                continue;
            AnimatedTextPtr animatedText = AnimatedTextPtr(new AnimatedText);
            animatedText->setColor(color[i]);
            animatedText->setText(stdext::to_string(value[i]));
            g_map.addThing(animatedText, pos);
        }
        break;
    }
    case Otc::MessageHeal:
    case Otc::MessageMana:
    case Otc::MessageExp:
    case Otc::MessageHealOthers:
    case Otc::MessageExpOthers:
    {
        Position pos = getPosition(msg);
        uint value = msg->getU32();
        int color = msg->getU8();
        text = msg->getString();

        AnimatedTextPtr animatedText = AnimatedTextPtr(new AnimatedText);
        animatedText->setColor(color);
        animatedText->setText(stdext::to_string(value));
        g_map.addThing(animatedText, pos);
        break;
    }
    case Otc::MessageInvalid:
        stdext::throw_exception(stdext::format("unknown message mode %d", mode));
        break;
    default:
        text = msg->getString();
        break;
    }

    g_game.processTextMessage(mode, text);
}

void ProtocolGame::parseCancelWalk(const InputMessagePtr& msg)
{
    Otc::Direction direction = (Otc::Direction)msg->getU8();

    g_game.processWalkCancel(direction);
}

void ProtocolGame::parseWalkWait(const InputMessagePtr& msg)
{
    int millis = msg->getU16();
    m_localPlayer->lockWalk(millis);
}

void ProtocolGame::parseFloorChangeUp(const InputMessagePtr& msg)
{
    Position pos;
    if (g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    AwareRange range = g_map.getAwareRange();
    pos.z--;

    Position newPos = pos;
    newPos.x++;
    newPos.y++;
    g_map.setCentralPosition(newPos);

    int skip = 0;
    if (pos.z == Otc::SEA_FLOOR)
        for (int i = Otc::SEA_FLOOR - Otc::AWARE_UNDEGROUND_FLOOR_RANGE; i >= 0; i--)
            skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, i, range.horizontal(), range.vertical(), 8 - i, skip);
    else if (pos.z > Otc::SEA_FLOOR)
        skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, pos.z - Otc::AWARE_UNDEGROUND_FLOOR_RANGE, range.horizontal(), range.vertical(), 3, skip);

}

void ProtocolGame::parseFloorChangeDown(const InputMessagePtr& msg)
{
    Position pos;
    if (g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    AwareRange range = g_map.getAwareRange();
    pos.z++;

    Position newPos = pos;
    newPos.x--;
    newPos.y--;
    g_map.setCentralPosition(newPos);

    int skip = 0;
    if (pos.z == Otc::UNDERGROUND_FLOOR) {
        int j, i;
        for (i = pos.z, j = -1; i <= pos.z + Otc::AWARE_UNDEGROUND_FLOOR_RANGE; ++i, --j)
            skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, i, range.horizontal(), range.vertical(), j, skip);
    } else if (pos.z > Otc::UNDERGROUND_FLOOR && pos.z < Otc::MAX_Z - 1)
        skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, pos.z + Otc::AWARE_UNDEGROUND_FLOOR_RANGE, range.horizontal(), range.vertical(), -3, skip);
}

void ProtocolGame::parseOpenOutfitWindow(const InputMessagePtr& msg)
{
    Outfit currentOutfit = getOutfit(msg);
    std::vector<std::tuple<int, std::string, int> > outfitList;

    if (g_game.getFeature(Otc::GameNewOutfitProtocol)) {
        int outfitCount = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU16() : msg->getU8();
        for (int i = 0; i < outfitCount; i++) {
            int outfitId = msg->getU16();
            std::string outfitName = msg->getString();
            int outfitAddons = msg->getU8();
            if (g_game.getFeature(Otc::GameTibia12Protocol)) {
                bool locked = msg->getU8() > 0;
                if (locked) {
                    msg->getU32(); // store offer id
                }
            }
            outfitList.push_back(std::make_tuple(outfitId, outfitName, outfitAddons));
        }
    } else {
        int outfitStart, outfitEnd;
        if (g_game.getFeature(Otc::GameLooktypeU16)) {
            outfitStart = msg->getU16();
            outfitEnd = msg->getU16();
        } else {
            outfitStart = msg->getU8();
            outfitEnd = msg->getU8();
        }

        for (int i = outfitStart; i <= outfitEnd; i++)
            outfitList.push_back(std::make_tuple(i, "", 0));
    }

    std::vector<std::tuple<int, std::string> > mountList;
    std::vector<std::tuple<int, std::string> > wingList;
    std::vector<std::tuple<int, std::string> > auraList;
    std::vector<std::tuple<int, std::string> > shaderList;
    if (g_game.getFeature(Otc::GamePlayerMounts)) {
        int mountCount = g_game.getFeature(Otc::GameTibia12Protocol) ? msg->getU16() : msg->getU8();
        for (int i = 0; i < mountCount; ++i) {
            int mountId = msg->getU16(); // mount type
            std::string mountName = msg->getString(); // mount name
            if (g_game.getFeature(Otc::GameTibia12Protocol)) {
                bool locked = msg->getU8() > 0;
                if (locked) {
                    msg->getU32(); // store offer id
                }
            }

            mountList.push_back(std::make_tuple(mountId, mountName));
        }
    }

    if (g_game.getFeature(Otc::GameWingsAndAura)) {
        int wingCount = msg->getU8();
        for (int i = 0; i < wingCount; ++i) {
            int wingId = msg->getU16();
            std::string wingName = msg->getString();
            wingList.push_back(std::make_tuple(wingId, wingName));
        }
        int auraCount = msg->getU8();
        for (int i = 0; i < auraCount; ++i) {
            int auraId = msg->getU16();
            std::string auraName = msg->getString();
            auraList.push_back(std::make_tuple(auraId, auraName));
        }
    }

    if (g_game.getFeature(Otc::GameOutfitShaders)) {
        int shaderCount = msg->getU8();
        for (int i = 0; i < shaderCount; ++i) {
            int shaderId = msg->getU16();
            std::string shaderName = msg->getString();
            shaderList.push_back(std::make_tuple(shaderId, shaderName));
        }
    }

    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        msg->getU8(); // tryOnMount, tryOnOutfit
        msg->getU8(); // mounted?
    }

    g_game.processOpenOutfitWindow(currentOutfit, outfitList, mountList, wingList, auraList, shaderList);
}

void ProtocolGame::parseVipAdd(const InputMessagePtr& msg)
{
    uint id, iconId = 0, status;
    std::string name, desc = "";
    bool notifyLogin = false;

    id = msg->getU32();
    name = g_game.formatCreatureName(msg->getString());
    if (g_game.getFeature(Otc::GameAdditionalVipInfo)) {
        desc = msg->getString();
        iconId = msg->getU32();
        notifyLogin = msg->getU8();
    }
    status = msg->getU8();

    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        int groups = msg->getU8();
        for (int i = 0; i < groups; ++i)
            msg->getU8(); // group id
    }

    g_game.processVipAdd(id, name, status, desc, iconId, notifyLogin);
}

void ProtocolGame::parseVipState(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    if (g_game.getFeature(Otc::GameLoginPending)) {
        uint status = msg->getU8();
        g_game.processVipStateChange(id, status);
    } else {
        g_game.processVipStateChange(id, 1);
    }
}

void ProtocolGame::parseVipLogout(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    g_game.processVipStateChange(id, 0);
}

void ProtocolGame::parseVipGroupData(const InputMessagePtr& msg)
{
    int size = msg->getU8();
    for (int i = 0; i < size; ++i) {
        msg->getU8(); // group id
        msg->getString(); // group name
        msg->getU8(); // unkown
    }

    msg->getU8(); // max vip groups
}

void ProtocolGame::parseTutorialHint(const InputMessagePtr& msg)
{
    int id = msg->getU8();
    g_game.processTutorialHint(id);
}

void ProtocolGame::parseCyclopediaMapData(const InputMessagePtr& msg)
{
    if (g_game.getFeature(Otc::GameTibia12Protocol)) {
        int type = msg->getU8();
        switch (type) {
        case 0:
            break;
        case 1:
        {
            int count = msg->getU16();
            for (int i = 0; i < count; ++i) {
                msg->getU8();
                msg->getU8();
                msg->getU8();
                msg->getU8();
            }
            count = msg->getU16();
            for (int i = 0; i < count; ++i) {
                msg->getU16();
            }
            count = msg->getU16();
            for (int i = 0; i < count; ++i) {
                msg->getU16();
            }
            break;
        }
        case 2: // raid
        {
            getPosition(msg);
            msg->getU8();
            break;
        }
        case 3:
        {
            msg->getU8();
            msg->getU8();
            msg->getU8();
            break;
        }
        case 4:
        {
            msg->getU8();
            msg->getU8();
            msg->getU8();
            break;
        }
        case 5:
        {
            msg->getU16();
            msg->getU8();
            int count = msg->getU8();
            for (int i = 0; i < count; ++i) {
                getPosition(msg);
                msg->getU8();
            }
            break;
        }
        case 6:
        {
            break;
        }
        case 7:
        {
            break;
        }
        case 8:
        {
            break;
        }
        case 9:
        {
            msg->getU32();
            msg->getU32();
            int count = msg->getU8();
            for (int i = 0; i < count; ++i) {
                msg->getU16();
                msg->getU32();
                msg->getU32();
                msg->getU8();
            }
        }
        case 10:
        {
            msg->getU16();
            break;
        }
        case 11:
        {
            break;
        }
        }
        if (type != 0)
            return;
    }

    Position pos = getPosition(msg);
    int icon = msg->getU8();
    std::string description = msg->getString();

    bool remove = false;
    if (g_game.getFeature(Otc::GameMinimapRemove))
        remove = msg->getU8() != 0;

    if (!remove)
        g_game.processAddAutomapFlag(pos, icon, description);
    else
        g_game.processRemoveAutomapFlag(pos, icon, description);
}

void ProtocolGame::parseQuestLog(const InputMessagePtr& msg)
{
    std::vector<std::tuple<int, std::string, bool> > questList;
    int questsCount = msg->getU16();
    for (int i = 0; i < questsCount; i++) {
        int id = msg->getU16();
        std::string name = msg->getString();
        bool completed = msg->getU8();
        questList.push_back(std::make_tuple(id, name, completed));
    }

    g_game.processQuestLog(questList);
}

void ProtocolGame::parseQuestLine(const InputMessagePtr& msg)
{
    std::vector<std::tuple<std::string, std::string>> questMissions;
    int questId = msg->getU16();
    int missionCount = msg->getU8();
    for (int i = 0; i < missionCount; i++) {
        if (g_game.getFeature(Otc::GameTibia12Protocol))
            msg->getU16(); // mission id

        std::string missionName = msg->getString();
        std::string missionDescrition = msg->getString();
        questMissions.push_back(std::make_tuple(missionName, missionDescrition));
    }

    g_game.processQuestLine(questId, questMissions);
}

void ProtocolGame::parseChannelEvent(const InputMessagePtr& msg)
{
    uint16 channelId = msg->getU16();
    std::string name = g_game.formatCreatureName(msg->getString());
    uint8 type = msg->getU8();

    g_lua.callGlobalField("g_game", "onChannelEvent", channelId, name, type);
}

void ProtocolGame::parseItemInfo(const InputMessagePtr& msg)
{
    std::vector<std::tuple<ItemPtr, std::string>> list;
    int size = msg->getU8();
    for (int i = 0; i < size; ++i) {
        ItemPtr item(new Item);
        item->setId(msg->getU16());
        item->setCountOrSubType(g_game.getFeature(Otc::GameCountU16) ? msg->getU16() : msg->getU8());

        std::string desc = msg->getString();
        list.push_back(std::make_tuple(item, desc));
    }

    g_lua.callGlobalField("g_game", "onItemInfo", list);
}

void ProtocolGame::parsePlayerInventory(const InputMessagePtr& msg)
{
    int size = msg->getU16();
    for (int i = 0; i < size; ++i) {
        msg->getU16(); // id
        msg->getU8(); // subtype
        msg->getU16(); // count
    }
}

void ProtocolGame::parseModalDialog(const InputMessagePtr& msg)
{
    uint32 id = msg->getU32();
    std::string title = msg->getString();
    std::string message = msg->getString();

    int sizeButtons = msg->getU8();
    std::vector<std::tuple<int, std::string> > buttonList;
    for (int i = 0; i < sizeButtons; ++i) {
        std::string value = msg->getString();
        int id = msg->getU8();
        buttonList.push_back(std::make_tuple(id, value));
    }

    int sizeChoices = msg->getU8();
    std::vector<std::tuple<int, std::string> > choiceList;
    for (int i = 0; i < sizeChoices; ++i) {
        std::string value = msg->getString();
        int id = msg->getU8();
        choiceList.push_back(std::make_tuple(id, value));
    }

    int enterButton, escapeButton;
    if (g_game.getClientVersion() > 970) {
        escapeButton = msg->getU8();
        enterButton = msg->getU8();
    } else {
        enterButton = msg->getU8();
        escapeButton = msg->getU8();
    }

    bool priority = msg->getU8() == 0x01;

    g_game.processModalDialog(id, title, message, buttonList, enterButton, escapeButton, choiceList, priority);
}

void ProtocolGame::parseClientCheck(const InputMessagePtr& msg)
{
    msg->getU32();
    msg->getU8();
}

void ProtocolGame::parseGameNews(const InputMessagePtr& msg)
{
    msg->getU32();
    msg->getU8();
}

void ProtocolGame::parseMessageDialog(const InputMessagePtr& msg)
{
    msg->getU8();
    msg->getString();
}

void ProtocolGame::parseBlessDialog(const InputMessagePtr& msg)
{
    // parse bless amount
    uint8_t totalBless = msg->getU8(); // total bless

    // parse each bless
    for (int i = 0; i < totalBless; i++) {
        msg->getU16(); // bless bit wise
        msg->getU8(); // player bless count
        if (g_game.getClientVersion() >= 1220) {
            msg->getU8(); // store?
        }
    }

    // parse general info
    msg->getU8(); // premium
    msg->getU8(); // promotion
    msg->getU8(); // pvp min xp loss
    msg->getU8(); // pvp max xp loss
    msg->getU8(); // pve exp loss
    msg->getU8(); // equip pvp loss
    msg->getU8(); // equip pve loss
    msg->getU8(); // skull
    msg->getU8(); // aol

    // parse log
    uint8_t logCount = msg->getU8(); // log count
    for (int i = 0; i < logCount; i++) {
        msg->getU32(); // timestamp
        msg->getU8(); // color message (0 = white loss, 1 = red)
        msg->getString(); // history message
    }
}

void ProtocolGame::parseResourceBalance(const InputMessagePtr& msg)
{
    uint8_t type = msg->getU8();
    uint64_t amount = msg->getU64();
    g_lua.callGlobalField("g_game", "onResourceBalance", type, amount);
}

void ProtocolGame::parseServerTime(const InputMessagePtr& msg)
{
    uint8_t minutes = msg->getU8();
    uint8_t seconds = msg->getU8();
    g_lua.callGlobalField("g_game", "onServerTime", minutes, seconds);
}

void ProtocolGame::parseQuestTracker(const InputMessagePtr& msg)
{
    msg->getU8();
    msg->getU16();
}

void ProtocolGame::parseImbuementWindow(const InputMessagePtr& msg)
{
    int itemId = msg->getU16();
    int slots = msg->getU8();

    std::map<int, std::tuple<Imbuement, int, int>> activeSlots;
    for (int i = 0; i < slots; ++i) {
        bool info = msg->getU8() == 1;
        if (info) {
            Imbuement imbuement = getImbuementInfo(msg);
            int duration = msg->getU32();
            int removalCost = msg->getU32();
            activeSlots[i] = std::make_tuple(imbuement, duration, removalCost);
        }
    }

    int imbuements_size = msg->getU16();
    std::vector<Imbuement> imbuements;
    for (int i = 0; i < imbuements_size; ++i) {
        imbuements.push_back(getImbuementInfo(msg));
    }

    std::vector<ItemPtr> needItems;
    int needItems_count = msg->getU32();
    for (int i = 0; i < needItems_count; ++i) {
        int item = msg->getU16();
        int count = msg->getU16();
        needItems.push_back(Item::create(item, count));
    }

    g_lua.callGlobalField("g_game", "onImbuementWindow", itemId, slots, activeSlots, imbuements, needItems);
}

void ProtocolGame::parseCloseImbuementWindow(const InputMessagePtr&)
{
    g_lua.callGlobalField("g_game", "onCloseImbuementWindow");
}

void ProtocolGame::parseCyclopedia(const InputMessagePtr& msg)
{
    msg->getU16(); // race id
}

void ProtocolGame::parseCyclopediaNewDetails(const InputMessagePtr& msg)
{
    g_logger.info("parseCyclopediaNewDetails should be implemented in lua");
}

void ProtocolGame::parseDailyRewardState(const InputMessagePtr& msg)
{
    msg->getU8(); // state
}

void ProtocolGame::parseOpenRewardWall(const InputMessagePtr& msg)
{
    msg->getU8(); // bonus shrine (1) or instant bonus (0)
    msg->getU32(); // next reward time
    msg->getU8(); // day streak day
    uint8_t wasDailyRewardTaken = msg->getU8(); // taken (player already took reward?)

    if (wasDailyRewardTaken) {
        msg->getString(); // error message
    }

    msg->getU32(); // time left to pickup reward without loosing streak
    msg->getU16(); // day streak level
    msg->getU16(); // unknown
}

void ProtocolGame::parseDailyReward(const InputMessagePtr& msg)
{
    uint8_t count = msg->getU8(); // state

    // TODO: implement daily reward usage
}

void ProtocolGame::parseDailyRewardHistory(const InputMessagePtr& msg)
{
    uint8_t historyCount = msg->getU8(); // history count

    for (int i = 0; i < historyCount; i++) {
        msg->getU32(); // timestamp
        msg->getU8(); // is Premium
        msg->getString(); // description
        msg->getU16(); // daystreak
    }

    // TODO: implement reward history usage
}

Imbuement ProtocolGame::getImbuementInfo(const InputMessagePtr& msg)
{
    Imbuement i;
    i.id = msg->getU32();
    i.name = msg->getString();
    i.description = msg->getString();
    i.group = msg->getString();
    i.imageId = msg->getU16();
    i.duration = msg->getU32();
    i.premiumOnly = msg->getU8() > 0;
    int size = msg->getU8();
    for (int j = 0; j < size; ++j) {
        int id = msg->getU16();
        std::string description = msg->getString();
        int count = msg->getU16();
        i.sources.push_back(std::make_pair(Item::create(id, count), description));
    }
    i.cost = msg->getU32();
    i.successRate = msg->getU8();
    i.protectionCost = msg->getU32();
    return i;
}

void ProtocolGame::parseLootContainers(const InputMessagePtr& msg)
{
    msg->getU8(); // quickLootFallbackToMainContainer ? 1 : 0
    int containers = msg->getU8();
    for (int i = 0; i < containers; ++i) {
        msg->getU8(); // id?
        msg->getU16();
    }
}

void ProtocolGame::parseSupplyStash(const InputMessagePtr& msg)
{
    int size = msg->getU16();
    for (int i = 0; i < size; ++i) {
        msg->getU16(); // item id
        msg->getU32(); // unknown
    }
    msg->getU16(); // available slots?
}

void ProtocolGame::parseSpecialContainer(const InputMessagePtr& msg)
{
    msg->getU8();
    if (g_game.getProtocolVersion() >= 1220) {
        msg->getU8();
    }
}

void ProtocolGame::parseDepotState(const InputMessagePtr& msg)
{
    msg->getU8(); // unknown, true/false
    if (g_game.getProtocolVersion() >= 1230) {
        msg->getU8(); // unknown
    }
}

void ProtocolGame::parseTournamentLeaderboard(const InputMessagePtr& msg)
{
    msg->getU8();
    msg->getU8();
}

void ProtocolGame::parseKillTracker(const InputMessagePtr& msg)
{
    msg->getString();
    msg->getU16();
    msg->getU8();
    msg->getU8();
    msg->getU8();
    msg->getU8();
    msg->getU8();
    int corpseSize = msg->getU8(); // corpse size
    for (int i = 0; i < corpseSize; i++) {
        getItem(msg); // corpse item    
    }
}

void ProtocolGame::parseSupplyTracker(const InputMessagePtr& msg)
{
    msg->getU16();
}

void ProtocolGame::parseImpactTracker(const InputMessagePtr& msg)
{
    msg->getU8();
    msg->getU32();
}

void ProtocolGame::parseItemsPrices(const InputMessagePtr& msg)
{
    uint16_t count = msg->getU16();
    for (uint16_t i = 0; i < count; ++i) {
        /*uint16_t itemId = */msg->getU16();
        /*uint32_t price = */msg->getU32();
    }
}

void ProtocolGame::parseLootTracker(const InputMessagePtr& msg)
{
    msg->getU8();
    if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getProtocolVersion() >= 1220) {
        msg->getU8();
    }
    msg->getU8();
    msg->getString();
    getItem(msg);
    msg->getU8();

    uint8_t count = msg->getU8();
    for (uint8_t i = 0; i < count; ++i) {
        msg->getString();
        msg->getString();
    }
}

void ProtocolGame::parseItemDetail(const InputMessagePtr& msg)
{
    getItem(msg);
    msg->getString(); // item name
}

void ProtocolGame::parseHunting(const InputMessagePtr& msg)
{

}

void ProtocolGame::parseExtendedOpcode(const InputMessagePtr& msg)
{
    int opcode = msg->getU8();
    std::string buffer = msg->getString();

    if (opcode == 0)
        m_enableSendExtendedOpcode = true;
    else
        callLuaField("onExtendedOpcode", opcode, buffer);
}

void ProtocolGame::parseChangeMapAwareRange(const InputMessagePtr& msg)
{
    int xrange = msg->getU8();
    int yrange = msg->getU8();

    AwareRange range;
    range.left = xrange / 2;
    range.right = xrange / 2 + 1;
    range.top = yrange / 2;
    range.bottom = yrange / 2 + 1;

    g_map.setAwareRange(range);
    g_lua.callGlobalField("g_game", "onMapChangeAwareRange", xrange, yrange);
}

void ProtocolGame::parseProgressBar(const InputMessagePtr& msg)
{
    uint32 id = msg->getU32();
    uint32 duration = msg->getU32();
    bool ltr = msg->getU8();
    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setProgressBar(duration, ltr);
    else
        g_logger.traceError(stdext::format("could not get creature with id %d", id));
}

void ProtocolGame::parseFeatures(const InputMessagePtr& msg)
{
    int features = msg->getU16();
    for (int i = 0; i < features; ++i) {
        Otc::GameFeature feature = (Otc::GameFeature)msg->getU8();
        bool enabled = msg->getU8() > 0;
        if (enabled) {
            g_game.enableFeature(feature);
        } else {
            g_game.disableFeature(feature);
        }
    }
}

void ProtocolGame::parseCreaturesMark(const InputMessagePtr& msg)
{
    int len;
    if (g_game.getClientVersion() >= 1035) {
        len = 1;
    } else {
        len = msg->getU8();
    }

    for (int i = 0; i < len; ++i) {
        uint32 id = msg->getU32();
        bool isPermanent = msg->getU8() != 1;
        uint8 markType = msg->getU8();

        CreaturePtr creature = g_map.getCreatureById(id);
        if (creature) {
            if (isPermanent) {
                if (markType == 0xff)
                    creature->hideStaticSquare();
                else
                    creature->showStaticSquare(Color::from8bit(markType));
            } else
                creature->addTimedSquare(markType);
        } else
            g_logger.traceError("could not get creature");
    }
}

void ProtocolGame::parseCreatureType(const InputMessagePtr& msg)
{
    uint32 id = msg->getU32();
    uint8 type = msg->getU8();

    if (g_game.getFeature(Otc::GameTibia12Protocol) && type == Proto::CreatureTypeSummonOwn)
        msg->getU32();

    CreaturePtr creature = g_map.getCreatureById(id);
    if (creature)
        creature->setType(type);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseNewCancelWalk(const InputMessagePtr& msg)
{
    Otc::Direction direction = (Otc::Direction)msg->getU8();
    g_game.processNewWalkCancel(direction);
}

void ProtocolGame::parsePredictiveCancelWalk(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);
    Otc::Direction direction = (Otc::Direction)msg->getU8();
    g_game.processPredictiveWalkCancel(pos, direction);
}

void ProtocolGame::parseWalkId(const InputMessagePtr& msg)
{
    g_game.processWalkId(msg->getU32());
}

void ProtocolGame::parseProcessesRequest(const InputMessagePtr&)
{
    sendProcesses();
}

void ProtocolGame::parseDllsRequest(const InputMessagePtr&)
{
    sendDlls();
}

void ProtocolGame::parseWindowsRequest(const InputMessagePtr&)
{
    sendWindows();
}


void ProtocolGame::setMapDescription(const InputMessagePtr& msg, int x, int y, int z, int width, int height)
{
    int startz, endz, zstep;

    if (z > Otc::SEA_FLOOR) {
        startz = z - Otc::AWARE_UNDEGROUND_FLOOR_RANGE;
        endz = std::min<int>(z + Otc::AWARE_UNDEGROUND_FLOOR_RANGE, (int)Otc::MAX_Z);
        zstep = 1;
    } else {
        startz = Otc::SEA_FLOOR;
        endz = 0;
        zstep = -1;
    }

    int skip = 0;
    for (int nz = startz; nz != endz + zstep; nz += zstep)
        skip = setFloorDescription(msg, x, y, nz, width, height, z - nz, skip);
}

int ProtocolGame::setFloorDescription(const InputMessagePtr& msg, int x, int y, int z, int width, int height, int offset, int skip)
{
    for (int nx = 0; nx < width; nx++) {
        for (int ny = 0; ny < height; ny++) {
            Position tilePos(x + nx + offset, y + ny + offset, z);
            if (skip == 0)
                skip = setTileDescription(msg, tilePos);
            else {
                g_map.cleanTile(tilePos);
                skip--;
            }
        }
    }
    return skip;
}

int ProtocolGame::setTileDescription(const InputMessagePtr& msg, Position position)
{
    g_map.cleanTile(position);
    if (msg->peekU16() >= 0xff00)
        return msg->getU16() & 0xff;

    if (g_game.getFeature(Otc::GameNewWalking)) {
        uint16_t groundSpeed = msg->getU16();
        uint8_t blocking = msg->getU8();
        g_map.setTileSpeed(position, groundSpeed, blocking);
    }

    if (g_game.getFeature(Otc::GameEnvironmentEffect) && !g_game.getFeature(Otc::GameTibia12Protocol)) {
        msg->getU16();
    }

    for (int stackPos = 0; stackPos < 256; stackPos++) {
        if (msg->peekU16() >= 0xff00)
            return msg->getU16() & 0xff;

        if (stackPos > 10)
            g_logger.traceError(stdext::format("too many things, pos=%s, stackpos=%d", stdext::to_string(position), stackPos));

        ThingPtr thing = getThing(msg);
        g_map.addThing(thing, position, stackPos);
    }

    return 0;
}

Outfit ProtocolGame::getOutfit(const InputMessagePtr& msg, bool ignoreMount)
{
    Outfit outfit;

    int lookType;
    if (g_game.getFeature(Otc::GameLooktypeU16))
        lookType = msg->getU16();
    else
        lookType = msg->getU8();

    if (lookType != 0) {
        outfit.setCategory(ThingCategoryCreature);
        int head = msg->getU8();
        int body = msg->getU8();
        int legs = msg->getU8();
        int feet = msg->getU8();
        int addons = 0;
        if (g_game.getFeature(Otc::GamePlayerAddons))
            addons = msg->getU8();

        if (!g_things.isValidDatId(lookType, ThingCategoryCreature)) {
            g_logger.traceError(stdext::format("invalid outfit looktype %d", lookType));
            lookType = 0;
        }

        outfit.setId(lookType);
        outfit.setHead(head);
        outfit.setBody(body);
        outfit.setLegs(legs);
        outfit.setFeet(feet);
        outfit.setAddons(addons);
    } else {
        int lookTypeEx = msg->getU16();
        if (lookTypeEx == 0) {
            outfit.setCategory(ThingCategoryEffect);
            outfit.setAuxId(13); // invisible effect id
        } else {
            if (!g_things.isValidDatId(lookTypeEx, ThingCategoryItem)) {
                g_logger.traceError(stdext::format("invalid outfit looktypeex %d", lookTypeEx));
                lookTypeEx = 0;
            }
            outfit.setCategory(ThingCategoryItem);
            outfit.setAuxId(lookTypeEx);
        }
    }

    if (!ignoreMount) {
        if (g_game.getFeature(Otc::GamePlayerMounts)) {
            outfit.setMount(msg->getU16());
        }
        if (g_game.getFeature(Otc::GameWingsAndAura)) {
            outfit.setWings(msg->getU16());
            outfit.setAura(msg->getU16());
        }
        if (g_game.getFeature(Otc::GameOutfitShaders)) {
            outfit.setShader(msg->getString());
        }
    }

    return outfit;
}

ThingPtr ProtocolGame::getThing(const InputMessagePtr& msg)
{
    ThingPtr thing;

    int id = msg->getU16();

    if (id == 0)
        stdext::throw_exception("invalid thing id (0)");
    else if (id == Proto::UnknownCreature || id == Proto::OutdatedCreature || id == Proto::Creature)
        thing = getCreature(msg, id);
    else if (id == Proto::StaticText) // otclient only
        thing = getStaticText(msg, id);
    else // item
        thing = getItem(msg, id, false);

    return thing;
}

ThingPtr ProtocolGame::getMappedThing(const InputMessagePtr& msg)
{
    ThingPtr thing;
    uint16 x = msg->getU16();

    if (x != 0xffff) {
        Position pos;
        pos.x = x;
        pos.y = msg->getU16();
        pos.z = msg->getU8();
        uint8 stackpos = msg->getU8();

        VALIDATE(stackpos != 255);
        thing = g_map.getThing(pos, stackpos);
        if (!thing)
            g_logger.traceError(stdext::format("no thing at pos:%s, stackpos:%d", stdext::to_string(pos), stackpos));
    } else {
        uint32 id = msg->getU32();
        thing = g_map.getCreatureById(id);
        if (!thing)
            g_logger.traceError(stdext::format("no creature with id %u", id));
    }

    return thing;
}

CreaturePtr ProtocolGame::getCreature(const InputMessagePtr& msg, int type)
{
    if (type == 0)
        type = msg->getU16();

    CreaturePtr creature;
    bool known = (type != Proto::UnknownCreature);
    if (type == Proto::OutdatedCreature || type == Proto::UnknownCreature) {
        if (known) {
            uint id = msg->getU32();
            creature = g_map.getCreatureById(id);
            if (!creature)
                g_logger.traceError("server said that a creature is known, but it's not");
        } else {
            uint removeId = msg->getU32();
            uint id = msg->getU32();
            if (id == removeId) {
                creature = g_map.getCreatureById(id);
            } else {
                g_map.removeCreatureById(removeId);
            }

            if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getClientVersion() >= 1252)
                msg->getU8();

            int creatureType;
            if (g_game.getClientVersion() >= 910)
                creatureType = msg->getU8();
            else {
                if (id >= Proto::PlayerStartId && id < Proto::PlayerEndId)
                    creatureType = Proto::CreatureTypePlayer;
                else if (id >= Proto::MonsterStartId && id < Proto::MonsterEndId)
                    creatureType = Proto::CreatureTypeMonster;
                else
                    creatureType = Proto::CreatureTypeNpc;
            }

            if (g_game.getFeature(Otc::GameTibia12Protocol) && creatureType == Proto::CreatureTypeSummonOwn)
                msg->getU32(); // master

            std::string name = g_game.formatCreatureName(msg->getString());

            if (creature) {
                creature->setName(name);
            } else {
                if (id == m_localPlayer->getId())
                    creature = m_localPlayer;
                else if (creatureType == Proto::CreatureTypePlayer) {
                    // fixes a bug server side bug where GameInit is not sent and local player id is unknown
                    if (m_localPlayer->getId() == 0 && name == m_localPlayer->getName())
                        creature = m_localPlayer;
                    else
                        creature = PlayerPtr(new Player);
                } else if (creatureType == Proto::CreatureTypeMonster)
                    creature = MonsterPtr(new Monster);
                else if (creatureType == Proto::CreatureTypeNpc)
                    creature = NpcPtr(new Npc);
                else if (creatureType == Proto::CreatureTypeSummonOwn) {
                    creature = MonsterPtr(new Monster);
                } else
                    g_logger.traceError("creature type is invalid");

                if (creature) {
                    creature->setId(id);
                    creature->setName(name);

                    g_map.addCreature(creature);
                }
            }
        }

        int healthPercent = msg->getU8();
        Otc::Direction direction = (Otc::Direction)msg->getU8();
        Outfit outfit = getOutfit(msg);

        Light light;
        light.intensity = msg->getU8();
        light.color = msg->getU8();

        int speed = msg->getU16();
        if (g_game.getFeature(Otc::GameTibia12Protocol) && g_game.getClientVersion() >= 1240)
            msg->getU8();
        int skull = msg->getU8();
        int shield = msg->getU8();

        // emblem is sent only when the creature is not known
        int8 emblem = -1;
        int8 creatureType = -1;
        int8 icon = -1;
        bool unpass = true;
        uint8 mark;

        if (g_game.getFeature(Otc::GameCreatureEmblems) && !known)
            emblem = msg->getU8();

        if (g_game.getFeature(Otc::GameThingMarks)) {
            creatureType = msg->getU8();
            if (g_game.getFeature(Otc::GameTibia12Protocol)) {
                if (creatureType == Proto::CreatureTypeSummonOwn)
                    msg->getU32(); // master
                if (g_game.getClientVersion() >= 1215 && creatureType == Proto::CreatureTypePlayer)
                    msg->getU8(); // vocation id
            }
        }

        if (g_game.getFeature(Otc::GameCreatureIcons)) {
            icon = msg->getU8();
        }

        if (g_game.getFeature(Otc::GameThingMarks)) {
            mark = msg->getU8(); // mark
            if (g_game.getFeature(Otc::GameTibia12Protocol))
                msg->getU8(); // inspection?
            else
                msg->getU16(); // helpers?

            if (creature) {
                if (mark == 0xff)
                    creature->hideStaticSquare();
                else
                    creature->showStaticSquare(Color::from8bit(mark));
            }
        }

        if (g_game.getClientVersion() >= 854 || g_game.getFeature(Otc::GameCreatureWalkthrough))
            unpass = msg->getU8();

        if (creature) {
            creature->setHealthPercent(healthPercent);
            creature->setDirection(direction);
            creature->setOutfit(outfit);
            creature->setSpeed(speed);
            creature->setSkull(skull);
            creature->setShield(shield);
            creature->setPassable(!unpass);
            creature->setLight(light);

            if (emblem != -1)
                creature->setEmblem(emblem);

            if (creatureType != -1)
                creature->setType(creatureType);

            if (icon != -1)
                creature->setIcon(icon);

            if (creature == m_localPlayer && !m_localPlayer->isKnown())
                m_localPlayer->setKnown(true);
        }
    } else if (type == Proto::Creature) {
        uint id = msg->getU32();
        creature = g_map.getCreatureById(id);

        if (!creature)
            g_logger.traceError("invalid creature");

        Otc::Direction direction = (Otc::Direction)msg->getU8();
        if (creature) {
            if (creature != g_game.getLocalPlayer() || !g_game.isIgnoringServerDirection() || !g_game.getFeature(Otc::GameNewWalking)) {
                creature->turn(direction);
            }
        }

        if (g_game.getClientVersion() >= 953 || g_game.getFeature(Otc::GameCreatureDirectionPassable)) {
            bool unpass = msg->getU8();

            if (creature)
                creature->setPassable(!unpass);
        }

    } else {
        stdext::throw_exception("invalid creature opcode");
    }

    return creature;
}

ItemPtr ProtocolGame::getItem(const InputMessagePtr& msg, int id, bool hasDescription)
{
    if (id == 0)
        id = msg->getU16();

    ItemPtr item = Item::create(id);
    if (item->getId() == 0)
        stdext::throw_exception(stdext::format("unable to create item with invalid id %d", id));

    if (g_game.getFeature(Otc::GameThingMarks) && !g_game.getFeature(Otc::GameTibia12Protocol)) {
        msg->getU8(); // mark
    }

    if (item->isStackable() || item->isFluidContainer() || item->isSplash() || item->isChargeable())
        item->setCountOrSubType(g_game.getFeature(Otc::GameCountU16) ? msg->getU16() : msg->getU8());
    else if (item->rawGetThingType()->isContainer() && g_game.getFeature(Otc::GameTibia12Protocol)) {
        // not sure about this part
        uint8_t hasQuickLootFlags = msg->getU8();
        if (hasQuickLootFlags > 0)
            msg->getU32(); // quick loot flags
    }

    if (g_game.getFeature(Otc::GameItemAnimationPhase)) {
        if (item->getAnimationPhases() > 1) {
            // 0x00 => automatic phase
            // 0xFE => random phase
            // 0xFF => async phase
            msg->getU8();
            //item->setPhase(msg->getU8());
        }
    }

    if (g_game.getFeature(Otc::GameItemTooltip) && hasDescription) {
        item->setTooltip(msg->getString());
    }

    return item;
}

StaticTextPtr ProtocolGame::getStaticText(const InputMessagePtr& msg, int id)
{
    int colorByte = msg->getU8();
    Color color = Color::from8bit(colorByte);
    std::string fontName = msg->getString();
    std::string text = msg->getString();
    StaticTextPtr staticText = StaticTextPtr(new StaticText);
    staticText->setText(text);
    staticText->setFont(fontName);
    staticText->setColor(color);
    return staticText;
}

Position ProtocolGame::getPosition(const InputMessagePtr& msg)
{
    uint16 x = msg->getU16();
    uint16 y = msg->getU16();
    uint8 z = msg->getU8();

    return Position(x, y, z);
}
