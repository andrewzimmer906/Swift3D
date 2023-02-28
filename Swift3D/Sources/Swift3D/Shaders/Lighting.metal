//
//  Lighting.cpp
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;


// Used for generating a normal matrix.
float3x3 upperLeft3x3AndTransposed(float4x4 m) {
  // Not Transposed
  /*return float3x3(m[0][0], m[1][0], m[2][0],
                  m[0][1], m[1][1], m[2][1],
                  m[0][2], m[1][2], m[2][2])*/

  // I think!?
  return float3x3(m[0][0], m[0][1], m[0][2],
                  m[1][0], m[1][1], m[1][2],
                  m[2][0], m[2][1], m[2][2]);
}

float3 calculateLightingSpecular(Light light, MaterialProperties material, float3 normal, float3 viewDirection) {
  float atten = light.color.w;
  float3 color = light.color.xyz;

  if (light.position.w == LightTypeAmbient) {
    return color * atten;
  } else if(light.position.w == LightTypeDirectional) {
    float3 lightDir = normalize(light.position.xyz);
    float diffuseFactor = saturate(-dot(lightDir, normal));

    float3 reflection = reflect(lightDir, normal);

    float specFactor = pow(saturate(-dot(reflection, viewDirection)), material.properties.x) * diffuseFactor;
    float rimFactor = pow(saturate(1.0 - dot(lightDir, normal)), material.properties.y);

    return (specFactor + diffuseFactor + rimFactor) * color * atten;
  }

  return float3(0);
}

// ------------------
// PBR Math
// ------------------

/// Calculates the (monochromatic) specular color at normal incidence
constexpr float3 F0FromIor(float ior) {
    float k = (1.0f - ior) / (1.0f + ior);
    return k * k;
}

// Microfacet Models for Refraction through Rough Surfaces
// Walter, et al. 2007 (eq. 34)
float G1_GGX(float alphaSq, float NdotX) {
    float cosSq = NdotX * NdotX;
    float tanSq = (1.0f - cosSq) / max(cosSq, 1e-4);
    return 2.0f / (1.0f + sqrt(1.0f + alphaSq * tanSq));
}

// Microfacet Models for Refraction through Rough Surfaces
// Walter, et al. 2007 (eq. 23)
float G_JointSmith(float alphaSq, float NdotL, float NdotV) {
    return G1_GGX(alphaSq, NdotL) * G1_GGX(alphaSq, NdotV);
}

// Microfacet Models for Refraction through Rough Surfaces
// Walter, et al. 2007 (eq. 33)
float D_TrowbridgeReitz(float alphaSq, float NdotH) {
    float c = (NdotH * NdotH) * (alphaSq - 1.0f) + 1.0f;
    return step(0.0f, NdotH) * alphaSq / (M_PI_F * (c * c));
}

// An Inexpensive BRDF Model for Physically-based Rendering
// Schlick, 1994 (eq. 15)
float3 F_Schlick(float3 F0, float VdotH) {
    return F0 + (1.0f - F0) * powr(1.0f - abs(VdotH), 5.0f);
}

float3 Lambertian(float3 diffuseColor) {
    return diffuseColor * (1.0f / M_PI_F);
}

// ------------------
// Final PBR
// ------------------

float3 BRDF(thread Material &material, float NdotL, float NdotV, float NdotH, float VdotH) {
  float3 baseColor = material.baseColor.rgb;
  float3 diffuseColor = mix(baseColor, float3(0.0f), material.metalness);

  float3 fd = Lambertian(diffuseColor) * material.ambientOcclusion;

  const float3 DielectricF0 = 0.04f; // This results from assuming an IOR of 1.5, the average for common dielectrics
  float3 F0 = mix(DielectricF0, baseColor, material.metalness);
  float alpha = material.roughness * material.roughness;
  float alphaSq = alpha * alpha;

  float D = D_TrowbridgeReitz(alphaSq, NdotH);
  float G = G_JointSmith(alphaSq, NdotL, NdotV);
  float3 F = F_Schlick(F0, VdotH);

  float3 fs = (D * G * F) / (4.0f * abs(NdotL) * abs(NdotV));

  return fd + fs;
}
