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

#include "tile.h"
#include "item.h"
#include "thingtypemanager.h"
#include "map.h"
#include "game.h"
#include "localplayer.h"
#include "effect.h"
#include "protocolgame.h"
#include "lightview.h"
#include "spritemanager.h"
#include <framework/graphics/fontmanager.h>
#include <framework/util/extras.h>
#include <framework/core/adaptiverenderer.h>

Tile::Tile(const Position& position) :
    m_position(position),
    m_drawElevation(0),
    m_minimapColor(0),
    m_flags(0)
{
}

void Tile::drawBottom(const Point& dest, LightView* lightView)
{
    m_topDraws = 0;
    m_drawElevation = 0;
    if (m_fill != Color::alpha) {
        g_drawQueue->addFilledRect(Rect(dest, Otc::TILE_PIXELS, Otc::TILE_PIXELS), m_fill);
        return;
    }

    // bottom things
    for (const ThingPtr& thing : m_things) {
        if (!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom())
            break;
        if (thing->isHidden())
            continue;

        thing->draw(dest - m_drawElevation, true, lightView);
        m_drawElevation = std::min<uint8_t>(m_drawElevation + thing->getElevation(), Otc::MAX_ELEVATION);
    }

    // common items, reverse order
    int redrawPreviousTopW = 0, redrawPreviousTopH = 0;
    for (auto it = m_things.rbegin(); it != m_things.rend(); ++it) {
        const ThingPtr& thing = *it;
        if (thing->isOnTop() || thing->isOnBottom() || thing->isGroundBorder() || thing->isGround() || thing->isCreature())
            break;
        if (thing->isHidden())
            continue;

        thing->draw(dest - m_drawElevation, true, lightView);
        m_drawElevation = std::min<uint8_t>(m_drawElevation + thing->getElevation(), Otc::MAX_ELEVATION);

        if (thing->isLyingCorpse()) {
            redrawPreviousTopW = std::max<int>(thing->getWidth() - 1, redrawPreviousTopW);
            redrawPreviousTopH = std::max<int>(thing->getHeight() - 1, redrawPreviousTopH);
        }
    }

    for (int x = -redrawPreviousTopW; x <= 0; ++x) {
        for (int y = -redrawPreviousTopH; y <= 0; ++y) {
            if (x == 0 && y == 0)
                continue;
            if(const TilePtr& tile = g_map.getTile(m_position.translated(x, y)))
               tile->drawTop(dest + Point(x * Otc::TILE_PIXELS, y * Otc::TILE_PIXELS), lightView);
        }
    }

    if (lightView && hasTranslucentLight()) {
        lightView->addLight(dest + Point(16, 16), 215, 1);
    }
}

void Tile::drawTop(const Point& dest, LightView* lightView)
{
    if (m_fill != Color::alpha)
        return;
    if (m_topDraws++ < m_topCorrection)
        return;

    // walking creatures
    for (const CreaturePtr& creature : m_walkingCreatures) {
        if (creature->isHidden())
            continue;
        Point creatureDest(dest.x + ((creature->getPrewalkingPosition().x - m_position.x) * Otc::TILE_PIXELS - m_drawElevation),
                   dest.y + ((creature->getPrewalkingPosition().y - m_position.y) * Otc::TILE_PIXELS - m_drawElevation));
        creature->draw(creatureDest, true, lightView);
    }

    // creatures
    std::vector<CreaturePtr> creaturesToDraw;
    int limit = g_adaptiveRenderer.creaturesLimit();
    for (auto& thing : m_things) {
        if (!thing->isCreature() || thing->isHidden())
            continue;
        if (limit-- <= 0)
            break;
        CreaturePtr creature = thing->static_self_cast<Creature>();
        if (!creature || creature->isWalking())
            continue;
        creature->draw(dest - m_drawElevation, true, lightView);
    }

    // effects
    limit = std::min<int>((int)m_effects.size() - 1, g_adaptiveRenderer.effetsLimit());
    for (int i = limit; i >= 0; --i) {
        if (m_effects[i]->isHidden())
            continue;
        m_effects[i]->draw(dest - m_drawElevation, m_position.x - g_map.getCentralPosition().x, m_position.y - g_map.getCentralPosition().y, true, lightView);
    }

    // top
    for (const ThingPtr& thing : m_things) {
        if (!thing->isOnTop() || thing->isHidden())
            continue;
        thing->draw(dest - m_drawElevation, true, lightView);
        m_drawElevation = std::min<uint8_t>(m_drawElevation + thing->getElevation(), Otc::MAX_ELEVATION);
    }
}


void Tile::calculateCorpseCorrection() {
    m_topCorrection = 0;
    int redrawPreviousTopW = 0, redrawPreviousTopH = 0;
    for(auto it = m_things.rbegin(); it != m_things.rend(); ++it) {
        const ThingPtr& thing = *it;
        if(!thing->isLyingCorpse()) {
            continue;
        }
        if (thing->isHidden())
            continue;
        redrawPreviousTopW = std::max<int>(thing->getWidth() - 1, redrawPreviousTopW);
        redrawPreviousTopH = std::max<int>(thing->getHeight() - 1, redrawPreviousTopH);
    }

    for (int x = -redrawPreviousTopW; x <= 0; ++x) {
        for (int y = -redrawPreviousTopH; y <= 0; ++y) {
            if (x == 0 && y == 0)
                continue;
            if (const TilePtr& tile = g_map.getTile(m_position.translated(x, y)))
                tile->m_topCorrection += 1;
        }
    }
}

void Tile::drawTexts(Point dest)
{
    if (m_timerText && g_clock.millis() < m_timer) {
        if (m_text && m_text->hasText())
            dest.y -= 8;
        m_timerText->setText(stdext::format("%.01f", (m_timer - g_clock.millis()) / 1000.));
        m_timerText->drawText(dest, Rect(dest.x - 64, dest.y - 64, 128, 128));
        dest.y += 16;
    }

    if (m_text && m_text->hasText()) {
        m_text->drawText(dest, Rect(dest.x - 64, dest.y - 64, 128, 128));
    }
}

void Tile::clean()
{
    while(!m_things.empty())
        removeThing(m_things.front());
}

void Tile::addWalkingCreature(const CreaturePtr& creature)
{
    m_walkingCreatures.push_back(creature);
}

void Tile::removeWalkingCreature(const CreaturePtr& creature)
{
    auto it = std::find(m_walkingCreatures.begin(), m_walkingCreatures.end(), creature);
    if(it != m_walkingCreatures.end())
        m_walkingCreatures.erase(it);
}

void Tile::addThing(const ThingPtr& thing, int stackPos)
{
    if(!thing)
        return;

    if(thing->isEffect()) {
        if(thing->isTopEffect())
            m_effects.insert(m_effects.begin(), thing->static_self_cast<Effect>());
        else
            m_effects.push_back(thing->static_self_cast<Effect>());
    } else {
        // priority                                    854
        // 0 - ground,                        -->      -->
        // 1 - ground borders                 -->      -->
        // 2 - bottom (walls),                -->      -->
        // 3 - on top (doors)                 -->      -->
        // 4 - creatures, from top to bottom  <--      -->
        // 5 - items, from top to bottom      <--      <--
        if(stackPos < 0 || stackPos == 255) {
            int priority = thing->getStackPriority();

            // -1 or 255 => auto detect position
            // -2        => append

            bool append;
            if(stackPos == -2)
                append = true;
            else {
                append = (priority <= 3);

                // newer protocols does not store creatures in reverse order
                if(g_game.getClientVersion() >= 854 && priority == 4)
                    append = !append;
            }

            for(stackPos = 0; stackPos < (int)m_things.size(); ++stackPos) {
                int otherPriority = m_things[stackPos]->getStackPriority(); 
                if((append && otherPriority > priority) || (!append && otherPriority >= priority))
                    break;
            }
        } else if(stackPos > (int)m_things.size())
            stackPos = m_things.size();

        m_things.insert(m_things.begin() + stackPos, thing);

        if(m_things.size() > MAX_THINGS)
            removeThing(m_things[MAX_THINGS]);

        /*
        // check stack priorities
        // this code exists to find stackpos bugs faster
        int lastPriority = 0;
        for(const ThingPtr& thing : m_things) {
            int priority = thing->getStackPriority();
            VALIDATE(lastPriority <= priority);
            lastPriority = priority;
        }
        */
    }

    thing->setPosition(m_position);
    thing->onAppear();

    if(thing->isTranslucent())
        checkTranslucentLight();

    if(g_game.isTileThingLuaCallbackEnabled())
        callLuaField("onAddThing", thing);
}

bool Tile::removeThing(ThingPtr thing)
{
    if(!thing)
        return false;

    bool removed = false;

    if(thing->isEffect()) {
        EffectPtr effect = thing->static_self_cast<Effect>();
        auto it = std::find(m_effects.begin(), m_effects.end(), effect);
        if(it != m_effects.end()) {
            m_effects.erase(it);
            removed = true;
        }
    } else {
        auto it = std::find(m_things.begin(), m_things.end(), thing);
        if(it != m_things.end()) {
            m_things.erase(it);
            removed = true;
        }
    }

    if (thing->isCreature()) {
        m_lastCreature = thing->getId();
    }

    thing->onDisappear();

    if(thing->isTranslucent())
        checkTranslucentLight();

    if (g_game.isTileThingLuaCallbackEnabled() && removed) {
        callLuaField("onRemoveThing", thing);
    }

    return removed;
}

ThingPtr Tile::getThing(int stackPos)
{
    if(stackPos >= 0 && stackPos < (int)m_things.size())
        return m_things[stackPos];
    return nullptr;
}

EffectPtr Tile::getEffect(uint16 id)
{
    for(const EffectPtr& effect : m_effects)
        if(effect->getId() == id)
            return effect;
    return nullptr;
}

bool Tile::hasThing(const ThingPtr& thing)
{
    return std::find(m_things.begin(), m_things.end(), thing) != m_things.end();
}

int Tile::getThingStackPos(const ThingPtr& thing)
{
    for(uint stackpos = 0; stackpos < m_things.size(); ++stackpos)
        if(thing == m_things[stackpos])
            return stackpos;
    return -1;
}

ThingPtr Tile::getTopThing()
{
    if(isEmpty())
        return nullptr;
    for(const ThingPtr& thing : m_things)
        if(!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop() && !thing->isCreature())
            return thing;
    return m_things[m_things.size() - 1];
}

std::vector<ItemPtr> Tile::getItems()
{
    std::vector<ItemPtr> items;
    for(const ThingPtr& thing : m_things) {
        if(!thing->isItem())
            continue;
        ItemPtr item = thing->static_self_cast<Item>();
        items.push_back(item);
    }
    return items;
}

std::vector<CreaturePtr> Tile::getCreatures()
{
    std::vector<CreaturePtr> creatures;
    for(const ThingPtr& thing : m_things) {
        if(thing->isCreature())
            creatures.push_back(thing->static_self_cast<Creature>());
    }
    return creatures;
}

ItemPtr Tile::getGround()
{
    ThingPtr firstObject = getThing(0);
    if(!firstObject)
        return nullptr;
    if(firstObject->isGround() && firstObject->isItem())
        return firstObject->static_self_cast<Item>();
    return nullptr;
}

int Tile::getGroundSpeed()
{
    if (m_speed)
        return m_speed;
    int groundSpeed = 100;
    if(ItemPtr ground = getGround())
        groundSpeed = ground->getGroundSpeed();
    return groundSpeed;
}

uint8 Tile::getMinimapColorByte()
{
    uint8 color = 255; // alpha
    if(m_minimapColor != 0)
        return m_minimapColor;

    for(const ThingPtr& thing : m_things) {
        if(!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop())
            break;
        uint8 c = thing->getMinimapColor();
        if(c != 0)
            color = c;
    }
    return color;
}

ThingPtr Tile::getTopLookThing()
{
    if(isEmpty())
        return nullptr;

    for(uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if(!thing->isIgnoreLook() && (!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop()))
            return thing;
    }

    return m_things[0];
}

ThingPtr Tile::getTopLookThingEx(Point offset)
{
    auto creature = getTopCreatureEx(offset);
    if (creature)
        return creature;

    if (isEmpty())
        return nullptr;

    for (uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if (!thing->isIgnoreLook() && (!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop() && !thing->isCreature()))
            return thing;
    }

    return m_things[0];
}

ThingPtr Tile::getTopUseThing()
{
    if(isEmpty())
        return nullptr;

    for(uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if (thing->isForceUse() || (!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop() && !thing->isCreature() && !thing->isSplash()))
            return thing;
    }

    for (uint i = m_things.size() - 1; i > 0; --i) {
        ThingPtr thing = m_things[i];
        if (!thing->isSplash() && !thing->isCreature())
            return thing;
    }

    return m_things[0];
}

CreaturePtr Tile::getTopCreature()
{
    CreaturePtr creature;
    for(uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if(thing->isLocalPlayer()) // return local player if there is no other creature
            creature = thing->static_self_cast<Creature>();
        else if(thing->isCreature() && !thing->isLocalPlayer())
            return thing->static_self_cast<Creature>();
    }
    if(!creature && !m_walkingCreatures.empty())
        creature = m_walkingCreatures.back();

    // check for walking creatures in tiles around
    if(!creature) {
        for(int xi=-1;xi<=1;++xi) {
            for(int yi=-1;yi<=1;++yi) {
                Position pos = m_position.translated(xi, yi);
                if(pos == m_position)
                    continue;

                const TilePtr& tile = g_map.getTile(pos);
                if(tile) {
                    for(const CreaturePtr& c : tile->getCreatures()) {
                        if(c->isWalking() && c->getLastStepFromPosition() == m_position && c->getStepProgress() < 0.75f) {
                            creature = c;
                        }
                    }
                }
            }
        }
    }
    return creature;
}

CreaturePtr Tile::getTopCreatureEx(Point offset)
{
    // hidden
    return nullptr;
}

ThingPtr Tile::getTopMoveThing()
{
    if(isEmpty())
        return nullptr;

    for(uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if(!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop() && !thing->isCreature()) {
            if(i > 0 && thing->isNotMoveable())
                return m_things[i-1];
            return thing;
        }
    }

    for(const ThingPtr& thing : m_things) {
        if(thing->isCreature())
            return thing;
    }

    return m_things[0];
}

ThingPtr Tile::getTopMultiUseThing()
{
    if (isEmpty())
        return nullptr;

    if (CreaturePtr topCreature = getTopCreature())
        return topCreature;

    for (uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if (thing->isForceUse())
            return thing;
    }

    for (uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if (!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop()) {
            if (i > 0 && thing->isSplash())
                return m_things[i - 1];
            return thing;
        }
    }

    return m_things.back();
}

ThingPtr Tile::getTopMultiUseThingEx(Point offset)
{
    if (CreaturePtr topCreature = getTopCreatureEx(offset))
        return topCreature;

    if (isEmpty())
        return nullptr;

    for (uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if (thing->isForceUse() && !thing->isCreature())
            return thing;
    }

    for (uint i = 0; i < m_things.size(); ++i) {
        ThingPtr thing = m_things[i];
        if (!thing->isGround() && !thing->isGroundBorder() && !thing->isOnBottom() && !thing->isOnTop() && !thing->isCreature()) {
            if (i > 0 && thing->isSplash())
                return m_things[i - 1];
            return thing;
        }
    }

    for (uint i = m_things.size() - 1; i > 0; --i) {
        ThingPtr thing = m_things[i];
        if (!thing->isCreature())
            return thing;
    }

    return m_things[0];
}

bool Tile::isWalkable(bool ignoreCreatures)
{
    if(!getGround())
        return false;

    for(const ThingPtr& thing : m_things) {
        if(thing->isNotWalkable())
            return false;

        if(!ignoreCreatures) {
            if(thing->isCreature()) {
                CreaturePtr creature = thing->static_self_cast<Creature>();
                if(!creature->isPassable() && creature->canBeSeen() && !creature->isLocalPlayer())
                    return false;
            }
        }
    }
    return true;
}

bool Tile::isPathable()
{
    for(const ThingPtr& thing : m_things)
        if(thing->isNotPathable())
            return false;
    return true;
}

bool Tile::isFullGround()
{
    ItemPtr ground = getGround();
    if(ground && ground->isFullGround())
        return true;
    return false;
}

bool Tile::isFullyOpaque()
{
    ThingPtr firstObject = getThing(0);
    return firstObject && firstObject->isFullGround();
}

bool Tile::isSingleDimension()
{
    if(!m_walkingCreatures.empty())
        return false;
    for(const ThingPtr& thing : m_things)
        if(thing->getHeight() != 1 || thing->getWidth() != 1)
            return false;
    return true;
}

bool Tile::isLookPossible()
{
    for(const ThingPtr& thing : m_things)
        if(thing->blockProjectile())
            return false;
    return true;
}

bool Tile::isClickable()
{
    bool hasGround = false;
    bool hasOnBottom = false;
    bool hasIgnoreLook = false;
    for(const ThingPtr& thing : m_things) {
        if(thing->isGround())
            hasGround = true;
        if(thing->isOnBottom())
            hasOnBottom = true;
        if((hasGround || hasOnBottom) && !hasIgnoreLook)
            return true;
    }
    return false;
}

bool Tile::isEmpty()
{
    return m_things.size() == 0;
}

bool Tile::isDrawable()
{
    return !m_things.empty() || !m_walkingCreatures.empty() || !m_effects.empty();
}

bool Tile::mustHookEast()
{
    for(const ThingPtr& thing : m_things)
        if(thing->isHookEast())
            return true;
    return false;
}

bool Tile::mustHookSouth()
{
    for(const ThingPtr& thing : m_things)
        if(thing->isHookSouth())
            return true;
    return false;
}

bool Tile::hasCreature()
{
    for(const ThingPtr& thing : m_things)
        if(thing->isCreature())
            return true;
    return false;
}

bool Tile::hasBlockingCreature()
{
    for (const ThingPtr& thing : m_things)
        if (thing->isCreature() && !thing->static_self_cast<Creature>()->isPassable() && !thing->isLocalPlayer())
            return true;
    return false;
}

bool Tile::limitsFloorsView(bool isFreeView)
{
    // ground and walls limits the view
    ThingPtr firstThing = getThing(0);

    if(isFreeView) {
        if(firstThing && !firstThing->isDontHide() && (firstThing->isGround() || firstThing->isOnBottom()))
            return true;
    } else if(firstThing && !firstThing->isDontHide() && (firstThing->isGround() || (firstThing->isOnBottom() && firstThing->blockProjectile())))
        return true;
    return false;
}


bool Tile::canErase()
{
    return m_walkingCreatures.empty() && m_effects.empty() && m_things.empty() && m_flags == 0 && m_minimapColor == 0;
}

int Tile::getElevation()
{
    int elevation = 0;
    for(const ThingPtr& thing : m_things)
        if(thing->getElevation() > 0)
            elevation++;
    return elevation;
}

bool Tile::hasElevation(int elevation)
{
    return getElevation() >= elevation;
}

void Tile::checkTranslucentLight()
{
    if(m_position.z != Otc::SEA_FLOOR)
        return;

    Position downPos = m_position;
    if(!downPos.down())
        return;

    TilePtr tile = g_map.getOrCreateTile(downPos);
    if(!tile)
        return;

    bool translucent = false;
    for(const ThingPtr& thing : m_things) {
        if(thing->isTranslucent() || thing->hasLensHelp()) {
            translucent = true;
            break;
        }
    }

    if(translucent)
        tile->m_flags |= TILESTATE_TRANSLUECENT_LIGHT;
    else
        tile->m_flags &= ~TILESTATE_TRANSLUECENT_LIGHT;
}

void Tile::setText(const std::string& text, Color color)
{
    if (!m_text) {
        m_text = StaticTextPtr(new StaticText());
    }
    m_text->setText(text);
    m_text->setColor(color);
}

std::string Tile::getText()
{
    return m_text ? m_text->getCachedText().getText() : "";
}

void Tile::setTimer(int time, Color color)
{
    if (time > 60000) {
        g_logger.warning("Max tile timer value is 300000 (300s)!");
        return;
    }
    m_timer = time + g_clock.millis();
    if (!m_timerText) {
        m_timerText = StaticTextPtr(new StaticText());
    }
    m_timerText->setColor(color);
}

int Tile::getTimer()
{
    return m_timerText ? std::max<int>(0, m_timer - g_clock.millis()) : 0;
}

void Tile::setFill(Color color)
{
    m_fill = color;
}
