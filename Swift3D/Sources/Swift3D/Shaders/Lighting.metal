//
//  Lighting.cpp
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

#include <metal_stdlib>
using namespace metal;

#include "Common.h"

// Helpers
float3 calculateLight(float type, float3 light, float3 col, float3 normal, float3 normalV, float4 vPos, MaterialProperties material) {
  if (type == 1) { // ambient
    return col;
  }

  // TODO: This lighting model is screwed. For some reason the eye value moving around isn't affecting our stuff when
  // mixed with normal.  Needs saving!
  if (type == 2) { // directional
    light = normalize(light);

    float diffuseFactor = saturate(dot(normal, light));
    
    float3 eye = vPos.xyz;

    float3 reflection = reflect(-light, normalV);
    float specFactor = pow(saturate(dot(reflection, eye)), material.properties.x) * diffuseFactor;
    float rimFactor = pow(saturate(1.0 - dot(eye, normalV)), material.properties.y) * diffuseFactor;

    // return float3(specFactor);
    return (diffuseFactor + specFactor + rimFactor) * col;
  }
  
  return float3(0, 0, 0); // none
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
