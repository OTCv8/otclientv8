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

#include "mapview.h"

#include "creature.h"
#include "map.h"
#include "tile.h"
#include "statictext.h"
#include "animatedtext.h"
#include "missile.h"
#include "shadermanager.h"
#include "lightview.h"
#include "localplayer.h"
#include "game.h"
#include "spritemanager.h"

#include <framework/graphics/graphics.h>
#include <framework/graphics/image.h>
#include <framework/graphics/framebuffermanager.h>
#include <framework/core/eventdispatcher.h>
#include <framework/core/application.h>
#include <framework/core/resourcemanager.h>
#include <framework/graphics/texturemanager.h>
#include <framework/graphics/atlas.h>

#include <framework/util/extras.h>
#include <framework/core/adaptiverenderer.h>

MapView::MapView()
{
    m_lockedFirstVisibleFloor = -1;
    m_cachedFirstVisibleFloor = 7;
    m_cachedLastVisibleFloor = 7;
    m_fadeOutTime = 0;
    m_fadeInTime = 0;
    m_minimumAmbientLight = 0;
    m_optimizedSize = Size(g_map.getAwareRange().horizontal(), g_map.getAwareRange().vertical()) * g_sprites.spriteSize();

    setVisibleDimension(Size(15, 11));
}

MapView::~MapView()
{
#ifndef NDEBUG
    VALIDATE(!g_app.isTerminated());
#endif
}

void MapView::drawTileTexts(const Rect& rect, const Rect& srcRect)
{
    Position cameraPosition = getCameraPosition();
    Point drawOffset = srcRect.topLeft();
    float horizontalStretchFactor = rect.width() / (float)srcRect.width();
    float verticalStretchFactor = rect.height() / (float)srcRect.height();

    auto player = g_game.getLocalPlayer();
    for (auto& tile : m_cachedVisibleTiles) {
        Position tilePos = tile.first->getPosition();
        if (tilePos.z != player->getPosition().z) continue;        

        Point p = transformPositionTo2D(tilePos, cameraPosition) - drawOffset;
        p.x *= horizontalStretchFactor;
        p.y *= verticalStretchFactor;
        p += rect.topLeft();
        p.y += 5;

        tile.first->drawTexts(p);
    }
}


void MapView::drawBackground(const Rect& rect, const TilePtr& crosshairTile) {
    Position cameraPosition = getCameraPosition();
    if (m_mustUpdateVisibleTilesCache) {
        updateVisibleTilesCache();
    }

    if (g_game.getFeature(Otc::GameForceLight)) {
        m_drawLight = true;
        m_minimumAmbientLight = 0.05f;
    }

    Rect srcRect = calcFramebufferSource(rect.size());
    g_drawQueue->setFrameBuffer(rect, m_optimizedSize, srcRect);

    if (m_drawLight) {
        Light ambientLight;
        if (cameraPosition.z <= Otc::SEA_FLOOR)
            ambientLight = g_map.getLight();
        if (!m_lightTexture || m_lightTexture->getSize() != m_drawDimension)
            m_lightTexture = TexturePtr(new Texture(m_drawDimension, false, true));
        m_lightView = std::make_unique<LightView>(m_lightTexture, m_drawDimension, rect, srcRect, ambientLight.color,
                                                  std::max<int>(m_minimumAmbientLight * 255, ambientLight.intensity));
    }

    auto itm = m_cachedVisibleTiles.begin();
    auto end = m_cachedVisibleTiles.end();
    for (int z = m_cachedLastVisibleFloor; z >= m_cachedFirstFadingFloor; --z) {
        float fading = 1.0;
        if (m_floorFading > 0) {
            fading = 0.;
            if (m_floorFading > 0) {
                fading = stdext::clamp<float>((float)m_fadingFloorTimers[z].elapsed_millis() / (float)m_floorFading, 0.f, 1.f);
                if (z < m_cachedFirstVisibleFloor)
                    fading = 1.0 - fading;
            }
            if (fading == 0) break;
        }

        size_t floorStart = g_drawQueue->size();
        size_t lightFloorStart = m_lightView ? m_lightView->size() : 0;
        for (; itm != end; ++itm) {
            Position tilePos = itm->first->getPosition();
            if (tilePos.z != z)
                break;


            Point tileDrawPos = transformPositionTo2D(tilePos, cameraPosition);

            if (m_lightView) {
                ItemPtr ground = itm->first->getGround();
                if (ground && ground->isGround() && !ground->isTranslucent()) {
                    m_lightView->setFieldBrightness(tileDrawPos, lightFloorStart, 0);
                }
            }

            itm->first->drawBottom(tileDrawPos, m_lightView.get());
            if (m_crosshair && itm->first == crosshairTile) 
            {
                g_drawQueue->addTexturedRect(Rect(tileDrawPos, tileDrawPos + Otc::TILE_PIXELS - 1),
                                             m_crosshair, Rect(0, 0, m_crosshair->getSize()));
            }
            itm->first->drawTop(tileDrawPos, m_lightView.get());
        }
        for (const MissilePtr& missile : g_map.getFloorMissiles(z)) {
            missile->draw(transformPositionTo2D(missile->getPosition(), cameraPosition), true, m_lightView.get());
        }
        if (fading < 0.99)
            g_drawQueue->setOpacity(floorStart, fading);
    }

} 

void MapView::drawForeground(const Rect& rect)
{
    // this could happen if the player position is not known yet
    Position cameraPosition = getCameraPosition();
    if (!cameraPosition.isValid())
        return;

    Rect srcRect = calcFramebufferSource(rect.size());
    Point drawOffset = srcRect.topLeft();
    float horizontalStretchFactor = rect.width() / (float)srcRect.width();
    float verticalStretchFactor = rect.height() / (float)srcRect.height();

    // creatures
    std::vector<std::pair<CreaturePtr, Point>> creatures;
    for (const CreaturePtr& creature : g_map.getSpectatorsInRangeEx(cameraPosition, false, m_visibleDimension.width() / 2, m_visibleDimension.width() / 2 + 1, m_visibleDimension.height() / 2, m_visibleDimension.height() / 2 + 1)) {
        if (!creature->canBeSeen())
            continue;

        PointF jumpOffset = creature->getJumpOffset();
        Point creatureOffset = Point(16 - creature->getDisplacementX(), -creature->getDisplacementY() - 2);
        Position pos = creature->getPrewalkingPosition();
        Point p = transformPositionTo2D(pos, cameraPosition) - drawOffset;
        p += (creature->getDrawOffset() + creatureOffset) - Point(stdext::round(jumpOffset.x), stdext::round(jumpOffset.y));
        p.x = p.x * horizontalStretchFactor;
        p.y = p.y * verticalStretchFactor;
        p += rect.topLeft();
        creatures.push_back(std::make_pair(creature, p));
    }

    for (auto& c : creatures) {
        int flags = Otc::DrawIcons;
        if (m_drawNames) { flags |= Otc::DrawNames; }
        if ((!c.first->isLocalPlayer() || m_drawPlayerBars) && !m_drawHealthBarsOnTop) {
            if (m_drawHealthBars) { flags |= Otc::DrawBars; }
            if (m_drawManaBar) { flags |= Otc::DrawManaBar; }
        }
        c.first->drawInformation(c.second, g_map.isCovered(c.first->getPrewalkingPosition(), m_cachedFirstVisibleFloor), rect, flags);
    }

    if (m_lightView) {
        g_drawQueue->add(m_lightView.release());
    }

    // texts
    int limit = g_adaptiveRenderer.textsLimit();
    for (int i = 0; i < 2; ++i) {
        for (const StaticTextPtr& staticText : g_map.getStaticTexts()) {
            Position pos = staticText->getPosition();

            if (pos.z != cameraPosition.z && staticText->getMessageMode() == Otc::MessageNone)
                continue;
            if ((staticText->getMessageMode() != Otc::MessageSay && staticText->getMessageMode() != Otc::MessageYell)) {
                if (i == 0)
                    continue;
            } else if (i == 1)
                continue;

            Point p = transformPositionTo2D(pos, cameraPosition) - drawOffset + Point(8, 0);
            p.x *= horizontalStretchFactor;
            p.y *= verticalStretchFactor;
            p += rect.topLeft();
            staticText->drawText(p, rect);
            if (--limit == 0)
                break;
        }
    }

    limit = g_adaptiveRenderer.textsLimit();
    for (const AnimatedTextPtr& animatedText : g_map.getAnimatedTexts()) {
        Position pos = animatedText->getPosition();

        if (pos.z != cameraPosition.z)
            continue;

        Point p = transformPositionTo2D(pos, cameraPosition) - drawOffset + Point(16, 8);
        p.x *= horizontalStretchFactor;
        p.y *= verticalStretchFactor;
        p += rect.topLeft();
        animatedText->drawText(p, rect);
        if (--limit == 0)
            break;
    }

    // tile texts
    drawTileTexts(rect, srcRect);

    // bars on top
    if (m_drawHealthBarsOnTop) {
        for (auto& c : creatures) {
            int flags = 0;
            if ((!c.first->isLocalPlayer() || m_drawPlayerBars)) {
                if (m_drawHealthBars) { flags |= Otc::DrawBars; }
                if (m_drawManaBar) { flags |= Otc::DrawManaBar; }
            }
            c.first->drawInformation(c.second, g_map.isCovered(c.first->getPrewalkingPosition(), m_cachedFirstVisibleFloor), rect, flags);
        }
    }
}


void MapView::updateVisibleTilesCache()
{
    // hidden
}

void MapView::updateGeometry(const Size& visibleDimension, const Size& optimizedSize)
{
    m_multifloor = true;
    m_visibleDimension = visibleDimension;
    m_drawDimension = visibleDimension + Size(3, 3);
    m_virtualCenterOffset = (m_drawDimension / 2 - Size(1, 1)).toPoint();
    m_visibleCenterOffset = m_virtualCenterOffset;
    m_optimizedSize = m_drawDimension * g_sprites.spriteSize();
    requestVisibleTilesCacheUpdate();
}

void MapView::onTileUpdate(const Position& pos)
{
    requestVisibleTilesCacheUpdate();
}

void MapView::onMapCenterChange(const Position& pos)
{
    requestVisibleTilesCacheUpdate();
}

void MapView::lockFirstVisibleFloor(int firstVisibleFloor)
{
    m_lockedFirstVisibleFloor = firstVisibleFloor;
    requestVisibleTilesCacheUpdate();
}

void MapView::unlockFirstVisibleFloor()
{
    m_lockedFirstVisibleFloor = -1;
    requestVisibleTilesCacheUpdate();
}

void MapView::setVisibleDimension(const Size& visibleDimension)
{
    //if(visibleDimension == m_visibleDimension)
    //    return;

    if(visibleDimension.width() % 2 != 1 || visibleDimension.height() % 2 != 1) {
        g_logger.traceError("visible dimension must be odd");
        return;
    }

    if(visibleDimension < Size(3,3)) {
        g_logger.traceError("reach max zoom in");
        return;
    }

    updateGeometry(visibleDimension, m_optimizedSize);
}

void MapView::optimizeForSize(const Size& visibleSize)
{
    updateGeometry(m_visibleDimension, visibleSize);
}

void MapView::followCreature(const CreaturePtr& creature)
{
    m_follow = true;
    m_followingCreature = creature;
    requestVisibleTilesCacheUpdate();
}

void MapView::setCameraPosition(const Position& pos)
{
    m_follow = false;
    m_customCameraPosition = pos;
    requestVisibleTilesCacheUpdate();
}

Position MapView::getPosition(const Point& point, const Size& mapSize)
{
    Position cameraPosition = getCameraPosition();

    // if we have no camera, its impossible to get the tile
    if(!cameraPosition.isValid())
        return Position();

    Rect srcRect = calcFramebufferSource(mapSize);
    float sh = srcRect.width() / (float)mapSize.width();
    float sv = srcRect.height() / (float)mapSize.height();

    Point framebufferPos = Point(point.x * sh, point.y * sv);
    Point realPos = (framebufferPos + srcRect.topLeft());
    Point centerOffset = realPos / Otc::TILE_PIXELS;

    Point tilePos2D = getVisibleCenterOffset() - m_drawDimension.toPoint() + centerOffset + Point(2,2);
    if(tilePos2D.x + cameraPosition.x < 0 && tilePos2D.y + cameraPosition.y < 0)
        return Position();

    Position position = Position(tilePos2D.x, tilePos2D.y, 0) + cameraPosition;

    if(!position.isValid())
        return Position();

    return position;
}

Point MapView::getPositionOffset(const Point& point, const Size& mapSize)
{
    Position cameraPosition = getCameraPosition();

    // if we have no camera, its impossible to get the tile
    if (!cameraPosition.isValid())
        return Point(0, 0);

    Rect srcRect = calcFramebufferSource(mapSize);
    float sh = srcRect.width() / (float)mapSize.width();
    float sv = srcRect.height() / (float)mapSize.height();

    Point framebufferPos = Point(point.x * sh, point.y * sv);
    Point realPos = (framebufferPos + srcRect.topLeft());
    return Point(realPos.x % Otc::TILE_PIXELS, realPos.y % Otc::TILE_PIXELS);
}

void MapView::move(int x, int y)
{
    m_moveOffset.x += x;
    m_moveOffset.y += y;

    int32_t tmp = m_moveOffset.x / g_sprites.spriteSize();
    bool requestTilesUpdate = false;
    if(tmp != 0) {
        m_customCameraPosition.x += tmp;
        m_moveOffset.x %= g_sprites.spriteSize();
        requestTilesUpdate = true;
    }

    tmp = m_moveOffset.y / g_sprites.spriteSize();
    if(tmp != 0) {
        m_customCameraPosition.y += tmp;
        m_moveOffset.y %= g_sprites.spriteSize();
        requestTilesUpdate = true;
    }

    if(requestTilesUpdate)
        requestVisibleTilesCacheUpdate();
}

Rect MapView::calcFramebufferSource(const Size& destSize, bool inNextFrame)
{
    float scaleFactor = g_sprites.spriteSize()/(float)Otc::TILE_PIXELS;
    Point drawOffset = ((m_drawDimension - m_visibleDimension - Size(1,1)).toPoint()/2) * g_sprites.spriteSize();
    if(isFollowingCreature())
        drawOffset += m_followingCreature->getWalkOffset(inNextFrame) * scaleFactor;

    Size srcSize = destSize;
    Size srcVisible = m_visibleDimension * g_sprites.spriteSize();
    srcSize.scale(srcVisible, Fw::KeepAspectRatio);
    drawOffset.x += (srcVisible.width() - srcSize.width()) / 2;
    drawOffset.y += (srcVisible.height() - srcSize.height()) / 2;

    return Rect(drawOffset, srcSize);
}

int MapView::calcFirstVisibleFloor(bool forFading)
{
    int z = 7;
    // return forced first visible floor
    if(m_lockedFirstVisibleFloor != -1) {
        z = m_lockedFirstVisibleFloor;
    } else {
        Position cameraPosition = getCameraPosition();

        // this could happens if the player is not known yet
        if(cameraPosition.isValid()) {
            // avoid rendering multifloors in far views
            if(!m_multifloor) {
                z = cameraPosition.z;
            } else {
                // if nothing is limiting the view, the first visible floor is 0
                int firstFloor = 0;

                // limits to underground floors while under sea level
                if(cameraPosition.z > Otc::SEA_FLOOR)
                    firstFloor = std::max<int>(cameraPosition.z - Otc::AWARE_UNDEGROUND_FLOOR_RANGE, (int)Otc::UNDERGROUND_FLOOR);

                // loop in 3x3 tiles around the camera
                for(int ix = -1; ix <= 1 && firstFloor < cameraPosition.z && !forFading; ++ix) {
                    for(int iy = -1; iy <= 1 && firstFloor < cameraPosition.z; ++iy) {
                        Position pos = cameraPosition.translated(ix, iy);

                        // process tiles that we can look through, e.g. windows, doors
                        if((ix == 0 && iy == 0) || ((std::abs(ix) != std::abs(iy)) && g_map.isLookPossible(pos))) {
                            Position upperPos = pos;
                            Position coveredPos = pos;

                            while(coveredPos.coveredUp() && upperPos.up() && upperPos.z >= firstFloor) {
                                // check tiles physically above
                                TilePtr tile = g_map.getTile(upperPos);
                                if(tile && tile->limitsFloorsView(!g_map.isLookPossible(pos))) {
                                    firstFloor = upperPos.z + 1;
                                    break;
                                }

                                // check tiles geometrically above
                                tile = g_map.getTile(coveredPos);
                                if(tile && tile->limitsFloorsView(g_map.isLookPossible(pos))) {
                                    firstFloor = coveredPos.z + 1;
                                    break;
                                }
                            }
                        }
                    }
                }
                z = firstFloor;
            }
        }
    }

    // just ensure the that the floor is in the valid range
    z = stdext::clamp<int>(z, 0, (int)Otc::MAX_Z);
    return z;
}

int MapView::calcLastVisibleFloor()
{
    if(!m_multifloor)
        return calcFirstVisibleFloor();

    int z = 7;

    Position cameraPosition = getCameraPosition();
    // this could happens if the player is not known yet
    if(cameraPosition.isValid()) {
        // view only underground floors when below sea level
        if(cameraPosition.z > Otc::SEA_FLOOR)
            z = cameraPosition.z + Otc::AWARE_UNDEGROUND_FLOOR_RANGE;
        else
            z = Otc::SEA_FLOOR;
    }

    if(m_lockedFirstVisibleFloor != -1)
        z = std::max<int>(m_lockedFirstVisibleFloor, z);

    // just ensure the that the floor is in the valid range
    z = stdext::clamp<int>(z, 0, (int)Otc::MAX_Z);
    return z;
}

Point MapView::transformPositionTo2D(const Position& position, const Position& relativePosition) {
    return Point((m_virtualCenterOffset.x + (position.x - relativePosition.x) - (relativePosition.z - position.z)) * g_sprites.spriteSize(),
        (m_virtualCenterOffset.y + (position.y - relativePosition.y) - (relativePosition.z - position.z)) * g_sprites.spriteSize());
}


Position MapView::getCameraPosition()
{
    if (isFollowingCreature()) {
        return m_followingCreature->getPrewalkingPosition();
    }

    return m_customCameraPosition;
}

void MapView::setDrawLights(bool enable)
{
    m_drawLight = enable;
}

void MapView::setCrosshair(const std::string& file)     
{
    if (file == "")
        m_crosshair = nullptr;
    else
        m_crosshair = g_textures.getTexture(file);
}

/* vim: set ts=4 sw=4 et: */
