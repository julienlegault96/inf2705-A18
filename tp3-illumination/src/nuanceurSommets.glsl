#version 410

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
   vec4 ambient;
   vec4 diffuse;
   vec4 specular;
   vec4 position[2];      // dans le repère du monde
   vec3 spotDirection[2]; // dans le repère du monde
   float spotExponent;
   float spotAngleOuverture; // ([0.0,90.0] ou 180.0)
   float constantAttenuation;
   float linearAttenuation;
   float quadraticAttenuation;
} LightSource;

// Définition des paramètres des matériaux
layout (std140) uniform MaterialParameters
{
   vec4 emission;
   vec4 ambient;
   vec4 diffuse;
   vec4 specular;
   float shininess;
} FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout (std140) uniform LightModelParameters
{
   vec4 ambient;       // couleur ambiante
   bool localViewer;   // observateur local ou à l'infini?
   bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

layout (std140) uniform varsUnif
{
   // partie 1: illumination
   int typeIllumination;     // 0:Gouraud, 1:Phong
   bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
   bool utiliseDirect;       // indique si on utilise un spot style Direct3D ou OpenGL
   bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
   // partie 3: texture
   int texnumero;            // numéro de la texture appliquée
   bool utiliseCouleur;      // doit-on utiliser la couleur de base de l'objet en plus de celle de la texture?
   int afficheTexelFonce;    // un texel noir doit-il être affiché 0:noir, 1:mi-coloré, 2:transparent?
};

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform mat3 matrNormale;

/////////////////////////////////////////////////////////////////

layout(location=0) in vec4 Vertex;
layout(location=2) in vec3 Normal;
layout(location=3) in vec4 Color;
layout(location=8) in vec4 TexCoord;

out Attribs {
   vec4 couleur;
} AttribsOut;

float calculerSpot( in vec3 D, in vec3 L )
{
   float spotFacteur = 1.0;
   return( spotFacteur );
}

vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O )
{
   /*vec4 grisUniforme = vec4(0.7,0.7,0.7,1.0);
   return( grisUniforme );*/
   // Gouraud
   vec4 reflexion = vec4(0.0, 0.0, 0.0, 0.0);
   if (utiliseBlinn) {
        vec3 B = normalize(L+O);
        reflexion += FrontMaterial.ambient * LightSource.ambient + 
                         FrontMaterial.diffuse * LightSource.diffuse*dot(L,N) +
                         FrontMaterial.specular* LightSource.specular*pow(dot(B,N),FrontMaterial.shininess);
   }
   // Phong
   else {
       vec3 R = 2*(L*N)*N -L;
       reflexion += FrontMaterial.ambient * LightSource.ambient + 
                         FrontMaterial.diffuse * LightSource.diffuse*dot(L,N) +
                         FrontMaterial.specular* LightSource.specular*pow(dot(R,O),FrontMaterial.shininess);
   }
   return (reflexion);
}

void main( void )
{
   // transformation standard du sommet
   gl_Position = matrProj * matrVisu * matrModel * Vertex;

   // couleur du sommet
   //AttribsOut.couleur =
   AttribsOut.couleur = Color; // à modifier!
}
