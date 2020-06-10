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

#ifndef PCH_H
#define PCH_H

// common C headers
#include <cstdio>
#include <cstdlib>
#include <cstddef>
#include <cstring>
#include <cmath>

// common STL headers
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <set>
#include <list>
#include <deque>
#include <map>
#include <algorithm>
#include <functional>
#include <array>
#include <unordered_map>
#include <unordered_set>
#include <tuple>
#include <iomanip>
#include <typeinfo>

// new
#include <thread>
#include <memory>
#include <functional>
#include <condition_variable>
#include <mutex>
#include <future>
#include <chrono>
#include <random>
#ifndef ANDROID
#include <filesystem>
#endif

 // boost
#ifdef ANDROID
#define BOOST_UUID_RANDOM_PROVIDER_FORCE_POSIX
#endif
#include <boost/system/config.hpp>
#include <boost/system/error_code.hpp>
#include <boost/asio.hpp>
#include <boost/beast.hpp>

#include <boost/asio/io_service.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <boost/asio/ssl.hpp>

#include <boost/beast/ssl.hpp>
#include <boost/beast/core/flat_buffer.hpp>
#include <boost/beast/http/write.hpp>
#include <boost/beast/http/string_body.hpp>
#include <boost/beast/http/dynamic_body.hpp>
#include <boost/beast/http/read.hpp>
#include <boost/beast/http/parser.hpp>
#include <boost/beast/websocket.hpp>
#include <boost/beast/websocket/ssl.hpp>

#endif
