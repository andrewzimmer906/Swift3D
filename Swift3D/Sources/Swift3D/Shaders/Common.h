//
//  SharedData.h
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

#ifndef SharedData_h
#define SharedData_h

using namespace metal;

// ------------ Enums

typedef enum {
  BufferIndexFragmentUniforms = 0,
  BufferIndexFragmentMaterial = 1,
  BufferIndexFragmentLights = 2
} BufferIndices;

typedef enum {
  LightTypeUnused = 0,
  LightTypeAmbient = 1,
  LightTypeDirectional = 2,
  LightTypePoint = 3
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

struct Light {
  float4 position; // w is type
  float4 color;    // a is intensity

  float3 directionToPoint(float3 p) {
    if (position.w == LightTypeDirectional) {
      return -position.xyz;
    }
    else if (position.w == LightTypePoint) {
      return p - position.xyz;
    }

    return float3(0,0,0);
  }

  /// Evaluates the intensity of this light given a non-normalized
  /// vector from the surface to the light.
  float3 evaluateIntensity(float3 toLight) {
    if (position.w == LightTypePoint) {
      float lightDistSq = dot(toLight, toLight);
      float attenuation = 1.0f / max(lightDistSq, 1e-4);
      return attenuation * color.rgb * color.w;
    }

    return color.xyz * color.w;
  }
};

struct MaterialProperties {
  float4 properties; // (specPow, rimPow, 0, 0)
  float4 albedoTextureScaling;
};

// Used for PBR Properties
struct Material {
    float4 baseColor;
    float metalness;
    float roughness;
    float ambientOcclusion;
};

// ------------ Samplers
constexpr sampler textureSampler (address::repeat);

// ------------ Methods

float3 calculateLightingSpecular(Light light, MaterialProperties material, float3 normal, float3 viewDirection, float3 worldPos);
float3 BRDF(thread Material &material, float NdotL, float NdotV, float NdotH, float VdotH);

#endif /* Header_h */
