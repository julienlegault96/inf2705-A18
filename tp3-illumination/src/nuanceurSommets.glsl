#version 410

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
   vec4  ambient;
   vec4  diffuse;
   vec4  specular;
   vec4  position[2];      // dans le repère du monde
   vec3  spotDirection[2]; // dans le repère du monde
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
   vec4 ambient;       // couleureur ambiante
   bool localViewer;   // observateur local ou à l'infini?
   bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

layout (std140) uniform varsUnif
{
   // illumination
   int  typeIllumination;     // 0:Gouraud, 1:Phong
   bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
   bool utiliseDirect;       // indique si on utilise un spot style Direct3D ou OpenGL
   bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
   // partie 3: texture
   int  texnumero;            // numéro de la texture appliquée
   bool utilisecouleureur;      // doit-on utiliser la couleureur de base de l'objet en plus de celle de la texture?
   int  afficheTexelFonce;    // un texel noir doit-il être affiché 0:noir, 1:mi-coloré, 2:transparent?
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
   vec3 normal;
   vec3 pos;
   
} AttribsOut;

float calculerSpot( in vec3 D, in vec3 L )
{
   float spotFacteur = 1.0;
   return spotFacteur;
}

vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O )
{
   // Gouraud
   vec4 coul = vec4(0.0, 0.0, 0.0, 1.0);

   // diffuse
   float NdotL = max(0.0, dot(N, L));
   coul +=  FrontMaterial.diffuse * LightSource.diffuse * NdotL;

   // speculaire
   if (utiliseBlinn) {    
      float NdotHV = max(0.0, dot( normalize(L + O), N ));
      coul += FrontMaterial.specular * LightSource.specular * pow(max(NdotHV, 0.0), FrontMaterial.shininess);    
   } else {
      float NdotHV = max(0.0, dot( reflect(-L, N), O ));
      coul += FrontMaterial.specular * LightSource.specular * pow(max(NdotHV, 0.0), FrontMaterial.shininess);
   }
   // ambient
   coul += FrontMaterial.ambient * LightSource.ambient;

   return coul;
}

void main( void )
{
   // transformation standard du sommet
   gl_Position = matrProj * matrVisu * matrModel * Vertex;

   vec3 pos = vec3(matrVisu * matrModel * Vertex);
   vec3 O = normalize(-pos);
   vec3 N = normalize(matrNormale * Normal);

   if (typeIllumination == 0){
      AttribsOut.couleur = vec4(0.f, 0.f, 0.f, 1.f);
      for (int i = 0; i < 2;  i++) {
          vec3 L = normalize( vec3(matrVisu * LightSource.position[i]).xyz - pos );
          AttribsOut.couleur += calculerReflexion(L, N, O); 
      }
       AttribsOut.couleur += FrontMaterial.emission + FrontMaterial.ambient * LightModel.ambient;
       AttribsOut.couleur = clamp(AttribsOut.couleur, 0.0, 1.0);
      
   }
   AttribsOut.normal = N;
   AttribsOut.pos = pos;
}
