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

#include "thingtype.h"
#include "spritemanager.h"
#include "game.h"
#include "lightview.h"

#include <framework/graphics/graphics.h>
#include <framework/graphics/texture.h>
#include <framework/graphics/image.h>
#include <framework/graphics/texturemanager.h>
#include <framework/core/filestream.h>
#include <framework/otml/otml.h>

ThingType::ThingType()
{
    m_category = ThingInvalidCategory;
    m_id = 0;
    m_null = true;
    m_exactSize = 0;
    m_realSize = 0;
    m_animator = nullptr;
    m_numPatternX = m_numPatternY = m_numPatternZ = 0;
    m_animationPhases = 0;
    m_layers = 0;
    m_elevation = 0;
    m_opacity = 1.0f;
}

void ThingType::serialize(const FileStreamPtr& fin)
{
    for(int i = 0; i < ThingLastAttr; ++i) {
        if(!hasAttr((ThingAttr)i))
            continue;

        int attr = i;
        if(g_game.getClientVersion() >= 780) {
            if(attr == ThingAttrChargeable)
                attr = ThingAttrWritable;
            else if(attr >= ThingAttrWritable)
                attr += 1;
        } else if(g_game.getClientVersion() >= 1000) {
            if(attr == ThingAttrNoMoveAnimation)
                attr = 16;
            else if(attr >= ThingAttrPickupable)
                attr += 1;
        }

        fin->addU8(attr);
        switch(attr) {
            case ThingAttrDisplacement: {
                fin->addU16(m_displacement.x);
                fin->addU16(m_displacement.y);
                break;
            }
            case ThingAttrLight: {
                Light light = m_attribs.get<Light>(attr);
                fin->addU16(light.intensity);
                fin->addU16(light.color);
                break;
            }
            case ThingAttrMarket: {
                MarketData market = m_attribs.get<MarketData>(attr);
                fin->addU16(market.category);
                fin->addU16(market.tradeAs);
                fin->addU16(market.showAs);
                fin->addString(market.name);
                fin->addU16(market.restrictVocation);
                fin->addU16(market.requiredLevel);
                break;
            }
            case ThingAttrUsable:
            case ThingAttrElevation:
            case ThingAttrGround:
            case ThingAttrWritable:
            case ThingAttrWritableOnce:
            case ThingAttrMinimapColor:
            case ThingAttrCloth:
            case ThingAttrLensHelp:
                fin->addU16(m_attribs.get<uint16>(attr));
                break;
            default:
                break;
        };
    }
    fin->addU8(ThingLastAttr);

    fin->addU8(m_size.width());
    fin->addU8(m_size.height());

    if(m_size.width() > 1 || m_size.height() > 1)
        fin->addU8(m_realSize);

    fin->addU8(m_layers);
    fin->addU8(m_numPatternX);
    fin->addU8(m_numPatternY);
    fin->addU8(m_numPatternZ);
    fin->addU8(m_animationPhases);

    if(g_game.getFeature(Otc::GameEnhancedAnimations)) {
        if(m_animationPhases > 1 && m_animator != nullptr)  {
            m_animator->serialize(fin);
        }
    }

    for(uint i = 0; i < m_spritesIndex.size(); i++) {
        if(g_game.getFeature(Otc::GameSpritesU32))
            fin->addU32(m_spritesIndex[i]);
        else
            fin->addU16(m_spritesIndex[i]);
    }
}

void ThingType::unserialize(uint16 clientId, ThingCategory category, const FileStreamPtr& fin)
{
    m_null = false;
    m_id = clientId;
    m_category = category;

    int count = 0, attr = -1;
    bool done = false;
    for(int i = 0 ; i < ThingLastAttr;++i) {
        count++;
        attr = fin->getU8();
        if(attr == ThingLastAttr) {
            done = true;
            break;
        }

        if(g_game.getClientVersion() >= 1000) {
            /* In 10.10+ all attributes from 16 and up were
             * incremented by 1 to make space for 16 as
             * "No Movement Animation" flag.
             */
            if(attr == 16)
                attr = ThingAttrNoMoveAnimation;
            else if(attr > 16)
                attr -= 1;
        } else if(g_game.getClientVersion() >= 860) {
            /* Default attribute values follow
             * the format of 8.6-9.86.
             * Therefore no changes here.
             */
        } else if(g_game.getClientVersion() >= 780) {
            /* In 7.80-8.54 all attributes from 8 and higher were
             * incremented by 1 to make space for 8 as
             * "Item Charges" flag.
             */
            if(attr == 8) {
                m_attribs.set(ThingAttrChargeable, true);
                continue;
            } else if(attr > 8)
                attr -= 1;
        } else if(g_game.getClientVersion() >= 755) {
            /* In 7.55-7.72 attributes 23 is "Floor Change". */
            if(attr == 23)
                attr = ThingAttrFloorChange;
        } else if(g_game.getClientVersion() >= 740) {
            /* In 7.4-7.5 attribute "Ground Border" did not exist
             * attributes 1-15 have to be adjusted.
             * Several other changes in the format.
             */
            if(attr > 0 && attr <= 15)
                attr += 1;
            else if(attr == 16)
                attr = ThingAttrLight;
            else if(attr == 17)
                attr = ThingAttrFloorChange;
            else if(attr == 18)
                attr = ThingAttrFullGround;
            else if(attr == 19)
                attr = ThingAttrElevation;
            else if(attr == 20)
                attr = ThingAttrDisplacement;
            else if(attr == 22)
                attr = ThingAttrMinimapColor;
            else if(attr == 23)
                attr = ThingAttrRotateable;
            else if(attr == 24)
                attr = ThingAttrLyingCorpse;
            else if(attr == 25)
                attr = ThingAttrHangable;
            else if(attr == 26)
                attr = ThingAttrHookSouth;
            else if(attr == 27)
                attr = ThingAttrHookEast;
            else if(attr == 28)
                attr = ThingAttrAnimateAlways;

            /* "Multi Use" and "Force Use" are swapped */
            if(attr == ThingAttrMultiUse)
                attr = ThingAttrForceUse;
            else if(attr == ThingAttrForceUse)
                attr = ThingAttrMultiUse;
        }

        switch(attr) {
            case ThingAttrDisplacement: {
                if(g_game.getClientVersion() >= 755) {
                    m_displacement.x = fin->getU16();
                    m_displacement.y = fin->getU16();
                } else {
                    m_displacement.x = 8;
                    m_displacement.y = 8;
                }
                m_attribs.set(attr, true);
                break;
            }
            case ThingAttrLight: {
                Light light;
                light.intensity = fin->getU16();
                light.color = fin->getU16();
                m_attribs.set(attr, light);
                break;
            }
            case ThingAttrMarket: {
                MarketData market;
                market.category = fin->getU16();
                market.tradeAs = fin->getU16();
                market.showAs = fin->getU16();
                market.name = fin->getString();
                market.restrictVocation = fin->getU16();
                market.requiredLevel = fin->getU16();
                m_attribs.set(attr, market);
                break;
            }
            case ThingAttrElevation: {
                m_elevation = fin->getU16();
                m_attribs.set(attr, m_elevation);
                break;
            }
            case ThingAttrUsable:
            case ThingAttrGround:
            case ThingAttrWritable:
            case ThingAttrWritableOnce:
            case ThingAttrMinimapColor:
            case ThingAttrCloth:
            case ThingAttrLensHelp:
                m_attribs.set(attr, fin->getU16());
                break;
            default:
                m_attribs.set(attr, true);
                break;
        };
    }

    if(!done)
        stdext::throw_exception(stdext::format("corrupt data (id: %d, category: %d, count: %d, lastAttr: %d)",
            m_id, m_category, count, attr));

    bool hasFrameGroups = (category == ThingCategoryCreature && g_game.getFeature(Otc::GameIdleAnimations));
    uint8 groupCount = hasFrameGroups ? fin->getU8() : 1;

    m_animationPhases = 0;
    int totalSpritesCount = 0;

    std::vector<Size> sizes;
    std::vector<int> total_sprites;

    for(int i = 0; i < groupCount; ++i) {
        uint8 frameGroupType = FrameGroupDefault;
        if(hasFrameGroups)
            frameGroupType = fin->getU8();

        uint8 width = fin->getU8();
        uint8 height = fin->getU8();
        m_size = Size(width, height);
        sizes.push_back(m_size);
        if(width > 1 || height > 1) {
            m_realSize = fin->getU8();
            m_exactSize = std::min<int>(m_realSize, std::max<int>(width * 32, height * 32));
        }
        else
            m_exactSize = 32;

        m_layers = fin->getU8();
        m_numPatternX = fin->getU8();
        m_numPatternY = fin->getU8();
        if(g_game.getClientVersion() >= 755)
            m_numPatternZ = fin->getU8();
        else
            m_numPatternZ = 1;
        
        int groupAnimationsPhases = fin->getU8();
        m_animationPhases += groupAnimationsPhases;

        if(groupAnimationsPhases > 1 && g_game.getFeature(Otc::GameEnhancedAnimations)) {
            AnimatorPtr animator = AnimatorPtr(new Animator);
            animator->unserialize(groupAnimationsPhases, fin);

            switch (frameGroupType) {
            case FrameGroupIdle:
                m_idleAnimator = animator;
                break;
            case FrameGroupMoving:
                m_animator = animator;
                break;
            }
        }

        int totalSprites = m_size.area() * m_layers * m_numPatternX * m_numPatternY * m_numPatternZ * groupAnimationsPhases;
        total_sprites.push_back(totalSprites);

        if((totalSpritesCount+totalSprites) > 4096)
            stdext::throw_exception("a thing type has more than 4096 sprites");

        m_spritesIndex.resize((totalSpritesCount+totalSprites));
        for(int i = totalSpritesCount; i < (totalSpritesCount+totalSprites); i++)
            m_spritesIndex[i] = g_game.getFeature(Otc::GameSpritesU32) ? fin->getU32() : fin->getU16();

        totalSpritesCount += totalSprites;
    }

    if(sizes.size() > 1) {
        // correction for some sprites
        for (auto& s : sizes) {
            m_size.setWidth(std::max<int>(m_size.width(), s.width()));
            m_size.setHeight(std::max<int>(m_size.height(), s.height()));
        }
        size_t expectedSize = m_size.area() * m_layers * m_numPatternX * m_numPatternY * m_numPatternZ * m_animationPhases;
        if (expectedSize != m_spritesIndex.size()) {
            std::vector<int> sprites(std::move(m_spritesIndex));
            m_spritesIndex.clear();
            m_spritesIndex.reserve(expectedSize);
            for (size_t i = 0, idx = 0; i < sizes.size(); ++i) {
                int totalSprites = total_sprites[i];
                if (m_size == sizes[i]) {
                    for (int j = 0; j < totalSprites; ++j) {
                        m_spritesIndex.push_back(sprites[idx++]);
                    }
                    continue;
                }
                size_t patterns = (totalSprites / sizes[i].area());
                for (size_t p = 0; p < patterns; ++p) {
                    for (int x = 0; x < m_size.width(); ++x) {
                        for (int y = 0; y < m_size.height(); ++y) {
                            if (x < sizes[i].width() && y < sizes[i].height()) {
                                m_spritesIndex.push_back(sprites[idx++]);
                                continue;
                            }
                            m_spritesIndex.push_back(0);
                        }
                    }
                }
            }
            //if (m_spritesIndex.size() != expectedSize) {
            //    g_logger.warning(stdext::format("Wrong thingtype: %i - %i - %i", clientId, m_spritesIndex.size(), expectedSize));
            //}
        }
    }

    if (m_idleAnimator && !m_animator) {
        m_animator = m_idleAnimator;
        m_idleAnimator = nullptr;
    }

    m_textures.resize(m_animationPhases);
    m_texturesFramesRects.resize(m_animationPhases);
    m_texturesFramesOriginRects.resize(m_animationPhases);
    m_texturesFramesOffsets.resize(m_animationPhases);

    m_lastUsage = g_clock.seconds();
}

void ThingType::exportImage(std::string fileName)
{
    if (m_null)
        stdext::throw_exception("cannot export null thingtype");

    if (m_spritesIndex.size() == 0)
        stdext::throw_exception("cannot export thingtype without sprites");

    size_t spriteSize = g_sprites.spriteSize();

    ImagePtr image(new Image(Size(spriteSize * m_size.width() * m_layers * m_numPatternX, spriteSize * m_size.height() * m_animationPhases * m_numPatternY * m_numPatternZ)));
    for (int z = 0; z < m_numPatternZ; ++z) {
        for (int y = 0; y < m_numPatternY; ++y) {
            for (int x = 0; x < m_numPatternX; ++x) {
                for (int l = 0; l < m_layers; ++l) {
                    for (int a = 0; a < m_animationPhases; ++a) {
                        for (int w = 0; w < m_size.width(); ++w) {
                            for (int h = 0; h < m_size.height(); ++h) {
                                image->blit(Point(spriteSize * (m_size.width() - w - 1 + m_size.width() * x + m_size.width() * m_numPatternX * l),
                                    spriteSize * (m_size.height() - h - 1 + m_size.height() * y + m_size.height() * m_numPatternY * a + m_size.height() * m_numPatternY * m_animationPhases * z)),
                                    g_sprites.getSpriteImage(m_spritesIndex[getSpriteIndex(w, h, l, x, y, z, a)]));
                            }
                        }
                    }
                }
            }
        }
    }

    image->savePNG(fileName);
}

void ThingType::replaceSprites(std::map<uint32_t, ImagePtr>& replacements, std::string fileName)
{
    if (m_null)
        stdext::throw_exception("cannot export null thingtype");

    if (m_spritesIndex.size() == 0)
        stdext::throw_exception("cannot export thingtype without sprites");

    size_t spriteSize = g_sprites.spriteSize();

    ImagePtr image = Image::loadPNG(fileName);
    if (!image)
        stdext::throw_exception(stdext::format("can't load image from %s", fileName));

    for (int z = 0; z < m_numPatternZ; ++z) {
        for (int y = 0; y < m_numPatternY; ++y) {
            for (int x = 0; x < m_numPatternX; ++x) {
                for (int l = 0; l < m_layers; ++l) {
                    for (int a = 0; a < m_animationPhases; ++a) {
                        for (int w = 0; w < m_size.width(); ++w) {
                            for (int h = 0; h < m_size.height(); ++h) {
                                uint32_t sprite = m_spritesIndex[getSpriteIndex(w, h, l, x, y, z, a)];
                                ImagePtr orgSprite = g_sprites.getSpriteImage(m_spritesIndex[getSpriteIndex(w, h, l, x, y, z, a)]);
                                if (!orgSprite) continue;
                                Point src(spriteSize * (m_size.width() - w - 1 + m_size.width() * x + m_size.width() * m_numPatternX * l),
                                    spriteSize * (m_size.height() - h - 1 + m_size.height() * y + m_size.height() * m_numPatternY * a + m_size.height() * m_numPatternY * m_animationPhases * z));
                                src = src * 2;
                                ImagePtr newSprite(new Image(Size(orgSprite->getSize() * 2)));
                                for (int x = 0; x < newSprite->getSize().width(); ++x) {
                                    for (int y = 0; y < newSprite->getSize().height(); ++y) {
                                        newSprite->setPixel(x, y, image->getPixel(src.x + x, src.y + y));
                                    }
                                }
                                replacements[sprite] = newSprite;
                            }
                        }
                    }
                }
            }
        }
    }
}

void ThingType::unserializeOtml(const OTMLNodePtr& node)
{
    for(const OTMLNodePtr& node2 : node->children()) {
        if(node2->tag() == "opacity")
            m_opacity = node2->value<float>();
        else if(node2->tag() == "notprewalkable")
            m_attribs.set(ThingAttrNotPreWalkable, node2->value<bool>());
        else if(node2->tag() == "image")
            m_customImage = node2->value();
        else if(node2->tag() == "full-ground") {
            if(node2->value<bool>())
                m_attribs.set(ThingAttrFullGround, true);
            else
                m_attribs.remove(ThingAttrFullGround);
        }
    }
}

void ThingType::unload()
{
    m_textures.clear();
    m_texturesFramesRects.clear();
    m_texturesFramesOriginRects.clear();
    m_texturesFramesOffsets.clear();

    m_textures.resize(m_animationPhases);
    m_texturesFramesRects.resize(m_animationPhases);
    m_texturesFramesOriginRects.resize(m_animationPhases);
    m_texturesFramesOffsets.resize(m_animationPhases);

    m_loaded = false;
}


DrawQueueItem* ThingType::draw(const Point& dest, int layer, int xPattern, int yPattern, int zPattern, int animationPhase, Color color, LightView* lightView)
{
    if (m_null)
        return nullptr;

    if (animationPhase < 0 || animationPhase >= m_animationPhases)
        return nullptr;

    const TexturePtr& texture = getTexture(animationPhase); // texture might not exists, neither its rects.
    if (!texture)
        return nullptr;

    uint frameIndex = getTextureIndex(layer, xPattern, yPattern, zPattern);
    if (frameIndex >= m_texturesFramesRects[animationPhase].size())
        return nullptr;

    Point textureOffset = m_texturesFramesOffsets[animationPhase][frameIndex];
    Rect textureRect = m_texturesFramesRects[animationPhase][frameIndex];

    Rect screenRect(dest + (textureOffset - m_displacement - (m_size.toPoint() - Point(1, 1)) * Otc::TILE_PIXELS), textureRect.size());

    bool useOpacity = m_opacity < 1.0f;
    if (useOpacity)
        color.setAlpha(m_opacity);

    if (lightView && hasLight())
        lightView->addLight(screenRect.center(), getLight());

    return g_drawQueue->addTexturedRect(screenRect, texture, textureRect, color);
}

DrawQueueItem* ThingType::draw(const Rect& dest, int layer, int xPattern, int yPattern, int zPattern, int animationPhase, Color color)
{
    if (m_null)
        return nullptr;

    if (animationPhase < 0 || animationPhase >= m_animationPhases)
        return nullptr;

    const TexturePtr& texture = getTexture(animationPhase); // texture might not exists, neither its rects.
    if (!texture)
        return nullptr;

    uint frameIndex = getTextureIndex(layer, xPattern, yPattern, zPattern);
    if (frameIndex >= m_texturesFramesRects[animationPhase].size())
        return nullptr;

    Point textureOffset = m_texturesFramesOffsets[animationPhase][frameIndex];
    Rect textureRect = m_texturesFramesRects[animationPhase][frameIndex];

    bool useOpacity = m_opacity < 1.0f;
    if (useOpacity)
        color.setAlpha(m_opacity);

    Size size = m_size * Otc::TILE_PIXELS;
    if (!size.isValid())
        return nullptr;

    // size correction for some too big items
    if ((size.width() > 1 || size.height() > 1) && 
        textureRect.width() <= Otc::TILE_PIXELS && textureRect.height() <= Otc::TILE_PIXELS) {
        size = Size(Otc::TILE_PIXELS, Otc::TILE_PIXELS);
        textureOffset = Point((Otc::TILE_PIXELS - textureRect.width()) / 2, 
                              (Otc::TILE_PIXELS - textureRect.height()) / 2);
    }

    float scale = std::min<float>((float)dest.width() / size.width(), (float)dest.height() / size.height());
    return g_drawQueue->addTexturedRect(Rect(dest.topLeft() + (textureOffset * scale), textureRect.size() * scale), texture, textureRect, color);
}

void ThingType::drawOutfit(const Point& dest, int xPattern, int yPattern, int zPattern, int animationPhase, int colors, Color color, LightView* lightView)
{
    if (m_null)
        return;

    if (animationPhase < 0 || animationPhase >= m_animationPhases)
        return;

    const TexturePtr& texture = getTexture(animationPhase); // texture might not exists, neither its rects.
    if (!texture)
        return;

    uint frameIndex = getTextureIndex(0, xPattern, yPattern, zPattern);
    uint frameIndex2 = getTextureIndex(1, xPattern, yPattern, zPattern);
    if (frameIndex >= m_texturesFramesRects[animationPhase].size() || frameIndex2 >= m_texturesFramesRects[animationPhase].size())
        return;

    Point textureOffset = m_texturesFramesOffsets[animationPhase][frameIndex];
    Point textureOffset2 = m_texturesFramesOffsets[animationPhase][frameIndex2];
    Rect textureRect = m_texturesFramesRects[animationPhase][frameIndex];
    Rect textureRect2 = m_texturesFramesRects[animationPhase][frameIndex2];
    Size size = textureRect.size();
    if (!size.isValid())
        return;
    Rect screenRect(dest + (textureOffset - m_displacement - (m_size.toPoint() - Point(1, 1)) * Otc::TILE_PIXELS), textureRect.size());

    bool useOpacity = m_opacity < 1.0f;
    if (useOpacity)
        color.setAlpha(m_opacity);

    if (lightView && hasLight())
        lightView->addLight(screenRect.center(), getLight());

    Point offset = textureOffset - textureOffset2;
    offset += textureRect2.topLeft() - textureRect.topLeft();
    g_drawQueue->addOutfit(screenRect, texture, textureRect, offset, colors, color);
}

Rect ThingType::getDrawSize(const Point& dest, int layer, int xPattern, int yPattern, int zPattern, int animationPhase)
{
    if (m_null)
        return Rect(0, 0, 1, 1);

    if (animationPhase < 0 || animationPhase >= m_animationPhases)
        return Rect(0, 0, 1, 1);

    const TexturePtr& texture = getTexture(animationPhase); // texture might not exists, neither its rects.
    if (!texture)
        return Rect(0, 0, 1, 1);

    uint frameIndex = getTextureIndex(layer, xPattern, yPattern, zPattern);
    if (frameIndex >= m_texturesFramesRects[animationPhase].size())
        return Rect(0, 0, 1, 1);

    Point textureOffset = m_texturesFramesOffsets[animationPhase][frameIndex];
    Rect textureRect = m_texturesFramesRects[animationPhase][frameIndex];
    return Rect(dest + textureOffset - m_displacement - (m_size.toPoint() - Point(1, 1)) * Otc::TILE_PIXELS, textureRect.size());
}


const TexturePtr& ThingType::getTexture(int animationPhase)
{
    m_lastUsage = g_clock.seconds();

    int spriteSize = g_sprites.spriteSize();
    TexturePtr& animationPhaseTexture = m_textures[animationPhase];
    if(!animationPhaseTexture) {
        bool useCustomImage = false; 
        if(animationPhase == 0 && !m_customImage.empty())
            useCustomImage = true;

        // we don't need layers in common items, they will be pre-drawn
        int textureLayers = 1;
        int numLayers = m_layers;
        if(m_category == ThingCategoryCreature && numLayers >= 2) {
            // otcv8 optimization from 5 to 2 layers
            textureLayers = 2;
            numLayers = 2;
        }

        int indexSize = textureLayers * m_numPatternX * m_numPatternY * m_numPatternZ;
        Size textureSize = getBestTextureDimension(m_size.width(), m_size.height(), indexSize);
        ImagePtr fullImage;

        if(useCustomImage)
            fullImage = Image::load(m_customImage);
        else
            fullImage = ImagePtr(new Image(textureSize * spriteSize));

        m_texturesFramesRects[animationPhase].resize(indexSize);
        m_texturesFramesOriginRects[animationPhase].resize(indexSize);
        m_texturesFramesOffsets[animationPhase].resize(indexSize);

        for(int z = 0; z < m_numPatternZ; ++z) {
            for(int y = 0; y < m_numPatternY; ++y) {
                for(int x = 0; x < m_numPatternX; ++x) {
                    for(int l = 0; l < numLayers; ++l) {
                        bool spriteMask = (m_category == ThingCategoryCreature && l > 0);
                        int frameIndex = getTextureIndex(l % textureLayers, x, y, z);
                        Point framePos = Point(frameIndex % (textureSize.width() / m_size.width()) * m_size.width(),
                                               frameIndex / (textureSize.width() / m_size.width()) * m_size.height()) * spriteSize;

                        if (!useCustomImage) {
                            for (int h = 0; h < m_size.height(); ++h) {
                                for (int w = 0; w < m_size.width(); ++w) {
                                    uint spriteIndex = getSpriteIndex(w, h, spriteMask ? 1 : l, x, y, z, animationPhase);
                                    ImagePtr spriteImage = g_sprites.getSpriteImage(m_spritesIndex[spriteIndex]);
                                    if (!spriteImage) {
                                        continue;
                                    }
                                    Point spritePos = Point(m_size.width() - w - 1,
                                                            m_size.height() - h - 1) * spriteSize;
                                    fullImage->blit(framePos + spritePos, spriteImage);
                                }
                            }
                        }

                        Rect drawRect(framePos + Point(m_size.width(), m_size.height()) * spriteSize - Point(1,1), framePos);
                        for(int x = framePos.x; x < framePos.x + m_size.width() * spriteSize; ++x) {
                            for(int y = framePos.y; y < framePos.y + m_size.height() * spriteSize; ++y) {
                                uint8 *p = fullImage->getPixel(x,y);
                                if(p[3] != 0x00) {
                                    drawRect.setTop   (std::min<int>(y, (int)drawRect.top()));
                                    drawRect.setLeft  (std::min<int>(x, (int)drawRect.left()));
                                    drawRect.setBottom(std::max<int>(y, (int)drawRect.bottom()));
                                    drawRect.setRight (std::max<int>(x, (int)drawRect.right()));
                                }
                            }
                        }

                        m_texturesFramesRects[animationPhase][frameIndex] = drawRect;
                        m_texturesFramesOriginRects[animationPhase][frameIndex] = Rect(framePos, Size(m_size.width(), m_size.height()) * spriteSize);// *0.5;
                        m_texturesFramesOffsets[animationPhase][frameIndex] = (drawRect.topLeft() - framePos);
                    }
                }
            }
        }
        animationPhaseTexture = TexturePtr(new Texture(fullImage, true, false, true));
        m_loaded = true;
    }
    return animationPhaseTexture;
}

Size ThingType::getBestTextureDimension(int w, int h, int count)
{
    const int MAX = 32;

    int k = 1;
    while(k < w)
        k<<=1;
    w = k;

    k = 1;
    while(k < h)
        k<<=1;
    h = k;

    int numSprites = w*h*count;
    VALIDATE(numSprites <= MAX*MAX);
    VALIDATE(w <= MAX);
    VALIDATE(h <= MAX);

    Size bestDimension = Size(MAX, MAX);
    for(int i=w;i<=MAX;i<<=1) {
        for(int j=h;j<=MAX;j<<=1) {
            Size candidateDimension = Size(i, j);
            if(candidateDimension.area() < numSprites)
                continue;
            if((candidateDimension.area() < bestDimension.area()) ||
               (candidateDimension.area() == bestDimension.area() && candidateDimension.width() + candidateDimension.height() < bestDimension.width() + bestDimension.height()))
                bestDimension = candidateDimension;
        }
    }

    return bestDimension;
}

uint ThingType::getSpriteIndex(int w, int h, int l, int x, int y, int z, int a) {
    uint index =
        ((((((a % m_animationPhases)
        * m_numPatternZ + z)
        * m_numPatternY + y)
        * m_numPatternX + x)
        * m_layers + l)
        * m_size.height() + h)
        * m_size.width() + w;
    VALIDATE(index < m_spritesIndex.size());
    return index;
}

uint ThingType::getTextureIndex(int l, int x, int y, int z) {
    return ((l * m_numPatternZ + z)
               * m_numPatternY + y)
               * m_numPatternX + x;
}

int ThingType::getExactSize(int layer, int xPattern, int yPattern, int zPattern, int animationPhase)
{
    if(m_null)
        return 0;

    getTexture(animationPhase); // we must calculate it anyway.
    int frameIndex = getTextureIndex(layer, xPattern, yPattern, zPattern);
    Size size = m_texturesFramesOriginRects[animationPhase][frameIndex].size() - m_texturesFramesOffsets[animationPhase][frameIndex].toSize();
    return std::max<int>(size.width(), size.height());
}

void ThingType::setPathable(bool var)
{
    if(var == true)
        m_attribs.remove(ThingAttrNotPathable);
    else
        m_attribs.set(ThingAttrNotPathable, true);
}