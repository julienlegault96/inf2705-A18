#version 410

// Définition des paramètres des sources de lumière
layout(std140) uniform LightSourceParameters {
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
}
LightSource;

// Définition des paramètres des matériaux
layout(std140) uniform MaterialParameters {
  vec4 emission;
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
}
FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout(std140) uniform LightModelParameters {
  vec4 ambient;     // couleureur ambiante
  bool localViewer; // observateur local ou à l'infini?
  bool twoSide;     // éclairage sur les deux côtés ou un seul?
}
LightModel;

layout(std140) uniform varsUnif {
  // partie 1: illumination
  int typeIllumination; // 0:Gouraud, 1:Phong
  bool utiliseBlinn; // indique si on veut utiliser modèle spéculaire de Blinn
                     // ou Phong
  bool utiliseDirect; // indique si on utilise un spot style Direct3D ou OpenGL
  bool afficheNormales; // indique si on utilise les normales comme couleureurs
                        // (utile pour le débogage)
  // partie 3: texture
  int texnumero;         // numéro de la texture appliquée
  bool utilisecouleur;   // doit-on utiliser la couleureur de base de l'objet en
                         // plus de celle de la texture?
  int afficheTexelFonce; // un texel noir doit-il être affiché 0:noir,
                         // 1:mi-coloré, 2:transparent?
};

uniform sampler2D laTexture;
uniform mat4 matrModel;
uniform mat4 matrVisu;

/////////////////////////////////////////////////////////////////

in Attribs {
  vec3 pos;
  vec3 normal;
  vec4 couleur;
  vec2 texCoord;
}
AttribsIn;

out vec4 FragColor;

float calculerSpot(in vec3 D, in vec3 L) {
  float spotFacteur = 1.0;
  float cosGamma = max(0.0, dot(L, D));
  float cosDelta = cos(radians(LightSource.spotAngleOuverture));

  if (!utiliseDirect) { // OpenGL
    spotFacteur = (cosGamma > cosDelta) ? pow(max(0.0, cosGamma), LightSource.spotExponent) : 0.0;
  } else { // Direct3D
    float cosOuter = pow(cosDelta, 1.01 + LightSource.spotExponent / 2);
    spotFacteur = smoothstep(cosOuter, cosDelta, cosGamma);
  }
  return spotFacteur;
}

vec4 calculerReflexion(in vec3 L, in vec3 N, in vec3 O) {
  // Phong
  vec4 coul = vec4(0.0, 0.0, 0.0, 1.0);

  // diffuse
  vec4 diffuse = FrontMaterial.diffuse;
  if (!utilisecouleur) {
    diffuse = vec4(0.7, 0.7, 0.7, 1.0);   // gris uniforme.
  }
  float NdotL = max(0.0, dot(N, L));
  coul += diffuse * LightSource.diffuse * NdotL;

  // speculaire
  if (utiliseBlinn) {
    float NdotHV = max(0.0, dot(normalize(L + O), N));
    coul += FrontMaterial.specular * LightSource.specular *
            pow(max(NdotHV, 0.0), FrontMaterial.shininess);
  } else {
    float NdotHV = max(0.0, dot(reflect(-L, N), O));
    coul += FrontMaterial.specular * LightSource.specular *
            pow(max(NdotHV, 0.0), FrontMaterial.shininess);
  }
  // ambient
  coul += FrontMaterial.ambient * LightSource.ambient;

  return coul;
}

void main(void) {
  if (afficheNormales) {
    FragColor = vec4(AttribsIn.normal, 1.f);
    return;
  }
  vec3 O = normalize(-AttribsIn.pos);
  vec3 N = AttribsIn.normal;
  if (typeIllumination == 0) {
    FragColor = AttribsIn.couleur;
  } else {
    FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    for (int i = 0; i < 2; i++) {
      vec3 L = normalize(vec3(matrVisu * LightSource.position[i]).xyz - AttribsIn.pos);
      vec3 D = normalize(transpose(inverse(mat3(matrVisu))) * (-LightSource.spotDirection[i]));
      FragColor += calculerReflexion(L, N, O) * calculerSpot(D, L);
    }
    FragColor += FrontMaterial.emission + FrontMaterial.ambient * LightModel.ambient;
    FragColor = clamp(FragColor, 0.0, 1.0);
  }
  if (texnumero != 0) {
    vec4 texelColor = texture(laTexture, AttribsIn.texCoord);
    
    if ((texelColor.r + texelColor.g + texelColor.b) / 3  >= 0.5) {
      FragColor *= texelColor;
    } else {
      switch(afficheTexelFonce) {
        case 0: 
          FragColor *= texelColor;
          break;
        case 1:
          if ((FragColor.r + FragColor.g + FragColor.b) / 3  >= 0.1)    // prevent adding color to unlighted areas.
            FragColor = (FragColor + texelColor) / 2;
          break;
        case 2:
          discard;
        default:
          break;
      }
    }
  }
}
