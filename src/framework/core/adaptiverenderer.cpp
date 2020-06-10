#include <framework/core/logger.h>
#include <framework/core/graphicalapplication.h>
#include <framework/stdext/format.h>
#include <framework/util/extras.h>

#include "adaptiverenderer.h"

AdaptiveRenderer g_adaptiveRenderer;

void AdaptiveRenderer::newFrame() {
    auto now = stdext::millis();
    m_frames.push_back(now);
    while (m_frames.front() + 5000 < now) {
        m_frames.pop_front();
    }

    if (m_forcedSpeed >= 0 && m_forcedSpeed <= 4) {
        m_speed = m_forcedSpeed;
        return;
    }

    if (m_update + 5000 > now)
        return;

    m_update = stdext::millis();

    if (m_speed < 1)
        m_speed = 1;

    int maxFps = std::min<int>(100, std::max<int>(10, g_app.getMaxFps() < 10 ? 100 : g_app.getMaxFps()));
    if (m_speed >= 2 && maxFps > 60) { // fix for forced vsync
        maxFps = 60;
    }

    if (m_frames.size() < maxFps * (4.0f - m_speed * 0.3f) && m_speed != RenderSpeeds - 1) {
        m_speed += 1;
    }
    if (m_frames.size() > maxFps * (4.5f - m_speed * 0.1f) && m_speed > 1) {
        m_speed -= 1;
    }
}

void AdaptiveRenderer::refresh() {
    m_update = stdext::millis();
}

int AdaptiveRenderer::effetsLimit() {
    static int limits[RenderSpeeds] = { 20, 10, 7, 4, 2 };
    return limits[m_speed];
}

int AdaptiveRenderer::creaturesLimit() {
    static int limits[RenderSpeeds] = { 20, 10, 7, 5, 3 };
    return limits[m_speed];
}

int AdaptiveRenderer::itemsLimit() {
    static int limits[RenderSpeeds] = { 20, 10, 7, 5, 3 };
    return limits[m_speed];
}

int AdaptiveRenderer::mapRenderInterval() {
    static int limits[RenderSpeeds] = { 0, 10, 20, 50, 100 };
    return limits[m_speed];
}

int AdaptiveRenderer::textsLimit() {
    static int limits[RenderSpeeds] = { 1000, 50, 30, 15, 5 };
    return limits[m_speed];
}

int AdaptiveRenderer::creaturesRenderInterval() {
    // not working yet
    static int limits[RenderSpeeds] = { 0, 0, 10, 15, 20 };
    return limits[m_speed];
}

bool AdaptiveRenderer::allowFading() {
    return m_speed <= 2;
}

int AdaptiveRenderer::foregroundUpdateInterval() {
    static int limits[RenderSpeeds] = { 0, 20, 40, 50, 60 };
    return limits[m_speed];
}

std::string AdaptiveRenderer::getDebugInfo() {
    std::stringstream ss;
    ss << "Frames: " << m_frames.size() << "|" << m_speed << "|" << m_forcedSpeed;
    return ss.str();
}