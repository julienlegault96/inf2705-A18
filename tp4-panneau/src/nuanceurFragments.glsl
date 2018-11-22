#version 410

uniform sampler2D laTexture;
uniform int texnumero;

in Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsIn;

out vec4 FragColor;

void main( void )
{
    if (texnumero == 0) {
        FragColor = AttribsIn.couleur;
        return;
    }

    vec4 texColor = texture(laTexture, AttribsIn.texCoord);
    if ( texColor.a < 0.1 ) {
        discard;
    }
    
    FragColor = mix(AttribsIn.couleur, texColor, 0.7);
}
