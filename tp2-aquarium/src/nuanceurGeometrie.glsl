#version 410
layout(triangles) in;
layout(triangle_strip, max_vertices = 6) out;

in Attribs {
   vec4 couleur;
   float clipDistance0;
   float clipDistance1;
   float clipDistance2;   
} AttribsIn[];

out Attribs {
   vec4 couleur;
}AttribsOut;


void main(void)
{
  for ( int i = 0; i < gl_in.length() ; ++i)
  {
    gl_ViewportIndex = 0; // premiere cloture
    gl_Position = -gl_in[i].gl_Position;
    AttribsOut.couleur = AttribsIn[i].couleur;

    gl_ClipDistance[0] = AttribsIn[i].clipDistance0;
    gl_ClipDistance[1] = AttribsIn[i].clipDistance1;
    gl_ClipDistance[2] = -AttribsIn[i].clipDistance2;  

    EmitVertex();  
  }
  EndPrimitive();

  for ( int i = 0; i < gl_in.length() ; ++i)
  {
    gl_ViewportIndex = 1; // premiere cloture
    gl_Position = gl_in[i].gl_Position;
    AttribsOut.couleur = AttribsIn[i].couleur;

    gl_ClipDistance[0] = AttribsIn[i].clipDistance0;
    gl_ClipDistance[1] = AttribsIn[i].clipDistance1;
    gl_ClipDistance[2] = AttribsIn[i].clipDistance2; 

    EmitVertex(); 

  }
  EndPrimitive();
}