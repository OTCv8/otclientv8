
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;

uniform vec4 u_Color;
uniform sampler2D u_Tex0;
uniform sampler2D u_Tex1;

void main()
{
    gl_FragColor = texture2D(u_Tex0, v_TexCoord) * u_Color;
    gl_FragColor += texture2D(u_Tex1, v_TexCoord2);
    if(gl_FragColor.a < 0.01)
        discard;
}
