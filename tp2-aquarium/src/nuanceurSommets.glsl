#version 410

const float M_PI = 3.14159265358979323846;	// pi
const float M_PI_2 = 1.57079632679489661923;	// pi/2

uniform int modeSelection;
uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

uniform vec4 planDragage; // équation du plan de dragage
uniform vec4 planRayonsX; // équation du plan de rayonX

layout(location=0) in vec4 Vertex;
layout(location=3) in vec4 Color;

out Attribs {
   vec4 couleur;  
   float clipDistance0;
   float clipDistance1;
   float clipDistance2;  
} AttribsOut;

void main( void )
{
   // transformation standard du sommet
   gl_Position = matrProj * matrVisu * matrModel * Vertex;

   // degrader de la couleur
    vec4 bleu = vec4(0.0, 1.0, 1.0, 1.0);    

    // couleur du sommet
    if (modeSelection == 0) 
    {
        AttribsOut.couleur = mix(Color, bleu,  Vertex.z);
    }
    else 
    {
        AttribsOut.couleur = Color;
    }

   gl_ClipDistance[0] = dot( planRayonsX, matrModel * Vertex );
    AttribsOut.clipDistance0 = gl_ClipDistance[0];
   gl_ClipDistance[1] = dot( planRayonsX * -1.0f, matrModel * Vertex );
   AttribsOut.clipDistance1 = gl_ClipDistance[1];
   gl_ClipDistance[2] = dot( planDragage, matrModel * Vertex );
   AttribsOut.clipDistance2 = gl_ClipDistance[2];
 }
