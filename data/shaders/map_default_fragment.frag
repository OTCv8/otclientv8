
varying vec2 v_TexCoord;
uniform vec4 u_Color;
uniform sampler2D u_Tex0;

void main()
{
    gl_FragColor = texture2D(u_Tex0, v_TexCoord) * u_Color;
    if(gl_FragColor.a < 0.01)
        discard;
}
