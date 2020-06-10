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

#include "texture.h"
#include "graphics.h"
#include "framebuffer.h"
#include "image.h"

#include <framework/core/application.h>
#include <framework/core/eventdispatcher.h>
#include <framework/util/stats.h>
#include <framework/graphics/texturemanager.h>

uint Texture::uniqueId = 1;

Texture::Texture(const Size& size, bool depthTexture, bool smooth, bool upsideDown)
{
    m_uniqueId = uniqueId++;
    m_smooth = smooth;
    m_upsideDown = upsideDown;
    setupSize(size);

    g_stats.addTexture();
}

Texture::Texture(const ImagePtr& image, bool buildMipmaps, bool compress, bool smooth)
{
    if (!image) {
        g_logger.fatal("Texture can't be created with null image!");
    }

    m_uniqueId = uniqueId++;
    m_smooth = smooth;
    m_image = image;
    setupSize(m_image->getSize());

    g_stats.addTexture();
}

Texture::~Texture()
{
#ifndef NDEBUG
    VALIDATE(!g_app.isTerminated());
#endif
    if (m_id != 0) { // free texture from gl memory
        GLuint textureId = m_id;
        g_graphicsDispatcher.addEvent([textureId] {
            glDeleteTextures(1, &textureId);
        });
    }

    g_stats.removeTexture();
}

void Texture::replace(const ImagePtr& image)
{
    m_uniqueId = uniqueId++;
    if (m_id != 0) { // free existing texture from gl memory
        GLuint textureId = m_id;
        g_graphicsDispatcher.addEvent([textureId] {
            glDeleteTextures(1, &textureId);
        });
    }
    if (!image) {
        g_logger.fatal("Texture can't be replaced with null image!");
    }
    m_id = 0;
    m_image = image;
    setupSize(m_image->getSize());
}

void Texture::resize(const Size& size)
{
    if(m_id == 0) 
        update();
    setupSize(size);
    glBindTexture(GL_TEXTURE_2D, m_id);
    setupPixels(0, m_size, nullptr, 4);
    //m_needsUpdate = true;
    /* update(); */
}


void Texture::update()
{
    if (m_id == 0) {
        glGenTextures(1, &m_id);
        VALIDATE(m_id != 0);
        glBindTexture(GL_TEXTURE_2D, m_id);
        if (m_image) {
            setupSize(m_image->getSize());
            int level = 0;
            do {
                setupPixels(level++, m_image->getSize(), m_image->getPixelData(), m_image->getBpp());
            } while (m_buildHardwareMipmaps && m_image->nextMipmap());
        } else {
            setupPixels(0, m_size, nullptr, 4);
        }
        m_image = nullptr; // free image
        m_needsUpdate = true;
        g_graphics.checkForError(__FUNCTION__, __FILE__, __LINE__);
    }
    
    if (m_needsUpdate) {
        glBindTexture(GL_TEXTURE_2D, m_id);
        setupWrap();
        setupFilters();
        setupTranformMatrix();
        m_needsUpdate = false;
        g_graphics.checkForError(__FUNCTION__, __FILE__, __LINE__);
    }
}

bool Texture::buildHardwareMipmaps()
{
    m_buildHardwareMipmaps = true;
    return true;
}

void Texture::setSmooth(bool smooth)
{
    if(smooth == m_smooth)
        return;

    m_smooth = smooth;
    m_needsUpdate = true;
}

void Texture::setRepeat(bool repeat)
{
    if(m_repeat == repeat)
        return;

    m_repeat = repeat;
    m_needsUpdate = true;
}

void Texture::setUpsideDown(bool upsideDown)
{
    if(m_upsideDown == upsideDown)
        return;
    m_upsideDown = upsideDown;
    m_needsUpdate = true;
}

void Texture::setupSize(const Size& size)
{
    if (size.width() > g_graphics.getMaxTextureSize() || size.height() > g_graphics.getMaxTextureSize()) {
        g_logger.fatal(stdext::format("Tried to create texture with size %ix%i while maximum texture size is %ix%i",
                                      size.width(), size.height(), g_graphics.getMaxTextureSize(), g_graphics.getMaxTextureSize()));
    }
    m_size = size;
}

void Texture::setupWrap()
{
    int texParam = GL_REPEAT;
    if(!m_repeat)
        texParam = GL_CLAMP_TO_EDGE;
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParam);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParam);
}

void Texture::setupFilters()
{
    int minFilter;
    int magFilter;
    if(m_smooth) {
        minFilter = m_hasMipmaps ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR;
        magFilter = GL_LINEAR;
    } else {
        minFilter = m_hasMipmaps ? GL_NEAREST_MIPMAP_NEAREST : GL_NEAREST;
        magFilter = GL_NEAREST;
    }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
}

void Texture::setupTranformMatrix()
{
    if(m_upsideDown) {
        m_transformMatrix = { 1.0f/m_size.width(),  0.0f,                                     0.0f,
                              0.0f,                  -1.0f/m_size.height(),                   0.0f,
                              0.0f,                   m_size.height()/(float)m_size.height(), 1.0f };
    } else {
        m_transformMatrix = { 1.0f/m_size.width(),  0.0f,                    0.0f,
                              0.0f,                   1.0f/m_size.height(),  0.0f,
                              0.0f,                   0.0f,                    1.0f };
    }
}

void Texture::setupPixels(int level, const Size& size, uchar* pixels, int channels, bool compress)
{
    GLenum format = 0;
    switch(channels) {
        case 4:
            format = GL_RGBA;
            break;
        case 3:
            format = GL_RGB;
            break;
        case 2:
            format = GL_LUMINANCE_ALPHA;
            break;
        case 1:
            format = GL_LUMINANCE;
            break;
    }

    GLenum internalFormat = GL_RGBA;
    glTexImage2D(GL_TEXTURE_2D, level, internalFormat, size.width(), size.height(), 0, format, GL_UNSIGNED_BYTE, pixels);
}
