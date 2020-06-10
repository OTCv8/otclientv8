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

#include "eventdispatcher.h"

#include <framework/core/clock.h>
#include <framework/core/graphicalapplication.h>
#include <framework/util/stats.h>
#include "timer.h"

EventDispatcher g_dispatcher;
EventDispatcher g_graphicsDispatcher;
std::thread::id g_mainThreadId = std::this_thread::get_id();
std::thread::id g_dispatcherThreadId = std::this_thread::get_id();

void EventDispatcher::shutdown()
{
    while(!m_eventList.empty())
        poll();

    while(!m_scheduledEventList.empty()) {
        ScheduledEventPtr scheduledEvent = m_scheduledEventList.top();
        scheduledEvent->cancel();
        m_scheduledEventList.pop();
    }
    m_disabled = true;
}

void EventDispatcher::poll()
{
    AutoStat s(this == &g_dispatcher ? STATS_MAIN : STATS_RENDER, "PollDispatcher");
    std::unique_lock<std::recursive_mutex> lock(m_mutex);

    int loops = 0;
    for(int count = 0, max = m_scheduledEventList.size(); count < max && !m_scheduledEventList.empty(); ++count) {
        ScheduledEventPtr scheduledEvent = m_scheduledEventList.top();
        if(scheduledEvent->remainingTicks() > 0)
            break;
        m_scheduledEventList.pop();
        {
            AutoStat s2(STATS_DISPATCHER, scheduledEvent->getFunction());
            m_botSafe = scheduledEvent->isBotSafe();
            m_mutex.unlock();
            scheduledEvent->execute();
            m_mutex.lock();
        }

        if(scheduledEvent->nextCycle())
            m_scheduledEventList.push(scheduledEvent);
    }

    // execute events list until all events are out, this is needed because some events can schedule new events that would
    // change the UIWidgets layout, in this case we must execute these new events before we continue rendering,
    m_pollEventsSize = m_eventList.size();
    loops = 0;
    while(m_pollEventsSize > 0) {
        if(loops > 50) {
            static Timer reportTimer;
            if(reportTimer.running() && reportTimer.ticksElapsed() > 100) {
                std::stringstream ss;
                ss << "ATTENTION the event list is not getting empty, this could be caused by some bad code.\nLog:\n";
                for (auto& event : m_eventList) {
                    ss << event->getFunction() << "\n";
                    if (ss.str().size() > 1024) break;
                }
                g_logger.error(ss.str());                
                reportTimer.restart();
            }
            break;
        }

        for(int i=0;i<m_pollEventsSize;++i) {
            EventPtr event = m_eventList.front();
            m_eventList.pop_front();
            {
                AutoStat s2(STATS_DISPATCHER, event->getFunction());
                m_botSafe = event->isBotSafe();
                m_mutex.unlock();
                event->execute();
                m_mutex.lock();
            }
        }
        m_pollEventsSize = m_eventList.size();
        
        loops++;
    }

    m_botSafe = false;
}

ScheduledEventPtr EventDispatcher::scheduleEventEx(const std::string& function, const std::function<void()>& callback, int delay)
{
    if(m_disabled)
        return ScheduledEventPtr(new ScheduledEvent("", nullptr, delay, 1));

    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    VALIDATE(delay >= 0);
    ScheduledEventPtr scheduledEvent(new ScheduledEvent(function, callback, delay, 1, g_app.isOnInputEvent()));
    m_scheduledEventList.push(scheduledEvent);
    return scheduledEvent;
}

ScheduledEventPtr EventDispatcher::cycleEventEx(const std::string& function, const std::function<void()>& callback, int delay)
{
    if(m_disabled)
        return ScheduledEventPtr(new ScheduledEvent("", nullptr, delay, 0));

    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    VALIDATE(delay > 0);
    ScheduledEventPtr scheduledEvent(new ScheduledEvent(function, callback, delay, 0, g_app.isOnInputEvent()));
    m_scheduledEventList.push(scheduledEvent);
    return scheduledEvent;
}

EventPtr EventDispatcher::addEventEx(const std::string& function, const std::function<void()>& callback, bool pushFront)
{
    if(m_disabled)
        return EventPtr(new Event("", nullptr));

    EventPtr event(new Event(function, callback, g_app.isOnInputEvent()));

    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    // front pushing is a way to execute an event before others
    if(pushFront) {
        m_eventList.push_front(event);
        // the poll event list only grows when pushing into front
        m_pollEventsSize++;
    } else
        m_eventList.push_back(event);
    return event;
}

