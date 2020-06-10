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

#include "outfit.h"
#include "game.h"
#include "spritemanager.h"

#include <framework/graphics/painter.h>
#include <framework/graphics/drawqueue.h>

Outfit::Outfit()
{
    m_category = ThingCategoryCreature;
    m_id = 128;
    m_auxId = 0;
    resetClothes();
}

void Outfit::draw(Point dest, Otc::Direction direction, uint walkAnimationPhase, bool animate, LightView* lightView)
{
    // direction correction
    if (m_category != ThingCategoryCreature)
        direction = Otc::North;
    else if (direction == Otc::NorthEast || direction == Otc::SouthEast)
        direction = Otc::East;
    else if (direction == Otc::NorthWest || direction == Otc::SouthWest)
        direction = Otc::West;

    auto type = g_things.rawGetThingType(m_category == ThingCategoryCreature ? m_id : m_auxId, m_category);

    int animationPhase = walkAnimationPhase;
    if (animate && m_category == ThingCategoryCreature) {
        auto idleAnimator = type->getIdleAnimator();
        if (idleAnimator) {
            if (walkAnimationPhase > 0) {
                animationPhase += idleAnimator->getAnimationPhases() - 1;;
            } else {
                animationPhase = idleAnimator->getPhase();
            }
        } else if (type->isAnimateAlways()) {
            int phases = type->getAnimator() ? type->getAnimator()->getAnimationPhases() : type->getAnimationPhases();
            int ticksPerFrame = 1000 / phases;
            animationPhase = (g_clock.millis() % (ticksPerFrame * phases)) / ticksPerFrame;
        }
    } else if(animate) {
        int animationPhases = type->getAnimationPhases();
        int animateTicks = g_game.getFeature(Otc::GameEnhancedAnimations) ? Otc::ITEM_TICKS_PER_FRAME_FAST : Otc::ITEM_TICKS_PER_FRAME;

        if (m_category == ThingCategoryEffect) {
            animationPhases = std::max<int>(1, animationPhases - 2);
            animateTicks = g_game.getFeature(Otc::GameEnhancedAnimations) ? Otc::INVISIBLE_TICKS_PER_FRAME_FAST : Otc::INVISIBLE_TICKS_PER_FRAME;
        }

        if (animationPhases > 1)
            animationPhase = (g_clock.millis() % (animateTicks * animationPhases)) / animateTicks;
        if (m_category == ThingCategoryEffect)
            animationPhase = std::min<int>(animationPhase + 1, animationPhases);
    }

    int zPattern = m_mount > 0 ? std::min<int>(1, type->getNumPatternZ() - 1) : 0;
    if (zPattern > 0) {
        int mountAnimationPhase = walkAnimationPhase;
        auto mountType = g_things.rawGetThingType(m_mount, ThingCategoryCreature);
        auto idleAnimator = mountType->getIdleAnimator();
        if (idleAnimator && animate) {
            if (walkAnimationPhase > 0) {
                mountAnimationPhase += idleAnimator->getAnimationPhases() - 1;
            } else {
                mountAnimationPhase = idleAnimator->getPhase();
            }
        }

        dest -= mountType->getDisplacement();
        mountType->draw(dest, 0, direction, 0, 0, mountAnimationPhase, Color::white, lightView);
        dest += type->getDisplacement();
    }

    if (m_aura) {
        auto auraType = g_things.rawGetThingType(m_aura, ThingCategoryCreature);
        auraType->draw(dest, 0, direction, 0, 0, 0, Color::white, lightView);
    }

    if (m_wings && (direction == Otc::South || direction == Otc::West)) {
        auto wingsType = g_things.rawGetThingType(m_wings, ThingCategoryCreature);
        wingsType->draw(dest, 0, direction, 0, 0, animationPhase, Color::white, lightView);
    }

    for (int yPattern = 0; yPattern < type->getNumPatternY(); yPattern++) {
        if (yPattern > 0 && !(getAddons() & (1 << (yPattern - 1)))) {
            continue;
        }

        if (type->getLayers() <= 1) {
            type->draw(dest, 0, direction, yPattern, zPattern, animationPhase, Color::white, lightView);
            continue;
        }

        uint32_t colors = m_head + (m_body << 8) + (m_legs << 16) + (m_feet << 24);
        type->drawOutfit(dest, direction, yPattern, zPattern, animationPhase, colors, Color::white, lightView);
    }

    if (m_wings && (direction == Otc::North || direction == Otc::East)) {
        auto wingsType = g_things.rawGetThingType(m_wings, ThingCategoryCreature);
        wingsType->draw(dest, 0, direction, 0, 0, animationPhase, Color::white, lightView);
    }
}

void Outfit::draw(const Rect& dest, Otc::Direction direction, uint animationPhase, bool animate)
{
    int size = g_drawQueue->size();
    draw(Point(0, 0), direction, animationPhase, animate);
    g_drawQueue->correctOutfit(dest, size);
}

void Outfit::resetClothes()
{
    setHead(0);
    setBody(0);
    setLegs(0);
    setFeet(0);
    setMount(0);
}
