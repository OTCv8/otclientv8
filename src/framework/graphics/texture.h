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

#ifndef TEXTURE_H
#define TEXTURE_H

#include "declarations.h"

class Texture : public stdext::shared_object
{
    static uint uniqueId;
public:
    Texture(const Size& size, bool depthTexture = false, bool smooth = false, bool upsideDown = false);
    Texture(const ImagePtr& image, bool buildMipmaps = false, bool compress = false, bool smooth = false);
    virtual ~Texture();
    virtual void replace(const ImagePtr& image);
    void resize(const Size& size);

    // update must be called always before drawing, only this function can use opengl functions
    virtual void update();

    virtual void setUpsideDown(bool upsideDown);
    virtual void setSmooth(bool smooth);
    virtual void setRepeat(bool repeat);
    virtual bool buildHardwareMipmaps();
    void setTime(ticks_t time) { m_time = time; }

    uint getId() { return m_id; }
    uint getUniqueId() { return m_uniqueId; }
    ticks_t getTime() { return m_time; }
    int getWidth() { return m_size.width(); }
    int getHeight() { return m_size.height(); }
    const Size& getSize() { return m_size; }
    const Matrix3& getTransformMatrix() { return m_transformMatrix; }
    bool isEmpty() { return false; }
    bool hasRepeat() { return m_repeat; }
    bool hasMipmaps() { return m_hasMipmaps; }
    virtual bool isAnimatedTexture() { return false; }

protected:

    void uploadPixels(const ImagePtr& image, bool buildMipmaps = false, bool compress = false);

    void setupSize(const Size& size);
    void setupWrap();
    void setupFilters();
    void setupTranformMatrix();
    void setupPixels(int level, const Size& size, uchar *pixels, int channels = 4, bool compress = false);

    uint m_id = 0;
    uint m_uniqueId = 0;
    ticks_t m_time = 0;
    Size m_size;
    Matrix3 m_transformMatrix;
    bool m_hasMipmaps = false;
    bool m_smooth = false;
    bool m_upsideDown = false;
    bool m_repeat = false;
    bool m_buildHardwareMipmaps = false;
    bool m_needsUpdate = false;
    ImagePtr m_image;
};

#endif
