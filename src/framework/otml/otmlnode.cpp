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

#include "otmlnode.h"
#include "otmlemitter.h"
#include "otmldocument.h"

#include <framework/util/extras.h>

OTMLNodePtr OTMLNode::create(std::string tag, bool unique)
{
    OTMLNodePtr node(new OTMLNode);
    node->setTag(tag);
    node->setUnique(unique);
    return node;
}

OTMLNodePtr OTMLNode::create(std::string tag, std::string value)
{
    OTMLNodePtr node(new OTMLNode);
    node->setTag(tag);
    node->setValue(value);
    node->setUnique(true);
    return node;
}

bool OTMLNode::hasChildren()
{
    for(const OTMLNodePtr& child : m_children) {
        if (!child->isNull())
            return true;
    }
    return false;
}

OTMLNodePtr OTMLNode::get(const std::string& childTag)
{
    //if (g_extras.OTMLChildIdCache) {
        if (childTag.size() > 0 && childTag[0] == '!')
            g_logger.fatal(stdext::format("Invalid childTag %s", childTag));
        auto it = m_childrenTagCache.find(childTag);
        if (it != m_childrenTagCache.end() && !it->second->isNull())
            return it->second;
    //} 

    for(const OTMLNodePtr& child : m_children) {
        if (child->tag() == childTag && !child->isNull()) {
            std::string tag = child->tag();
            if (tag.size() > 0 && tag[0] == '!')
                tag = tag.substr(1);
            m_childrenTagCache[tag] = child;
            child->lockTag();
            return child;
        }
    }
    return nullptr;
}

OTMLNodePtr OTMLNode::getIndex(int childIndex)
{
    if(childIndex < size() && childIndex >= 0)
        return m_children[childIndex];
    return nullptr;
}

OTMLNodePtr OTMLNode::at(const std::string& childTag)
{
    OTMLNodePtr res;
    for(const OTMLNodePtr& child : m_children) {
        if(child->tag() == childTag && !child->isNull()) {
            res = child;
            break;
        }
    }
    if(!res)
        throw OTMLException(asOTMLNode(), stdext::format("child node with tag '%s' not found", childTag));
    return res;
}

OTMLNodePtr OTMLNode::atIndex(int childIndex)
{
    if(childIndex >= size() || childIndex < 0)
        throw OTMLException(asOTMLNode(), stdext::format("child node with index '%d' not found", childIndex));
    return m_children[childIndex];
}

void OTMLNode::addChild(const OTMLNodePtr& newChild)
{
    // replace is needed when the tag is marked as unique
    if(newChild->hasTag()) {
        for(const OTMLNodePtr& node : m_children) {
            if(node->tag() == newChild->tag() && (node->isUnique() || newChild->isUnique())) {
                newChild->setUnique(true);

                if(node->hasChildren() && newChild->hasChildren()) {
                    OTMLNodePtr tmpNode = node->clone();
                    tmpNode->merge(newChild);
                    newChild->copy(tmpNode);
                }

                replaceChild(node, newChild);

                // remove any other child with the same tag
                auto it = m_children.begin();
                while(it != m_children.end()) {
                    OTMLNodePtr node = (*it);
                    if(node != newChild && node->tag() == newChild->tag()) {
                        std::string tag = newChild->tag();
                        if (tag.size() > 0 && tag[0] == '!')
                            tag = tag.substr(1);
                        auto cacheIt = m_childrenTagCache.find(tag);
                        if (cacheIt != m_childrenTagCache.end()) {
                            if (cacheIt->second != newChild) {
                                m_childrenTagCache.erase(cacheIt);
                                m_childrenTagCache[tag] = newChild;
                                newChild->lockTag();
                            }
                        }
                        it = m_children.erase(it);
                    } else
                        ++it;
                }
                return;
            }
        }
    }

    m_children.push_back(newChild);
    std::string tag = newChild->tag();
    if (tag.size() > 0 && tag[0] == '!')
        tag = tag.substr(1);
    m_childrenTagCache[tag] = newChild;
    newChild->lockTag();
}

bool OTMLNode::removeChild(const OTMLNodePtr& oldChild)
{
    auto it = std::find(m_children.begin(), m_children.end(), oldChild);
    if(it != m_children.end()) {
        m_children.erase(it);
        m_childrenTagCache.erase((*it)->tag());
        return true;
    }
    return false;
}

bool OTMLNode::replaceChild(const OTMLNodePtr& oldChild, const OTMLNodePtr& newChild)
{
    auto it = std::find(m_children.begin(), m_children.end(), oldChild);
    if(it != m_children.end()) {
        std::string tag = (*it)->tag();
        if (tag.size() > 0 && tag[0] == '!')
            tag = tag.substr(1);
        auto cacheIt = m_childrenTagCache.find(tag);
        if (cacheIt != m_childrenTagCache.end()) {
            if (cacheIt->second == (*it))
                m_childrenTagCache.erase(cacheIt);
        }
        it = m_children.erase(it);

        m_children.insert(it, newChild);
        tag = newChild->tag();
        if (tag.size() > 0 && tag[0] == '!')
            tag = tag.substr(1);
        m_childrenTagCache[tag] = newChild;
        newChild->lockTag();
        return true;
    }
    return false;
}

void OTMLNode::copy(const OTMLNodePtr& node)
{
    setTag(node->tag());
    setValue(node->rawValue());
    setUnique(node->isUnique());
    setNull(node->isNull());
    setSource(node->source());
    clear();
    for(const OTMLNodePtr& child : node->m_children)
        addChild(child->clone());
}

void OTMLNode::merge(const OTMLNodePtr& node)
{
    for(const OTMLNodePtr& child : node->m_children)
        addChild(child->clone());
    setTag(node->tag());
    setSource(node->source());
}

void OTMLNode::clear()
{
    m_children.clear();
    m_childrenTagCache.clear();
}

OTMLNodeList OTMLNode::children()
{
    OTMLNodeList children;
    for(const OTMLNodePtr& child : m_children)
        if(!child->isNull())
            children.push_back(child);
    return children;
}

OTMLNodePtr OTMLNode::clone()
{
    OTMLNodePtr myClone(new OTMLNode);
    myClone->setTag(m_tag);
    myClone->setValue(m_value);
    myClone->setUnique(m_unique);
    myClone->setNull(m_null);
    myClone->setSource(m_source);
    for(const OTMLNodePtr& child : m_children)
        myClone->addChild(child->clone());
    return myClone;
}

std::string OTMLNode::emit()
{
    return OTMLEmitter::emitNode(asOTMLNode(), 0);
}

void OTMLNode::setTag(const std::string& tag) { 
    if (m_tagLocked && tag != m_tag) {
        std::string correct_tag = m_tag;
        if (correct_tag.size() > 0 && m_tag[0] == '!')
            correct_tag = correct_tag.substr(1);
        if(correct_tag != tag)
            g_logger.fatal(stdext::format("Trying to setTag for locked QTMLNode %s to %s", m_tag, tag));
    }
    m_tag = tag; 
}
