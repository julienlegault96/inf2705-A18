#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

uniform float pointsize;

layout(location=0) in vec4 Vertex;
layout(location=3) in vec4 Color;
layout(location=4) in vec3 vitesse;
layout(location=5) in float tempsRestant;

out Attribs {
    vec4 couleur;
    float tempsRestant;
    float sens;
} AttribsOut;

void main( void )
{
    // transformation standard du sommet
    gl_Position = matrVisu * matrModel * Vertex;

    AttribsOut.tempsRestant = tempsRestant;

    // couleur du sommet
    AttribsOut.couleur = Color;

    // sens du vol par rapport a la camera
    AttribsOut.sens = (matrVisu * vec4(vitesse, 1.0)).x;

    // assigner la taille des points (en pixels)
    gl_PointSize = pointsize;
}
