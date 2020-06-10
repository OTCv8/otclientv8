#include <atomic>
#include <list>
#include "../stdext/time.h"

class FrameCounter {
public:
    void addFrame() // not thread-safe
    {
        ticks_t now = stdext::millis();
        m_framesList.push_back(now);
        m_frames += 1;
        while (m_framesList.front() + 1000 < now) {
            m_framesList.pop_front();
            m_frames -= 1;
        }
    }

    int getFps() // thread safe
    {
        return m_frames.load();
    }

private:
    std::list<ticks_t> m_framesList;
    std::atomic_int m_frames;
};
