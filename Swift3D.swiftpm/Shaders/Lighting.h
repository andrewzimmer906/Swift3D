//
//  Lighting.h
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

#ifndef Lighting_h
#define Lighting_h



// Uniforms -----------
struct Lights {
  float4 light1;
  float4 light1Col;
  
  float4 light2;
  float4 light2Col;
};

struct MaterialProperties {
  float4 properties; // (specPow, rimPow, 0, 0)
  float4 albedoTextureScaling;
};

// Methods -----------

float3 calculateLighting(Lights lights, MaterialProperties material, float3 normal, float4 vPos);

#endif /* Header_h */
