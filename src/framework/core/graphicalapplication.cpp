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


#include "graphicalapplication.h"
#include <framework/core/adaptiverenderer.h>
#include <framework/core/clock.h>
#include <framework/core/eventdispatcher.h>
#include <framework/core/asyncdispatcher.h>
#include <framework/platform/platformwindow.h>
#include <framework/ui/uimanager.h>
#include <framework/graphics/graphics.h>
#include <framework/graphics/texturemanager.h>
#include <framework/graphics/painter.h>
#include <framework/graphics/framebuffermanager.h>
#include <framework/graphics/fontmanager.h>
#include <framework/graphics/atlas.h>
#include <framework/graphics/image.h>
#include <framework/graphics/textrender.h>
#include <framework/input/mouse.h>
#include <framework/util/extras.h>
#include <framework/util/stats.h>

#ifdef FW_SOUND
#include <framework/sound/soundmanager.h>
#endif

GraphicalApplication g_app;

void GraphicalApplication::init(std::vector<std::string>& args)
{
    Application::init(args);

    // setup platform window
    g_window.init();
    g_window.hide();
    g_window.setOnResize(std::bind(&GraphicalApplication::resize, this, std::placeholders::_1));
    g_window.setOnInputEvent(std::bind(&GraphicalApplication::inputEvent, this, std::placeholders::_1));
    g_window.setOnClose(std::bind(&GraphicalApplication::close, this));

    g_mouse.init();

    // initialize ui
    g_ui.init();

    // initialize graphics
    g_graphics.init();

    // fire first resize event
    resize(g_window.getSize());

#ifdef FW_SOUND
    // initialize sound
    g_sounds.init();
#endif
}

void GraphicalApplication::deinit()
{
    // hide the window because there is no render anymore
    g_window.hide();
    g_asyncDispatcher.terminate();

    Application::deinit();
}

void GraphicalApplication::terminate()
{
    // destroy any remaining widget
    g_ui.terminate();

    Application::terminate();
    m_terminated = false;

#ifdef FW_SOUND
    // terminate sound
    g_sounds.terminate();
#endif

    g_mouse.terminate();

    // terminate graphics
    g_graphicsDispatcher.shutdown();
    g_graphics.terminate();
    g_window.terminate();

    m_terminated = true;
}

void GraphicalApplication::run()
{
    m_running = true;

    // first clock update
    g_clock.update();

    // run the first poll
    poll();
    g_clock.update();

    // show window
    g_window.show();

    // run the second poll
    poll();
    g_clock.update();

    g_lua.callGlobalField("g_app", "onRun");

    m_framebuffer = g_framebuffers.createFrameBuffer();
    m_framebuffer->resize(g_painterNew->getResolution());
    m_mapFramebuffer = g_framebuffers.createFrameBuffer();
    m_mapFramebuffer->resize(g_painterNew->getResolution());

    ticks_t lastRender = stdext::micros();

    std::shared_ptr<DrawQueue> drawQueue;
    std::shared_ptr<DrawQueue> drawMapQueue;
    std::shared_ptr<DrawQueue> drawMapForegroundQueue;

    std::mutex mutex;
    std::thread worker([&] {
        g_dispatcherThreadId = std::this_thread::get_id();
        while (!m_stopping) {
            m_processingFrames.addFrame();
            {
                g_clock.update();
                poll();
                g_clock.update();
            }

            mutex.lock();
            if (drawQueue && drawMapQueue && m_maxFps > 0) { // old drawQueue not processed yet
                mutex.unlock();
                AutoStat s(STATS_MAIN, "Sleep");
                stdext::millisleep(1);
                continue;
            }
            mutex.unlock();

            {
                AutoStat s(STATS_MAIN, "DrawMapBackground");
                g_drawQueue = std::make_shared<DrawQueue>();
                g_ui.render(Fw::MapBackgroundPane);
            }
            std::shared_ptr<DrawQueue> mapBackgroundQueue = g_drawQueue;
            {
                AutoStat s(STATS_MAIN, "DrawMapForeground");
                g_drawQueue = std::make_shared<DrawQueue>();
                g_ui.render(Fw::MapForegroundPane);
            }

            mutex.lock();
            drawMapQueue = mapBackgroundQueue;
            drawMapForegroundQueue = g_drawQueue;
            mutex.unlock();

            {
                AutoStat s(STATS_MAIN, "DrawForeground");
                g_drawQueue = std::make_shared<DrawQueue>();
                g_ui.render(Fw::ForegroundPane);
            }

            mutex.lock();
            drawQueue = g_drawQueue;
            g_drawQueue = nullptr;
            mutex.unlock();

            if (m_maxFps > 0 || g_window.hasVerticalSync()) {
                AutoStat s(STATS_MAIN, "Sleep");
                stdext::millisleep(1);
            }
        }
        g_dispatcher.poll(); // last poll
        g_dispatcherThreadId = g_mainThreadId;
    });

    std::shared_ptr<DrawQueue> toDrawQueue, toDrawMapQueue, toDrawMapForegroundQueue;
    int draws = 0, calls = 0;
    while (!m_stopping) {
        m_iteration += 1;

        pollGraphics();

        if (!g_window.isVisible()) {
            AutoStat s(STATS_RENDER, "Sleep");
            stdext::millisleep(1);
            g_adaptiveRenderer.refresh();
            continue;
        }

        int frameDelay = m_maxFps <= 0 ? 0 : (1000000 / m_maxFps);
        if (lastRender + frameDelay > stdext::micros() && !m_mustRepaint) {
            AutoStat s(STATS_RENDER, "Sleep");
            stdext::millisleep(1);
            continue;
        }

        mutex.lock();
        if ((!drawQueue && !toDrawQueue) || !drawMapQueue || !drawMapForegroundQueue || (m_mustRepaint && !drawQueue)) {
            mutex.unlock();
            continue;
        }
        toDrawQueue = drawQueue ? drawQueue : toDrawQueue;
        toDrawMapQueue = drawMapQueue;
        toDrawMapForegroundQueue = drawMapForegroundQueue;
        drawQueue = drawMapQueue = drawMapForegroundQueue = nullptr;
        mutex.unlock();

        g_adaptiveRenderer.newFrame();
        m_graphicsFrames.addFrame();
        m_mustRepaint = false;
        lastRender = stdext::micros() > lastRender + frameDelay * 2 ? stdext::micros() : lastRender + frameDelay;

        g_painterNew->resetDraws();
        if (m_scaling > 1.0f) {
            g_painterNew->setResolution(g_graphics.getViewportSize() / m_scaling);
            m_framebuffer->resize(g_painterNew->getResolution());
            m_framebuffer->bind();
        }

        if (toDrawMapQueue->hasFrameBuffer()) {
            AutoStat s(STATS_RENDER, "UpdateMap");
            m_mapFramebuffer->resize(toDrawMapQueue->getFrameBufferSize());
            m_mapFramebuffer->bind();
            g_painterNew->clear(Color::black);
            toDrawMapQueue->draw(DRAW_ALL);
            m_mapFramebuffer->release();
        }

        {
            AutoStat s(STATS_RENDER, "Clear");
            g_painterNew->clear(Color::alpha);
        }

        {
            AutoStat s(STATS_RENDER, "DrawFirstForeground");
            if (toDrawQueue)
                toDrawQueue->draw(DRAW_BEFORE_MAP);
        }

        if(toDrawMapQueue->hasFrameBuffer()) {
            AutoStat s(STATS_RENDER, "DrawMapBackground");
            m_mapFramebuffer->draw(toDrawMapQueue->getFrameBufferDest(), toDrawMapQueue->getFrameBufferSrc());
        }

        {
            AutoStat s(STATS_RENDER, "DrawMapForeground");
            toDrawMapForegroundQueue->draw();
        }

        {
            AutoStat s(STATS_RENDER, "DrawSecondForeground");
            if(g_extras.debugRender)
                toDrawQueue->addText(g_fonts.getDefaultFont(), stdext::format("Calls: %i Draws %i", calls, draws), Rect(0, 0, 200, 200), Fw::AlignTopLeft, Color::yellow);
            toDrawQueue->draw(DRAW_AFTER_MAP);
        }

        if (m_scaling > 1.0f) {
            AutoStat s(STATS_RENDER, "DrawScaled");
            m_framebuffer->release();
            g_painterNew->setResolution(g_graphics.getViewportSize());
            g_painterNew->clear(Color::alpha);
            m_framebuffer->draw(Rect(0, 0, g_painterNew->getResolution()));
        }

        draws = g_painterNew->draws();
        calls = g_painterNew->calls();

        AutoStat s(STATS_RENDER, "SwapBuffers");
        g_window.swapBuffers();
        g_graphics.checkForError(__FUNCTION__, __FILE__, __LINE__);
    }

    worker.join();
    g_graphicsDispatcher.poll();

    m_framebuffer = nullptr;
    m_mapFramebuffer = nullptr;
    g_drawQueue = nullptr;
    m_stopping = false;
    m_running = false;
}

void GraphicalApplication::poll() {
#ifdef FW_SOUND
    g_sounds.poll();
#endif
    Application::poll();
}

void GraphicalApplication::pollGraphics()
{
    g_graphicsDispatcher.poll();
    g_textures.poll();
    g_text.poll();
    g_window.poll();
}

void GraphicalApplication::close()
{
    VALIDATE(std::this_thread::get_id() == g_dispatcherThreadId);
    m_onInputEvent = true;
    Application::close();
    m_onInputEvent = false;
}

void GraphicalApplication::resize(const Size& size)
{
    VALIDATE(std::this_thread::get_id() == g_mainThreadId);
    g_graphics.resize(size); // uses painter
    scale(m_scaling); // thread safe
}

void GraphicalApplication::inputEvent(InputEvent event)
{
    VALIDATE(std::this_thread::get_id() == g_dispatcherThreadId);
    m_onInputEvent = true;
    g_ui.inputEvent(event);
    m_onInputEvent = false;
}

void GraphicalApplication::doScreenshot(std::string file)
{
    if (g_mainThreadId != std::this_thread::get_id()) {
        g_graphicsDispatcher.addEvent(std::bind(&GraphicalApplication::doScreenshot, this, file));
        return;
    }

    if (file.empty()) {
        file = "screenshot.png";
    }
    auto resolution = g_graphics.getViewportSize();
    int width = resolution.width();
    int height = resolution.height();
    auto pixels = std::make_shared<std::vector<uint8_t>>(width * height * 4 * sizeof(GLubyte), 0);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, (GLubyte*)(pixels->data()));

    g_asyncDispatcher.dispatch([resolution, pixels, file] {
        for (int line = 0, h = resolution.height(), w = resolution.width(); line != h / 2; ++line) {
            std::swap_ranges(
                pixels->begin() + 4 * w * line,
                pixels->begin() + 4 * w * (line + 1),
                pixels->begin() + 4 * w * (h - line - 1));
        }
        try {
            Image image(resolution, 4, pixels->data());
            image.savePNG(file);
        } catch (stdext::exception& e) {
            g_logger.error(std::string("Can't do screenshot: ") + e.what());
        }
    });
}

void GraphicalApplication::scaleUp()
{
    if (g_mainThreadId != std::this_thread::get_id()) {
        g_graphicsDispatcher.addEvent(std::bind(&GraphicalApplication::scaleUp, this));
        return;
    }
    scale(m_scaling + 0.5);
}

void GraphicalApplication::scaleDown()
{
    if (g_mainThreadId != std::this_thread::get_id()) {
        g_graphicsDispatcher.addEvent(std::bind(&GraphicalApplication::scaleDown, this));
        return;
    }
    scale(m_scaling - 0.5);
}

void GraphicalApplication::scale(float value)
{
    if (g_mainThreadId != std::this_thread::get_id()) {
        g_graphicsDispatcher.addEvent(std::bind(&GraphicalApplication::scale, this, value));
        return;
    }

    float maxScale = std::min<float>((g_graphics.getViewportSize().height() / 180),
                                        g_graphics.getViewportSize().width() / 280);
    if (maxScale < 2.0)
        maxScale = 2.0;
    maxScale /= 2;

    if (m_scaling == value) {
        value = m_lastScaling;
    } else {
        m_lastScaling = std::max<float>(1.0, std::min<float>(maxScale, value));
    }

    m_scaling = std::max<float>(1.0, std::min<float>(maxScale, value));
    g_window.setScaling(m_scaling);

    g_dispatcher.addEvent([&] {
        m_onInputEvent = true;
        g_ui.resize(g_graphics.getViewportSize() / m_scaling);
        m_onInputEvent = false;
        m_mustRepaint = true;
    });
}