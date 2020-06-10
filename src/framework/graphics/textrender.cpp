#include "painter.h"
#include "textrender.h"
#include <framework/core/logger.h>

TextRender g_text;

void TextRender::init()
{

}

void TextRender::terminate()
{
    for (auto& cache : m_cache) {
        cache.clear();
    }
}

void TextRender::poll()
{
    static int iteration = 0;
    int index = (iteration++) % INDEXES;
    std::lock_guard<std::mutex> lock(m_mutex[index]);
    auto& cache = m_cache[index];
    if (cache.size() < 100)
        return;

    ticks_t dropPoint = g_clock.millis();
    if (cache.size() > 500)
        dropPoint -= 10;
    else if (cache.size() > 250)
        dropPoint -= 100;
    else
        dropPoint -= 1000;

    for (auto it = cache.begin(); it != cache.end(); ) {
        if (it->second->lastUse < dropPoint) {
            it = cache.erase(it);
            continue;
        }
        ++it;
    }
}

uint64_t TextRender::addText(BitmapFontPtr font, const std::string& text, const Size& size, Fw::AlignmentFlag align)
{
    uint64_t hash = 1125899906842597ULL;
    for (size_t i = 0; i < text.length(); ++i) {
        hash = hash * 31 + text[i];
    }
    hash = hash * 31 + size.width();
    hash = hash * 31 + size.height();
    hash = hash * 31 + (uint64_t)align;
    hash = hash * 31 + (uint64_t)font->getId();

    int index = hash % INDEXES;
    m_mutex[index].lock();
    auto it = m_cache[index].find(hash);
    if (it == m_cache[index].end()) {
        m_cache[index][hash] = std::shared_ptr<TextRenderCache>(new TextRenderCache{ font, text, size, align, font->getTexture(), CoordsBuffer(), g_clock.millis() });
    }
    m_mutex[index].unlock();
    return hash;
}

void TextRender::drawText(const Point& pos, uint64_t hash, const Color& color)
{
    int index = hash % INDEXES;
    m_mutex[index].lock();
    auto _it = m_cache[index].find(hash);
    if (_it == m_cache[index].end()) {
        m_mutex[index].unlock();
        return;
    }
    auto it = _it->second;
    m_mutex[index].unlock();
    if (it->font) { // calculate text coords
        it->font->calculateDrawTextCoords(it->coords, it->text, Rect(0, 0, it->size), it->align);
        it->coords.cache();
        it->text.clear();
        it->font.reset();
    }
    it->lastUse = g_clock.millis();
    g_painterNew->drawText(pos, it->coords, color);
}

void TextRender::drawColoredText(const Point& pos, uint64_t hash, const std::vector<std::pair<int, Color>>& colors)
{
    if (colors.empty())
        return drawText(pos, hash, Color::white);
    int index = hash % INDEXES;
    m_mutex[index].lock();
    auto _it = m_cache[index].find(hash);
    if (_it == m_cache[index].end()) {
        m_mutex[index].unlock();
        return;
    }
    auto it = _it->second;
    m_mutex[index].unlock();
    if (it->font) { // calculate text coords
        it->font->calculateDrawTextCoords(it->coords, it->text, Rect(0, 0, it->size), it->align);
        it->coords.cache();
        it->text.clear();
        it->font.reset();
    }
    it->lastUse = g_clock.millis();
    g_painterNew->drawText(pos, it->coords, colors);
}

