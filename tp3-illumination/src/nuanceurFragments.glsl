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
   vec4 ambient;       // couleureur ambiante
   bool localViewer;   // observateur local ou à l'infini?
   bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

layout (std140) uniform varsUnif
{
   // partie 1: illumination
   int typeIllumination;     // 0:Gouraud, 1:Phong
   bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
   bool utiliseDirect;       // indique si on utilise un spot style Direct3D ou OpenGL
   bool afficheNormales;     // indique si on utilise les normales comme couleureurs (utile pour le débogage)
   // partie 3: texture
   int texnumero;            // numéro de la texture appliquée
   bool utilisecouleureur;      // doit-on utiliser la couleureur de base de l'objet en plus de celle de la texture?
   int afficheTexelFonce;    // un texel noir doit-il être affiché 0:noir, 1:mi-coloré, 2:transparent?
};

uniform sampler2D laTexture;
uniform mat4 matrModel;
uniform mat4 matrVisu;

/////////////////////////////////////////////////////////////////

in Attribs {
   vec4 couleur;
   vec3 normal;
   vec3 pos;   
} AttribsIn;

out vec4 FragColor;

float calculerSpot( in vec3 D, in vec3 L )
{
   float spotFacteur = 1.0;
   return( spotFacteur );
}

vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O )
{
    // Phong
   vec4 coul = vec4(0.0, 0.0, 0.0, 1.0);

   // diffuse
   float NdotL = max ( 0.0, dot( N, L ) );
   coul += FrontMaterial.diffuse * LightSource.diffuse*NdotL;

   // speculaire
   if (utiliseBlinn)
   {    
    float NdotHV = max( 0.0, dot( normalize( L + O ), N ) );
    coul += FrontMaterial.specular*LightSource.specular*pow(max(NdotHV, 0.0),FrontMaterial.shininess);    
   }

   else
   {
    float NdotHV = max( 0.0, dot( reflect( -L, N ), O ) );
    coul += FrontMaterial.specular*LightSource.specular*pow(max(NdotHV, 0.0),FrontMaterial.shininess);
   }
    // ambient
   coul += FrontMaterial.ambient * LightSource.ambient;

   return coul;
}

void main( void )
{
  if(typeIllumination == 0)
  {
    FragColor = AttribsIn.couleur;
  }

  else
  {    
   vec3 O = normalize(-AttribsIn.pos);
   vec3 N = AttribsIn.normal;

   FragColor = vec4(0.0, 0.0, 0.0, 1.0);
  
    for (int i=0; i<2;  i++)
    {
     vec3 L = normalize(vec3(matrVisu*LightSource.position[i]/LightSource.position[i].w).xyz - AttribsIn.pos);
     FragColor += calculerReflexion(L, N, O); 
    }

   FragColor += FrontMaterial.emission + FrontMaterial.ambient * LightModel.ambient;
   FragColor = clamp( FragColor, 0.0, 1.0 );
  }
}
