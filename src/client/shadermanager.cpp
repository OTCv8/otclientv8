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

#include "shadermanager.h"
#include <framework/graphics/paintershaderprogram.h>
#include <framework/graphics/graphics.h>
#include <framework/core/resourcemanager.h>
#include <framework/core/eventdispatcher.h>

ShaderManager g_shaders;

void ShaderManager::init()
{
    PainterShaderProgram::release();
}

void ShaderManager::terminate()
{
    m_shaders.clear();
}

void ShaderManager::createShader(const std::string& name, std::string vertex, std::string fragment, bool colorMatrix)
{
    if (vertex.find("\n") == std::string::npos) { // file
        vertex = g_resources.guessFilePath(vertex, "frag");
        vertex = g_resources.readFileContents(vertex);
    }
    if (fragment.find("\n") == std::string::npos) { // file
        fragment = g_resources.guessFilePath(fragment, "frag");
        fragment = g_resources.readFileContents(fragment);
    }

    g_graphicsDispatcher.addEventEx("createShader", [&, name, vertex, fragment, colorMatrix] {
        auto program = PainterShaderProgram::create(vertex, fragment, colorMatrix);
        if (program)
            m_shaders[name] = program;
    });
}

void ShaderManager::addTexture(const std::string& name, const std::string& file)
{
    g_graphicsDispatcher.addEventEx("addTexture", [&, name, file] {
        auto program = getShader(name);
        if (program)
            program->addMultiTexture(file);
    });
}

PainterShaderProgramPtr ShaderManager::getShader(const std::string& name)
{
    VALIDATE_GRAPHICS_THREAD();
    auto it = m_shaders.find(name);
    if(it != m_shaders.end())
        return it->second;
    return nullptr;
}

