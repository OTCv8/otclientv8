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

#include "statictext.h"
#include "map.h"
#include <framework/core/clock.h>
#include <framework/core/eventdispatcher.h>
#include <framework/graphics/graphics.h>
#include <framework/graphics/fontmanager.h>

StaticText::StaticText()
{
    m_mode = Otc::MessageNone;
    m_color = Color::white;
    m_cachedText.setFont(g_fonts.getFont("verdana-11px-rounded"));
    m_cachedText.setAlign(Fw::AlignCenter);
}

void StaticText::drawText(const Point& dest, const Rect& parentRect)
{
    Size textSize = m_cachedText.getTextSize();
    Rect rect = Rect(dest - Point(textSize.width() / 2, textSize.height()) + Point(20, 5), textSize);
    Rect boundRect = rect;
    boundRect.bind(parentRect);

    // draw only if the real center is not too far from the parent center, or its a yell
    //if(g_map.isAwareOfPosition(m_position) || isYell()) {
        m_cachedText.draw(boundRect, m_color);
    //}
}

void StaticText::setFont(const std::string& fontName)
{
    m_cachedText.setFont(g_fonts.getFont(fontName));
}

void StaticText::setText(const std::string& text)
{
    m_cachedText.setText(text);
}

bool StaticText::addMessage(const std::string& name, Otc::MessageMode mode, const std::string& text)
{
    return addColoredMessage(name, mode, { text, "" });
}

bool StaticText::addColoredMessage(const std::string& name, Otc::MessageMode mode, const std::vector<std::string>& texts)
{
    if (texts.empty() || texts.size() % 2 != 0)
        return false;
    //TODO: this could be moved to lua
    // first message
    if (m_messages.size() == 0) {
        m_name = name;
        m_mode = mode;
    }
    // check if we can really own the message
    else if (m_name != name || m_mode != mode) {
        return false;
    }
    // too many messages
    else if (m_messages.size() > 10) {
        m_messages.pop_front();
        m_updateEvent->cancel();
        m_updateEvent = nullptr;
    }

    size_t len = 0;
    for (size_t i = 0; i < texts.size(); i += 2) {
        len += texts[i].length();
    }

    int delay = std::max<int>(Otc::STATIC_DURATION_PER_CHARACTER * len, Otc::MIN_STATIC_TEXT_DURATION);
    if (isYell())
        delay *= 2;

    m_messages.push_back(StaticTextMessage{ texts, g_clock.millis() + delay });
    compose();

    if (!m_updateEvent)
        scheduleUpdate();
    return true;
}

void StaticText::update()
{
    m_messages.pop_front();
    if(m_messages.empty()) {
        // schedule removal
        auto self = asStaticText();
        g_dispatcher.addEvent([self]() { g_map.removeThing(self); });
    } else {
        compose();
        scheduleUpdate();
    }
}

void StaticText::scheduleUpdate()
{
    int delay = std::max<int>(m_messages.front().time - g_clock.millis(), 0);

    auto self = asStaticText();
    m_updateEvent = g_dispatcher.scheduleEvent([self]() {
        self->m_updateEvent = nullptr;
        self->update();
    }, delay);
}

void StaticText::compose()
{
    //TODO: this could be moved to lua
    std::vector<std::string> texts;

    if(m_mode == Otc::MessageSay) {
        texts.push_back(m_name + " says:\n");
        texts.push_back("#EFEF00");
        m_color = Color(239, 239, 0);
    } else if(m_mode == Otc::MessageWhisper) {
        texts.push_back(m_name + " whispers:\n");
        texts.push_back("#EFEF00");
        m_color = Color(239, 239, 0);
    } else if(m_mode == Otc::MessageYell) {
        texts.push_back(m_name + " yells:\n");
        texts.push_back("#EFEF00");
        m_color = Color(239, 239, 0);
    } else if(m_mode == Otc::MessageMonsterSay || m_mode == Otc::MessageMonsterYell || m_mode == Otc::MessageSpell
              || m_mode == Otc::MessageBarkLow || m_mode == Otc::MessageBarkLoud) {
        m_color = Color(254, 101, 0);
    } else if(m_mode == Otc::MessageNpcFrom || m_mode == Otc::MessageNpcFromStartBlock) {
        texts.push_back(m_name + " says:\n");
        texts.push_back("#5FF7F7");
        m_color = Color(95, 247, 247);
    } else {
        g_logger.warning(stdext::format("Unknown speak type: %d", m_mode));
    }

    for(uint i = 0; i < m_messages.size(); ++i) {
        for (size_t j = 0; j < m_messages[i].texts.size() - 1; j += 2) {
            texts.push_back(m_messages[i].texts[j]);
            texts.push_back(m_messages[i].texts[j + 1].empty() ? m_color.toHex() : m_messages[i].texts[j + 1]);
        }
        if (texts.size() >= 2 && i < m_messages.size() - 1) {
            texts[texts.size() - 2] += "\n";
        }
    }

    m_cachedText.setColoredText(texts);
    m_cachedText.wrapText(275);
}
