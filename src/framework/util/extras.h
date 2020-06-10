#ifndef EXTRAS_H
#define EXTRAS_H

#include <string>
#include <map>
#include <framework/core/logger.h>
#include <deque>

constexpr bool default_value = true;

#define DEFINE_OPTION(option, description) { m_options[ #option ] = std::make_pair(description, &(this -> option )); }

class Extras {
public:
    Extras() {
        DEFINE_OPTION(limitedPolling, "Limited polling");

        DEFINE_OPTION(debugWalking, "Debug walking");
        DEFINE_OPTION(debugPredictiveWalking, "Debug predictive walking");
        DEFINE_OPTION(debugPathfinding, "Debug path finding");
        DEFINE_OPTION(debugRender, "Debug render");
        DEFINE_OPTION(debugProxy, "Debug proxy");
        DEFINE_OPTION(showPredictions, "Show predictions");
        DEFINE_OPTION(debugWidgets, "Debug widgets");

        DEFINE_OPTION(disablePredictiveWalking, "Disable predictive walking");
    }

    bool botDetection = default_value;
    
    bool newMapViewRendering = default_value;
    bool limitedPolling = default_value;

    bool debugWalking  = false;
    bool debugPredictiveWalking = false;
    bool debugPathfinding  = false;
    bool debugRender = false;
    bool debugProxy = false;
    bool disablePredictiveWalking = false;
    bool showPredictions = false;
    bool debugWidgets = false;

    int testMode = 0;

    void set(const std::string& key, bool value) {
        auto it = m_options.find(key);
        if (it == m_options.end()) {
            g_logger.fatal(std::string("Invalid extraOptions key:") + key);
            return;
        }
        *(it->second.second) = value;
    }

    bool get(const std::string& key) {
        auto it = m_options.find(key);
        if (it == m_options.end()) {
            g_logger.fatal(std::string("Invalid extraOptions key:") + key);
            return false;
        }
        return *(it->second.second);
    }

    std::string getDescription(const std::string& key) {
        auto it = m_options.find(key);
        if (it == m_options.end()) {
            g_logger.fatal(std::string("Invalid extraOptions key:") + key);
            return "";
        }
        return it->second.first;
    }

    std::vector<std::string> getAll() {
        std::vector<std::string> ret;
        for (auto& it : m_options)
            ret.push_back(it.first);
        return ret;
    }

private:
    std::map<std::string, std::pair<std::string, bool*>> m_options;
    std::deque<ticks_t> framerRenderTimes;
};

extern Extras g_extras;

#endif