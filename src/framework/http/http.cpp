#include <framework/luaengine/luainterface.h>
#include <framework/util/crypt.h>
#include <framework/util/stats.h>
#include <framework/core/eventdispatcher.h>

#include "http.h"
#include "session.h"
#include "websocket.h"

Http g_http;

void Http::init() {
    m_working = true;
    m_thread = std::thread([&] {
        m_ios.run();
    });
}

void Http::terminate() {
    if (!m_working)
        return;
    m_working = false;
    for (auto& ws : m_websockets) {
        ws.second->close();
    }
    for (auto& op : m_operations) {
        op.second->canceled = true;
    }
    m_guard.reset();
    if (!m_thread.joinable()) {
        stdext::millisleep(100);
        m_ios.stop();
    }
    m_thread.join();
}

int Http::get(const std::string& url, int timeout) {
    if (!timeout) // lua is not working with default values
        timeout = 5;
    int operationId = m_operationId++;

    boost::asio::post(m_ios, [&, url, timeout, operationId] {
        auto result = std::make_shared<HttpResult>();
        result->url = url;
        result->operationId = operationId;
        m_operations[operationId] = result;
        auto session = std::make_shared<HttpSession>(m_ios, url, timeout, result, [&](HttpResult_ptr result) {
            bool finished = result->finished;
            g_dispatcher.addEventEx("Http::onGet", [result, finished]() {
                if (!finished) {
                    g_lua.callGlobalField("g_http", "onGetProgress", result->operationId, result->url, result->progress);
                    return;
                }
                g_lua.callGlobalField("g_http", "onGet", result->operationId, result->url, result->error, std::string(result->response.begin(), result->response.end()));
            });
            if (finished) {
                m_operations.erase(operationId);
            }
        });
        session->start();
    });

    return operationId;
}

int Http::post(const std::string& url, const std::string& data, int timeout) {
    if (!timeout) // lua is not working with default values
        timeout = 5;
    if (data.empty()) {
        g_logger.error(stdext::format("Invalid post request for %s, empty data, use get instead", url));
        return -1;
    }

    int operationId = m_operationId++;
    boost::asio::post(m_ios, [&, url, data, timeout, operationId] {
        auto result = std::make_shared<HttpResult>();
        result->url = url;
        result->operationId = operationId;
        result->postData = data;
        m_operations[operationId] = result;
        auto session = std::make_shared<HttpSession>(m_ios, url, timeout, result, [&](HttpResult_ptr result) {
            bool finished = result->finished;
            g_dispatcher.addEventEx("Http::onPost", [result, finished]() {
                if (!finished) {
                    g_lua.callGlobalField("g_http", "onPostProgress", result->operationId, result->url, result->progress);
                    return;
                }
                g_lua.callGlobalField("g_http", "onPost", result->operationId, result->url, result->error, std::string(result->response.begin(), result->response.end()));
            });
            if (finished) {
                m_operations.erase(operationId);
            }
        });
        session->start();
    });
    return operationId;
}

int Http::download(const std::string& url, std::string path, int timeout) {
    if (!timeout) // lua is not working with default values
        timeout = 5;

    int operationId = m_operationId++;
    boost::asio::post(m_ios, [&, url, path, timeout, operationId] {
        auto result = std::make_shared<HttpResult>();
        result->url = url;
        result->operationId = operationId;
        m_operations[operationId] = result;
        auto session = std::make_shared<HttpSession>(m_ios, url, timeout, result, [&, path](HttpResult_ptr result) {
            m_speed = ((result->size) * 10) / (1 + stdext::micros() - m_lastSpeedUpdate);
            m_lastSpeedUpdate = stdext::micros();

            if (!result->finished) {
                int speed = m_speed;
                g_dispatcher.addEventEx("Http::onDownloadProgress", [result, speed]() {
                    g_lua.callGlobalField("g_http", "onDownloadProgress", result->operationId, result->url, result->progress, speed);
                });
                return;
            }
            std::string checksum = g_crypt.crc32(std::string(result->response.begin(), result->response.end()), false);
            g_dispatcher.addEventEx("Http::onDownload", [&, result, path, checksum]() {
                if (result->error.empty()) {
                    if (!path.empty() && path[0] == '/')
                        m_downloads[path.substr(1)] = result;
                    else
                        m_downloads[path] = result;
                }
                g_lua.callGlobalField("g_http", "onDownload", result->operationId, result->url, result->error, path, checksum);
            });
            m_operations.erase(operationId);
        });
        session->start();
    });
    return operationId;
}

int Http::ws(const std::string& url, int timeout)
{
    if (!timeout) // lua is not working with default values
        timeout = 5;
    int operationId = m_operationId++;

    boost::asio::post(m_ios, [&, url, timeout, operationId] {
        auto result = std::make_shared<HttpResult>();
        result->url = url;
        result->operationId = operationId;
        m_operations[operationId] = result;
        auto session = std::make_shared<WebsocketSession>(m_ios, url, timeout, result, [&, result](WebsocketCallbackType type, std::string message) {
            g_dispatcher.addEventEx("Http::ws", [result, type, message]() {
                if (type == WEBSOCKET_OPEN) {
                    g_lua.callGlobalField("g_http", "onWsOpen", result->operationId, message);
                } else if (type == WEBSOCKET_MESSAGE) {
                    g_lua.callGlobalField("g_http", "onWsMessage", result->operationId, message);
                } else if (type == WEBSOCKET_CLOSE) {
                    g_lua.callGlobalField("g_http", "onWsClose", result->operationId, message);
                } else if (type == WEBSOCKET_ERROR) {
                    g_lua.callGlobalField("g_http", "onWsError", result->operationId, message);
                }
            });
            if (type == WEBSOCKET_CLOSE) {
                m_websockets.erase(result->operationId);
            }
        });
        m_websockets[result->operationId] = session;
        session->start();
    });

    return operationId;
}

bool Http::wsSend(int operationId, std::string message)
{
    boost::asio::post(m_ios, [&, operationId, message] {
        auto wit = m_websockets.find(operationId);
        if (wit == m_websockets.end()) {
            return;
        }
        wit->second->send(message);
    });
    return true;
}

bool Http::wsClose(int operationId)
{
    cancel(operationId);
    return true;
}


bool Http::cancel(int id) {
    boost::asio::post(m_ios, [&, id] {
        auto wit = m_websockets.find(id);
        if (wit != m_websockets.end()) {
            wit->second->close();
        }
        auto it = m_operations.find(id);
        if (it == m_operations.end())
            return;
        if (it->second->canceled)
            return;
        it->second->canceled = true;
    });
    return true;
}

