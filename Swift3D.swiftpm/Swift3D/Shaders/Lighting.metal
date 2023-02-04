//
//  Lighting.cpp
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

#include <metal_stdlib>
using namespace metal;

#include "Lighting.h"

// Helpers
float3 calculateLight(float type, float3 light, float3 col, float3 normal, float3 normalV, float4 vPos, MaterialProperties material) {
  if (type == 1) { // ambient
    return col;
  }
  
  if (type == 2) { // directional
    float diffuseFactor = saturate(dot(normal, light));
    
    float3 eye = normalize(-vPos.xyz);

    float3 reflection = 2.0 * dot(normalV, light) * normalV - light;
    float specFactor = pow(saturate(dot(reflection, eye)), material.properties.x) * diffuseFactor;
    float rimFactor = pow(saturate(1.0 - dot(eye, normalV)), material.properties.y) * diffuseFactor;

    return (diffuseFactor + specFactor + rimFactor) * col;
  }
  
  return float3(0, 0, 0); // none
}

// We'll eventually want position for point lights, but whatevers
float3 calculateLighting(Lights lights, MaterialProperties material, float3 normal, float3 normalV, float4 vPos) {
  float3 light1 = calculateLight(lights.light1.w, lights.light1.xyz, lights.light1Col.xyz, normal, normalV, vPos, material);
  float3 light2 = calculateLight(lights.light2.w, lights.light2.xyz, lights.light2Col.xyz, normal, normalV, vPos, material);
  return light1 + light2;
}
