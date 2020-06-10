#ifndef NEWSHADER_H
#define NEWSHADER_H

#include <string>
// VERTEX
static const std::string newVertexShader = "\n\
    attribute vec2 a_Vertex;\n\
    attribute vec2 a_TexCoord;\n\
    attribute vec4 a_Color;\n\
    \n\
    uniform mat3 u_ProjectionMatrix;\n\
    uniform mat3 u_TransformMatrix;\n\
    uniform mat3 u_TextureMatrix;\n\
    \n\
    varying vec2 v_TexCoord;\n\
    varying vec4 v_Color;\n\
    void main()\n\
    {\n\
        gl_Position = vec4((u_ProjectionMatrix * u_TransformMatrix * vec3(a_Vertex.xy, 1.0)).xy, 1.0, 1.0);\n\
        v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord,1.0)).xy;\n\
        v_Color = a_Color;\n\
    }\n";

// TEXT
static const std::string textVertexShader = "\n\
    attribute vec2 a_TexCoord;\n\
    uniform mat3 u_TextureMatrix;\n\
    varying vec2 v_TexCoord;\n\
    attribute vec2 a_Vertex;\n\
    uniform mat3 u_TransformMatrix;\n\
    uniform mat3 u_ProjectionMatrix;\n\
    uniform float u_Depth;\n\
    uniform vec2 u_Offset;\n\
    void main()\n\
    {\n\
        gl_Position = vec4((u_ProjectionMatrix * u_TransformMatrix * vec3(a_Vertex.xy + u_Offset, 1.0)).xy, u_Depth / 16384.0, 1.0);\n\
        v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord,1.0)).xy;\n\
    }\n";

// FRAGMENT
static const std::string newFragmentShader = "\n\
    varying vec2 v_TexCoord;\n\
    varying vec4 v_Color;\n\
    uniform sampler2D u_Atlas;\n\
    void main()\n\
    {\n\
        if(v_TexCoord.x < 0.0) { gl_FragColor = v_Color; return; }\n\
        gl_FragColor = texture2D(u_Atlas, v_TexCoord) * v_Color;\n\
    }\n";

// TEXT
static const std::string textFragmentShader = "\n\
    varying vec2 v_TexCoord;\n\
    uniform vec4 u_Color;\n\
    uniform sampler2D u_Fonts;\n\
    void main()\n\
    {\n\
        gl_FragColor = texture2D(u_Fonts, v_TexCoord) * u_Color;\n\
    }\n";

#endif