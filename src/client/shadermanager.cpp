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

ShaderManager g_shaders;

void ShaderManager::init()
{
    PainterShaderProgram::release();
}

void ShaderManager::terminate()
{
    m_shaders.clear();
}

PainterShaderProgramPtr ShaderManager::createShader(const std::string& name)
{
    return nullptr;
}

PainterShaderProgramPtr ShaderManager::createFragmentShader(const std::string& name, std::string file)
{
    return nullptr;
}

PainterShaderProgramPtr ShaderManager::createFragmentShaderFromCode(const std::string& name, const std::string& code)
{
    return nullptr;
}

PainterShaderProgramPtr ShaderManager::createItemShader(const std::string& name, const std::string& file)
{
    PainterShaderProgramPtr shader = createFragmentShader(name, file);
    if(shader)
        setupItemShader(shader);
    return shader;
}

PainterShaderProgramPtr ShaderManager::createMapShader(const std::string& name, const std::string& file)
{
    PainterShaderProgramPtr shader = createFragmentShader(name, file);
    if(shader)
        setupMapShader(shader);
    return shader;
}

void ShaderManager::setupItemShader(const PainterShaderProgramPtr& shader)
{
    if (!shader)
        return;
}

void ShaderManager::setupMapShader(const PainterShaderProgramPtr& shader)
{
    if(!shader)
        return;
}

PainterShaderProgramPtr ShaderManager::getShader(const std::string& name)
{
    auto it = m_shaders.find(name);
    if(it != m_shaders.end())
        return it->second;
    return nullptr;
}

