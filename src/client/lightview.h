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

#ifndef LIGHTVIEW_H
#define LIGHTVIEW_H

#include "declarations.h"
#include "thingtype.h"
#include <framework/graphics/declarations.h>
#include <framework/graphics/drawqueue.h>
#include <set>

struct TileLight {
    size_t start;
    uint8_t color;
};

class LightView : public DrawQueueItem
{
public:
    LightView(TexturePtr& lightTexture, const Size& mapSize, const Rect& dest, const Rect& src, uint8_t color, uint8_t intensity) :
        DrawQueueItem(nullptr), m_lightTexture(lightTexture), m_mapSize(mapSize), m_dest(dest), m_src(src) {
        m_globalLight = Color::from8bit(color) * ((float)intensity / 255.f);
        m_tiles.resize(m_mapSize.area(), TileLight{ 0, 0 });
    }

    inline void addLight(const Point& pos, const Light& light)
    {
        return addLight(pos, light.color, light.intensity);
    }
    void addLight(const Point& pos, uint8_t color, uint8_t intensity);
    void setFieldBrightness(const Point& pos, size_t start, uint8_t color);
    size_t size() { return m_lights.size(); }

    void draw() override;

private:
    TexturePtr m_lightTexture;
    Size m_mapSize;
    Rect m_dest, m_src;
    Color m_globalLight;
    std::vector<Light> m_lights;
    std::vector<TileLight> m_tiles;
};

#endif

