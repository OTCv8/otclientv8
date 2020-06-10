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

#include "map.h"
#include "game.h"
#include "localplayer.h"
#include "tile.h"
#include "item.h"
#include "missile.h"
#include "statictext.h"
#include "mapview.h"
#include "minimap.h"

#include <framework/core/asyncdispatcher.h>
#include <framework/core/eventdispatcher.h>
#include <framework/core/application.h>
#include <framework/util/extras.h>
#include <set>

Map g_map;
TilePtr Map::m_nulltile = nullptr;

void Map::init()
{
    resetAwareRange();
    m_animationFlags |= Animation_Show;
}

void Map::terminate()
{
    clean();
}

void Map::addMapView(const MapViewPtr& mapView)
{
    m_mapViews.push_back(mapView);
}

void Map::removeMapView(const MapViewPtr& mapView)
{
    auto it = std::find(m_mapViews.begin(), m_mapViews.end(), mapView);
    if(it != m_mapViews.end())
        m_mapViews.erase(it);
}

void Map::notificateTileUpdate(const Position& pos, bool updateMinimap)
{
    if(!pos.isMapPosition())
        return;

    for(const MapViewPtr& mapView : m_mapViews)
        mapView->onTileUpdate(pos);

    if (!updateMinimap)
        return;

    if (!g_game.getFeature(Otc::GameMinimapLimitedToSingleFloor) || (m_centralPosition.z == pos.z)) {
        g_minimap.updateTile(pos, getTile(pos));
    }
}

void Map::requestVisibleTilesCacheUpdate() {
    for (const MapViewPtr& mapView : m_mapViews)
        mapView->requestVisibleTilesCacheUpdate();
}

void Map::clean()
{
    cleanDynamicThings();

    for(int i=0;i<=Otc::MAX_Z;++i)
        m_tileBlocks[i].clear();

    m_waypoints.clear();

    g_towns.clear();
    g_houses.clear();
    g_creatures.clearSpawns();
    m_tilesRect = Rect(65534, 65534, 0, 0);
}

void Map::cleanDynamicThings()
{
    for(const auto& pair : m_knownCreatures) {
        const CreaturePtr& creature = pair.second;
        removeThing(creature);
    }
    m_knownCreatures.clear();

    for(int i=0;i<=Otc::MAX_Z;++i)
        m_floorMissiles[i].clear();

    cleanTexts();
}

void Map::cleanTexts()
{
    m_animatedTexts.clear();
    m_staticTexts.clear();
}

void Map::addThing(const ThingPtr& thing, const Position& pos, int stackPos)
{
    if(!thing)
        return;

    if(thing->isItem() || thing->isCreature() || thing->isEffect()) {
        const TilePtr& tile = getOrCreateTile(pos);
        if(tile)
            tile->addThing(thing, stackPos);
    } else {
        if(thing->isMissile()) {
            m_floorMissiles[pos.z].push_back(thing->static_self_cast<Missile>());
        } else if(thing->isAnimatedText()) {
            // this code will stack animated texts of the same color
            AnimatedTextPtr animatedText = thing->static_self_cast<AnimatedText>();

            AnimatedTextPtr prevAnimatedText;
            bool merged = false;
            for(auto other : m_animatedTexts) {
                if(other->getPosition() == pos) {
                    prevAnimatedText = other;
                    if(other->merge(animatedText)) {
                        merged = true;
                        break;
                    }
                }
            }
            if(!merged) {
                m_animatedTexts.push_back(animatedText);
            }
        } else if(thing->isStaticText()) {
            StaticTextPtr staticText = thing->static_self_cast<StaticText>();

            bool mustAdd = true;
            for(auto other : m_staticTexts) {
                // try to combine messages
                if(other->getPosition() == pos && other->addColoredMessage(staticText->getName(), staticText->getMessageMode(), staticText->getFirstMessage())) {
                    mustAdd = false;
                    break;
                }
            }

            if(mustAdd)
                m_staticTexts.push_back(staticText);
            else
                return;
        }

        thing->setPosition(pos);
        thing->onAppear();

        if (thing->isMissile()) {
            g_lua.callGlobalField("g_map", "onMissle", thing);
        } else if (thing->isAnimatedText()) {
            AnimatedTextPtr animatedText = thing->static_self_cast<AnimatedText>();
            g_lua.callGlobalField("g_map", "onAnimatedText", thing, animatedText->getText());
        } else if (thing->isStaticText()) {
            StaticTextPtr staticText = thing->static_self_cast<StaticText>();
            g_lua.callGlobalField("g_map", "onStaticText", thing, staticText->getText());
        }
    } 

    notificateTileUpdate(pos, thing->isItem());
}

void Map::setTileSpeed(const Position& pos, uint16_t speed, uint8_t blocking) {
    const TilePtr& tile = getOrCreateTile(pos);
    if (tile)
        tile->setSpeed(speed, blocking);
}

ThingPtr Map::getThing(const Position& pos, int stackPos)
{
    if(TilePtr tile = getTile(pos))
        return tile->getThing(stackPos);
    return nullptr;
}

bool Map::removeThing(const ThingPtr& thing)
{
    if(!thing)
        return false;

    bool ret = false;
    if(thing->isMissile()) {
        MissilePtr missile = thing->static_self_cast<Missile>();
        int z = missile->getPosition().z;
        auto it = std::find(m_floorMissiles[z].begin(), m_floorMissiles[z].end(), missile);
        if(it != m_floorMissiles[z].end()) {
            m_floorMissiles[z].erase(it);
            ret = true;
        }
    } else if(thing->isAnimatedText()) {
        AnimatedTextPtr animatedText = thing->static_self_cast<AnimatedText>();
        auto it = std::find(m_animatedTexts.begin(), m_animatedTexts.end(), animatedText);
        if(it != m_animatedTexts.end()) {
            m_animatedTexts.erase(it);
            ret = true;
        }
    } else if(thing->isStaticText()) {
        StaticTextPtr staticText = thing->static_self_cast<StaticText>();
        auto it = std::find(m_staticTexts.begin(), m_staticTexts.end(), staticText);
        if(it != m_staticTexts.end()) {
            m_staticTexts.erase(it);
            ret = true;
        }
    } else if(const TilePtr& tile = thing->getTile())
        ret = tile->removeThing(thing);

    notificateTileUpdate(thing->getPosition(), thing->isItem());
    return ret;
}

bool Map::removeThingByPos(const Position& pos, int stackPos)
{
    if(TilePtr tile = getTile(pos))
        return removeThing(tile->getThing(stackPos));
    return false;
}

void Map::colorizeThing(const ThingPtr& thing, const Color& color)
{
    if(!thing)
        return;

    if(thing->isItem())
        thing->static_self_cast<Item>()->setColor(color);
    else if(thing->isCreature()) {
        const TilePtr& tile = thing->getTile();
        VALIDATE(tile);

        const ThingPtr& topThing = tile->getTopThing();
        VALIDATE(topThing);

        topThing->static_self_cast<Item>()->setColor(color);
    }
}

void Map::removeThingColor(const ThingPtr& thing)
{
    if(!thing)
        return;

    if(thing->isItem())
        thing->static_self_cast<Item>()->setColor(Color::alpha);
    else if(thing->isCreature()) {
        const TilePtr& tile = thing->getTile();
        VALIDATE(tile);

        const ThingPtr& topThing = tile->getTopThing();
        VALIDATE(topThing);

        topThing->static_self_cast<Item>()->setColor(Color::alpha);
    }
}

StaticTextPtr Map::getStaticText(const Position& pos)
{
    for(auto staticText : m_staticTexts) {
        // try to combine messages
        if(staticText->getPosition() == pos)
            return staticText;
    }
    return nullptr;
}

const TilePtr& Map::createTile(const Position& pos)
{
    if(!pos.isMapPosition())
        return m_nulltile;
    if(pos.x < m_tilesRect.left())
        m_tilesRect.setLeft(pos.x);
    if(pos.y < m_tilesRect.top())
        m_tilesRect.setTop(pos.y);
    if(pos.x > m_tilesRect.right())
        m_tilesRect.setRight(pos.x);
    if(pos.y > m_tilesRect.bottom())
        m_tilesRect.setBottom(pos.y);
    TileBlock& block = m_tileBlocks[pos.z][getBlockIndex(pos)];
    return block.create(pos);
}

template <typename... Items>
const TilePtr& Map::createTileEx(const Position& pos, const Items&... items)
{
    if(!pos.isValid())
        return m_nulltile;
    const TilePtr& tile = getOrCreateTile(pos);
    auto vec = {items...};
    for(auto it : vec)
        addThing(it, pos);

    return tile;
}

const TilePtr& Map::getOrCreateTile(const Position& pos)
{
    if(!pos.isMapPosition())
        return m_nulltile;
    if(pos.x < m_tilesRect.left())
        m_tilesRect.setLeft(pos.x);
    if(pos.y < m_tilesRect.top())
        m_tilesRect.setTop(pos.y);
    if(pos.x > m_tilesRect.right())
        m_tilesRect.setRight(pos.x);
    if(pos.y > m_tilesRect.bottom())
        m_tilesRect.setBottom(pos.y);
    TileBlock& block = m_tileBlocks[pos.z][getBlockIndex(pos)];
    return block.getOrCreate(pos);
}

const TilePtr& Map::getTile(const Position& pos)
{
    if(!pos.isMapPosition())
        return m_nulltile;
    auto it = m_tileBlocks[pos.z].find(getBlockIndex(pos));
    if(it != m_tileBlocks[pos.z].end())
        return it->second.get(pos);
    return m_nulltile;
}

const TileList Map::getTiles(int floor/* = -1*/)
{
    TileList tiles;
    if(floor > Otc::MAX_Z) {
        return tiles;
    }
    else if(floor < 0) {
        // Search all floors
        for(uint8_t z = 0; z <= Otc::MAX_Z; ++z) {
            for(const auto& pair : m_tileBlocks[z]) {
                const TileBlock& block = pair.second;
                for(const TilePtr& tile : block.getTiles()) {
                    if(tile != nullptr)
                        tiles.push_back(tile);
                }
            }
        }
    }
    else {
        for(const auto& pair : m_tileBlocks[floor]) {
            const TileBlock& block = pair.second;
            for(const TilePtr& tile : block.getTiles()) {
                if(tile != nullptr)
                    tiles.push_back(tile);
            }
        }
    }
    return tiles;
}

void Map::cleanTile(const Position& pos)
{
    if(!pos.isMapPosition())
        return;
    auto it = m_tileBlocks[pos.z].find(getBlockIndex(pos));
    if(it != m_tileBlocks[pos.z].end()) {
        TileBlock& block = it->second;
        if(const TilePtr& tile = block.get(pos)) {
            tile->clean();
            if(tile->canErase())
                block.remove(pos);

            notificateTileUpdate(pos, false);
        }
    }
    for(auto it = m_staticTexts.begin();it != m_staticTexts.end();) {
        const StaticTextPtr& staticText = *it;
        if(staticText->getPosition() == pos && staticText->getMessageMode() == Otc::MessageNone)
            it = m_staticTexts.erase(it);
        else
            ++it;
    }

    if (!g_game.getFeature(Otc::GameMinimapLimitedToSingleFloor) || (m_centralPosition.z == pos.z)) {
        g_minimap.updateTile(pos, getTile(pos));
    }
}

void Map::setShowZone(tileflags_t zone, bool show)
{
    if(show)
        m_zoneFlags |= (uint32)zone;
    else
        m_zoneFlags &= ~(uint32)zone;
}

void Map::setShowZones(bool show)
{
    if(!show)
        m_zoneFlags = 0;
    else if(m_zoneFlags == 0)
        m_zoneFlags = TILESTATE_HOUSE | TILESTATE_PROTECTIONZONE;
}

void Map::setZoneColor(tileflags_t zone, const Color& color)
{
    if((m_zoneFlags & zone) == zone)
        m_zoneColors[zone] = color;
}

Color Map::getZoneColor(tileflags_t flag)
{
    auto it = m_zoneColors.find(flag);
    if(it == m_zoneColors.end())
        return Color::alpha;
    return it->second;
}

void Map::setForceShowAnimations(bool force)
{
    if(force) {
        if(!(m_animationFlags & Animation_Force))
            m_animationFlags |= Animation_Force;
    } else
        m_animationFlags &= ~Animation_Force;
}

bool Map::isForcingAnimations()
{
    return (m_animationFlags & Animation_Force) == Animation_Force;
}

bool Map::isShowingAnimations()
{
    return (m_animationFlags & Animation_Show) == Animation_Show;
}

void Map::setShowAnimations(bool show)
{
    if(show) {
        if(!(m_animationFlags & Animation_Show))
            m_animationFlags |= Animation_Show;
    } else
        m_animationFlags &= ~Animation_Show;
}

std::map<Position, ItemPtr> Map::findItemsById(uint16 clientId, uint32 max)
{
    std::map<Position, ItemPtr> ret;
    uint32 count = 0;
    for(uint8_t z = 0; z <= Otc::MAX_Z; ++z) {
        for(const auto& pair : m_tileBlocks[z]) {
            const TileBlock& block = pair.second;
            for(const TilePtr& tile : block.getTiles()) {
                if(unlikely(!tile || tile->isEmpty()))
                    continue;
                for(const ItemPtr& item : tile->getItems()) {
                    if(item->getId() == clientId) {
                        ret.insert(std::make_pair(tile->getPosition(), item));
                        if(++count >= max)
                            break;
                    }
                }
            }
        }
    }

    return ret;
}

void Map::addCreature(const CreaturePtr& creature)
{
    m_knownCreatures[creature->getId()] = creature;
}

CreaturePtr Map::getCreatureById(uint32 id)
{
    auto it = m_knownCreatures.find(id);
    if(it == m_knownCreatures.end())
        return nullptr;
    return it->second;
}

void Map::removeCreatureById(uint32 id)
{
    if(id == 0)
        return;

    auto it = m_knownCreatures.find(id);
    if(it != m_knownCreatures.end())
        m_knownCreatures.erase(it);
}

void Map::removeUnawareThings()
{
    // remove creatures from tiles that we are not aware of anymore
    for(const auto& pair : m_knownCreatures) {
        const CreaturePtr& creature = pair.second;
        if(!isAwareOfPosition(creature->getPosition()))
            removeThing(creature);
    }

    // remove static texts from tiles that we are not aware anymore
    for(auto it = m_staticTexts.begin(); it != m_staticTexts.end();) {
        const StaticTextPtr& staticText = *it;
        if(staticText->getMessageMode() == Otc::MessageNone && !isAwareOfPosition(staticText->getPosition()))
            it = m_staticTexts.erase(it);
        else
            ++it;
    }

    bool extended = g_game.getFeature(Otc::GameBiggerMapCache);
    if(!g_game.getFeature(Otc::GameKeepUnawareTiles)) {
        // remove tiles that we are not aware anymore
        for(int z = 0; z <= Otc::MAX_Z; ++z) {
            auto& tileBlocks = m_tileBlocks[z];
            for(auto it = tileBlocks.begin(); it != tileBlocks.end();) {
                TileBlock& block = (*it).second;
                bool blockEmpty = true;
                for(const TilePtr& tile : block.getTiles()) {
                    if(!tile)
                        continue;

                    const Position& pos = tile->getPosition();

                    if(!isAwareOfPositionForClean(pos, extended))
                        block.remove(pos);
                    else
                        blockEmpty = false;
                }

                if(blockEmpty)
                    it = tileBlocks.erase(it);
                else
                    ++it;
            }
        }
    }
}

void Map::setCentralPosition(const Position& centralPosition)
{
    if(m_centralPosition == centralPosition)
        return;

    m_centralPosition = centralPosition;

    removeUnawareThings();

    // this fixes local player position when the local player is removed from the map,
    // the local player is removed from the map when there are too many creatures on his tile,
    // so there is no enough stackpos to the server send him
    g_dispatcher.addEvent([this] {
        LocalPlayerPtr localPlayer = g_game.getLocalPlayer();
        if(!localPlayer || localPlayer->getPosition() == m_centralPosition)
            return;
        TilePtr tile = localPlayer->getTile();
        if(tile && tile->hasThing(localPlayer))
            return;

        Position oldPos = localPlayer->getPosition();
        Position pos = m_centralPosition;
        if(oldPos != pos) {
            if(!localPlayer->isRemoved())
                localPlayer->onDisappear();
            localPlayer->setPosition(pos);
            localPlayer->onAppear();
            g_logger.debug("forced player position update");
        }
    });

    for(const MapViewPtr& mapView : m_mapViews)
        mapView->onMapCenterChange(centralPosition);
}

std::vector<CreaturePtr> Map::getSightSpectators(const Position& centerPos, bool multiFloor)
{
    return getSpectatorsInRangeEx(centerPos, multiFloor, m_awareRange.left - 1, m_awareRange.right - 2, m_awareRange.top - 1, m_awareRange.bottom - 2);
}

std::vector<CreaturePtr> Map::getSpectators(const Position& centerPos, bool multiFloor)
{
    return getSpectatorsInRangeEx(centerPos, multiFloor, m_awareRange.left, m_awareRange.right, m_awareRange.top, m_awareRange.bottom);
}

std::vector<CreaturePtr> Map::getSpectatorsInRange(const Position& centerPos, bool multiFloor, int xRange, int yRange)
{
    return getSpectatorsInRangeEx(centerPos, multiFloor, xRange, xRange, yRange, yRange);
}

std::vector<CreaturePtr> Map::getSpectatorsInRangeEx(const Position& centerPos, bool multiFloor, int minXRange, int maxXRange, int minYRange, int maxYRange)
{
    int minZRange = 0;
    int maxZRange = 0;
    std::vector<CreaturePtr> creatures;

    if(multiFloor) {
        minZRange = 0;
        maxZRange = Otc::MAX_Z;
    }

    //TODO: optimize
    //TODO: get creatures from other floors corretly
    //TODO: delivery creatures in distance order

    for(int iz=-minZRange; iz<=maxZRange; ++iz) {
        for(int iy=-minYRange; iy<=maxYRange; ++iy) {
            for(int ix=-minXRange; ix<=maxXRange; ++ix) {
                TilePtr tile = getTile(centerPos.translated(ix,iy,iz));
                if(!tile)
                    continue;

                auto tileCreatures = tile->getCreatures();
                creatures.insert(creatures.end(), tileCreatures.rbegin(), tileCreatures.rend());
            }
        }
    }

    return creatures;
}

bool Map::isLookPossible(const Position& pos)
{
    TilePtr tile = getTile(pos);
    return tile && tile->isLookPossible();
}

bool Map::isCovered(const Position& pos, int firstFloor)
{
    // check for tiles on top of the postion
    Position tilePos = pos;
    while(tilePos.coveredUp() && tilePos.z >= firstFloor) {
        TilePtr tile = getTile(tilePos);
        // the below tile is covered when the above tile has a full ground
        if(tile && tile->isFullGround())
            return true;
    }
    return false;
}

bool Map::isCompletelyCovered(const Position& pos, int firstFloor)
{
    const TilePtr& checkTile = getTile(pos);
    Position tilePos = pos;
    while(tilePos.coveredUp() && tilePos.z >= firstFloor) {
        bool covered = true;
        bool done = false;
        // check in 2x2 range tiles that has no transparent pixels
        for(int x=0;x<2 && !done;++x) {
            for(int y=0;y<2 && !done;++y) {
                const TilePtr& tile = getTile(tilePos.translated(-x, -y));
                if(!tile || !tile->isFullyOpaque()) {
                    covered = false;
                    done = true;
                } else if(x==0 && y==0 && (!checkTile || checkTile->isSingleDimension())) {
                    done = true;
                }
            }
        }
        if(covered)
            return true;
    }
    return false;
}

bool Map::isAwareOfPosition(const Position& pos, bool extended)
{
    if ((pos.z < getFirstAwareFloor() || pos.z > getLastAwareFloor()) && !extended)
        return false;

    Position groundedPos = pos;
    while (groundedPos.z != m_centralPosition.z) {
        if (groundedPos.z > m_centralPosition.z) {
            if (groundedPos.x == 65535 || groundedPos.y == 65535) // When pos == 65535,65535,15 we cant go up to 65536,65536,14
                break;
            groundedPos.coveredUp();
        } else {
            if (groundedPos.x == 0 || groundedPos.y == 0) // When pos == 0,0,0 we cant go down to -1,-1,1
                break;
            groundedPos.coveredDown();
        }
    }

    if (extended) {
        return m_centralPosition.isInRange(groundedPos, m_awareRange.left * 2,
                                           m_awareRange.right * 2,
                                           m_awareRange.top * 2,
                                           m_awareRange.bottom * 2);
    }
    return m_centralPosition.isInRange(groundedPos, m_awareRange.left,
                                       m_awareRange.right,
                                       m_awareRange.top,
                                       m_awareRange.bottom);
}

bool Map::isAwareOfPositionForClean(const Position& pos, bool extended)
{
    if ((pos.z < getFirstAwareFloor() || pos.z > getLastAwareFloor()) && !extended)
        return false;

    Position groundedPos = pos;
    while (groundedPos.z != m_centralPosition.z) {
        if (groundedPos.z > m_centralPosition.z) {
            if (groundedPos.x == 65535 || groundedPos.y == 65535) // When pos == 65535,65535,15 we cant go up to 65536,65536,14
                break;
            groundedPos.coveredUp();
        } else {
            if (groundedPos.x == 0 || groundedPos.y == 0) // When pos == 0,0,0 we cant go down to -1,-1,1
                break;
            groundedPos.coveredDown();
        }
    }

    if (extended) {
        return m_centralPosition.isInRange(groundedPos, m_awareRange.left * 4,
                                           m_awareRange.right * 4,
                                           m_awareRange.top * 4,
                                           m_awareRange.bottom * 4);
    }
    return m_centralPosition.isInRange(groundedPos, m_awareRange.left + 1,
                                       m_awareRange.right + 1,
                                       m_awareRange.top + 1,
                                       m_awareRange.bottom + 1);
}

void Map::setAwareRange(const AwareRange& range)
{
    m_awareRange = range;
    removeUnawareThings();
}

void Map::resetAwareRange()
{
    AwareRange range;
    range.left = 8;
    range.top = 6;
    range.bottom = 7;
    range.right = 9;
    setAwareRange(range);
}

int Map::getFirstAwareFloor()
{
    if(m_centralPosition.z > Otc::SEA_FLOOR)
        return m_centralPosition.z-Otc::AWARE_UNDEGROUND_FLOOR_RANGE;
    else
        return 0;
}

int Map::getLastAwareFloor()
{
    if(m_centralPosition.z > Otc::SEA_FLOOR)
        return std::min<int>(m_centralPosition.z+Otc::AWARE_UNDEGROUND_FLOOR_RANGE, (int)Otc::MAX_Z);
    else
        return Otc::SEA_FLOOR;
}

std::tuple<std::vector<Otc::Direction>, Otc::PathFindResult> Map::findPath(const Position& startPos, const Position& goalPos, int maxComplexity, int flags)
{
    // pathfinding using A* search algorithm (otclientv8 note: it's dijkstra algorithm)
    // as described in http://en.wikipedia.org/wiki/A*_search_algorithm

    struct SNode {
        SNode(const Position& pos) : cost(0), totalCost(0), pos(pos), prev(nullptr), dir(Otc::InvalidDirection) { }
        float cost;
        float totalCost;
        Position pos;
        SNode *prev;
        Otc::Direction dir;
    };

    struct LessNode {
        bool operator()(std::pair<SNode*, float> a, std::pair<SNode*, float> b) const {
            return b.second < a.second;
        }
    };

    std::tuple<std::vector<Otc::Direction>, Otc::PathFindResult> ret;
    std::vector<Otc::Direction>& dirs = std::get<0>(ret);
    Otc::PathFindResult& result = std::get<1>(ret);

    result = Otc::PathFindResultNoWay;

    if(startPos == goalPos) {
        result = Otc::PathFindResultSamePosition;
        return ret;
    }

    if(startPos.z != goalPos.z) {
        result = Otc::PathFindResultImpossible;
        return ret;
    }

    // check the goal pos is walkable
    if(g_map.isAwareOfPosition(goalPos)) {
        const TilePtr goalTile = getTile(goalPos);
        if(!goalTile || (!goalTile->isWalkable(flags & Otc::PathFindIgnoreCreatures))) {
            return ret;
        }
    }
    else {
        const MinimapTile& goalTile = g_minimap.getTile(goalPos);
        if(goalTile.hasFlag(MinimapTileNotWalkable)) {
            return ret;
        }
    }

    std::unordered_map<Position, SNode*, PositionHasher> nodes;
    std::priority_queue<std::pair<SNode*, float>, std::vector<std::pair<SNode*, float>>, LessNode> searchList;

    // hidden code
    
    for(auto it : nodes)
        delete it.second;

    return ret;
}

PathFindResult_ptr Map::newFindPath(const Position& start, const Position& goal, std::shared_ptr<std::list<Node*>> visibleNodes) {
    auto ret = std::make_shared<PathFindResult>();
    ret->start = start;
    ret->destination = goal;

    if (start == goal) {
        ret->status = Otc::PathFindResultSamePosition;
        return ret;
    }
    if (goal.z != start.z) {
        return ret;
    }

    struct LessNode {
        bool operator()(Node* a, Node* b) const {
            return b->totalCost < a->totalCost;
        }
    };

    std::unordered_map<Position, Node*, PositionHasher> nodes;
    std::priority_queue<Node*, std::vector<Node*>, LessNode> searchList;

    if (visibleNodes) {
        for (auto& node : *visibleNodes)
            nodes.emplace(node->pos, node);
    }

    Node* initNode = new Node{ 1, 0, start, nullptr, 0, 0 };
    nodes[start] = initNode;
    searchList.push(initNode);

    int limit = 50000;
    float distance = start.distance(goal);

    // hidden code

    return ret;
}

void Map::findPathAsync(const Position& start, const Position& goal, std::function<void(PathFindResult_ptr)> callback) {

}

std::map<std::string, std::tuple<int, int, int, std::string>> Map::findEveryPath(const Position& start, int maxDistance, const std::map<std::string, std::string>& params)
{
    // using Dijkstra's algorithm
    struct LessNode {
        bool operator()(Node* a, Node* b) const
        {
            return b->totalCost < a->totalCost;
        }
    };

    if (g_extras.debugPathfinding) {
        g_logger.info(stdext::format("findEveryPath: %i %i %i - %i", start.x, start.y, start.z, maxDistance));
        for (auto& param : params) {
            g_logger.info(stdext::format("%s - %s", param.first, param.second));
        }
    }

    std::map<std::string, std::string>::const_iterator it;
    it = params.find("ignoreLastCreature");
    bool ignoreLastCreature = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("ignoreCreatures");
    bool ignoreCreatures = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("ignoreNonPathable");
    bool ignoreNonPathable = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("ignoreNonWalkable");
    bool ignoreNonWalkable = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("ignoreStairs");
    bool ignoreStairs = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("ignoreCost");
    bool ignoreCost = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("allowUnseen");
    bool allowUnseen = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("allowOnlyVisibleTiles");
    bool allowOnlyVisibleTiles = it != params.end() && it->second != "0" && it->second != "";
    it = params.find("marginMin");
    bool hasMargin = it != params.end();
    it = params.find("marginMax");
    hasMargin = hasMargin || (it != params.end());
    
        
    Position destPos;
    it = params.find("destination");
    if (it != params.end()) {
        std::vector<int32> pos = stdext::split<int32>(it->second, ",");
        if (pos.size() == 3) {
            destPos = Position(pos[0], pos[1], pos[2]);
        }
    }

    std::map<std::string, std::tuple<int, int, int, std::string>> ret;
    std::unordered_map<Position, Node*, PositionHasher> nodes;
    std::priority_queue<Node*, std::vector<Node*>, LessNode> searchList;

    Node* initNode = new Node{ 1, 0, start, nullptr, 0, 0 };
    nodes[start] = initNode;
    searchList.push(initNode);

    // hidden code
    
    for (auto& node : nodes) {
        if (node.second)
            delete node.second;
    }

    return ret;
}

int Map::getMinimapColor(const Position& pos)
{
    int color = 0;
    if (const TilePtr& tile = getTile(pos)) {
        color = tile->getMinimapColorByte();
    }
    if (color == 0) {
        const MinimapTile& mtile = g_minimap.getTile(pos);
        color = mtile.color;
    }
    return color;
}

bool Map::isPatchable(const Position& pos)
{
    if (const TilePtr& tile = getTile(pos)) {
        return tile->isPathable();
    }
    const MinimapTile& mtile = g_minimap.getTile(pos);
    return !mtile.hasFlag(MinimapTileNotPathable);
}

bool Map::isWalkable(const Position& pos, bool ignoreCreatures)
{
    if (const TilePtr& tile = getTile(pos)) {
        return tile->isWalkable(ignoreCreatures);
    }
    const MinimapTile& mtile = g_minimap.getTile(pos);
    return !mtile.hasFlag(MinimapTileNotPathable);
}
