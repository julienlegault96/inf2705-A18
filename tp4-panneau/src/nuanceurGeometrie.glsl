#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 matrProj;
uniform int texnumero;

in Attribs {
    vec4 couleur;
    float tempsRestant;
    float sens;
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsOut;

void main()
{
    vec2 coins[4]; 
    
    coins[0] = vec2(-0.5,  0.5);
    coins[1] = vec2(-0.5, -0.5);
    coins[2] = vec2( 0.5,  0.5);
    coins[3] = vec2( 0.5, -0.5);

    vec2 coins_reverse[4];
    coins_reverse[0] = vec2( 0.5,  0.5);
    coins_reverse[1] = vec2( 0.5, -0.5);
    coins_reverse[2] = vec2(-0.5,  0.5);
    coins_reverse[3] = vec2(-0.5, -0.5);
    
    for ( int i = 0 ; i < 4 ; i++ ) {
        vec2 texCoord = vec2(0.0, 0.0); 
        if (texnumero == 1) {
            texCoord = coins[i] + vec2(0.5, 0.5);
            float rotationSpeed = 6.0;
            float angle = rotationSpeed * AttribsIn[0].tempsRestant;
            mat2 rotationMatrix = mat2( vec2(cos(angle), -sin(angle)),
                                        vec2(sin(angle),  cos(angle)) );
            coins[i] *= rotationMatrix;
        } else if (texnumero == 2 || texnumero == 3) {
            if (sign(AttribsIn[0].sens) == 1.0) {
                texCoord = coins[i] + vec2(0.5, 0.5);
            }
            else {
                texCoord = coins_reverse[i] + vec2(0.5, 0.5);   
            }
            float animationSpeed = 20.0;
            int spriteIndex = int (animationSpeed * AttribsIn[0].tempsRestant) % 16;
            texCoord.x = clamp( texCoord.x, float(spriteIndex) / 16, float(spriteIndex + 1) / 16 );
        }
        
        float sizeFactor = gl_in[0].gl_PointSize / 50;
        gl_PointSize = gl_in[0].gl_PointSize;
        gl_Position = matrProj * vec4( gl_in[0].gl_Position.xy + sizeFactor * coins[i],
                                    gl_in[0].gl_Position.zw );
        AttribsOut.couleur = AttribsIn[0].couleur;
        AttribsOut.texCoord = texCoord;

        EmitVertex();
    }
}
