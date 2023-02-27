//
//  SharedData.h
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

#ifndef SharedData_h
#define SharedData_h

// ------------ Enums

typedef enum {
  BufferIndexFragmentUniforms = 0,
  BufferIndexFragmentMaterial = 1,
  BufferIndexFragmentLights = 2
} BufferIndices;

typedef enum {
  LightTypeUnused = 0,
  LightTypeAmbient = 1,
  LightTypeDirectional = 2
} LightType;

typedef enum {
  FragmentTextureBaseColor = 0,
  FragmentTextureNormal = 1,
  FragmentTextureEmissive = 2,
  FragmentTextureMetallic = 3,
  FragmentTextureRoughness = 4,
  FragmentTextureAmbientOcclusion = 5
} FragmentTexture;

// ------------ Structs

// ---- Vertex --

struct Uniforms {
  float4x4 modelMatrix;
};

struct ViewProjectionUniform {
  float4x4 projectionMatrix;
  float4x4 viewMatrix;
};

struct VertexIn {
  float3 position [[attribute(0)]];
  float3 normal [[attribute(1)]];
  float2 uv [[attribute(2)]];
  float4 tangent [[attribute(3)]];
};

// ---- Fragment --

struct FragmentUniforms {
  float4 cameraPos;
  float4 lightData;
};

typedef struct {
  float4 position; // w is type
  float4 color;    // a is intensity
} Light;


struct MaterialProperties {
  float4 properties; // (specPow, rimPow, 0, 0)
  float4 albedoTextureScaling;
};

// ------------ Samplers
constexpr sampler textureSampler (address::repeat);

// ------------ Methods

float3 calculateLightingSpecular(Light light, MaterialProperties material, float3 normal, float3 viewDirection);

#endif /* Header_h */
