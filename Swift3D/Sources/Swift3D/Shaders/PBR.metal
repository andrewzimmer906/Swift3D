#include <metal_stdlib>
#include "Common.h"
using namespace metal;

struct Surface {
    float3 reflected { 0 };
    float3 emitted { 0 };
};

struct PBRMaterialProperties {
  float4 properties;
};

struct VertexOut {
  float4 position [[position]];  //1
  float3 worldPos;
  float3 eyePosition;
  float3 eyeNormal;
  float3 eyeTangent;
  float tangentSign [[flat]];
  float3 worldNormal;
  float2 uv;
};

// --

vertex VertexOut pbr_vertex(VertexIn in [[stage_in]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]]) {

  float4x4 m_matrix =      uniforms.modelMatrix;
  float4x4 mvp_matrix =    vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;

  float4 modelPosition = float4(in.position, 1);
  float4 worldPosition = m_matrix * modelPosition;
  float4 eyePosition = vpUniforms.viewMatrix * worldPosition;
  float3x3 nm = upperLeft3x3AndTransposed(vpUniforms.viewMatrix * m_matrix);

  VertexOut out {
    .position = mvp_matrix * modelPosition,
    .worldPos = worldPosition.xyz,
    .eyePosition = eyePosition.xyz,
    .eyeNormal = normalize(nm * in.normal),
    .eyeTangent = normalize(nm * in.tangent.xyz),
    .tangentSign = in.tangent.w,
    .worldNormal = normalize((m_matrix * float4(in.normal, 0.0))).xyz,
    .uv = in.uv
  };

  return out;
}

// ----- Helper Methods -------

float remap(float sourceMin, float sourceMax, float destMin, float destMax, float t) {
    float f = (t - sourceMin) / (sourceMax - sourceMin);
    return mix(destMin, destMax, f);
}

fragment float4 pbr_fragment(VertexOut in [[stage_in]],
                             texture2d<float, access::sample> baseColorTex [[ texture(FragmentTextureBaseColor) ]],
                             texture2d<float, access::sample> emissionTex [[ texture(FragmentTextureEmissive) ]],
                             texture2d<float, access::sample> normalTex [[ texture(FragmentTextureNormal) ]],
                             texture2d<float, access::sample> metalnessTex [[ texture(FragmentTextureMetallic) ]],
                             texture2d<float, access::sample> roughnessTex [[ texture(FragmentTextureRoughness) ]],
                             texture2d<float, access::sample> occlusionTex [[ texture(FragmentTextureAmbientOcclusion) ]],

                             constant FragmentUniforms &uniforms [[ buffer(0) ]],
                             constant MaterialProperties &materialProp [[ buffer(1) ]],
                             constant Light *lights [[ buffer(2) ]]) {

  constexpr sampler repeatSampler(filter::linear, mip_filter::linear, address::repeat);

  float ambientOcclusion = is_null_texture(occlusionTex) ? 1.0f : occlusionTex.sample(repeatSampler, in.uv).r;
  float4 baseColor = is_null_texture(baseColorTex) ? float4(1) : baseColorTex.sample(repeatSampler, in.uv);
  float roughness = is_null_texture(roughnessTex) ? 0.5 : roughnessTex.sample(repeatSampler, in.uv).g;
  float metalness = is_null_texture(metalnessTex) ? 0 : metalnessTex.sample(repeatSampler, in.uv).b;

  Material material {
    .baseColor = baseColor,
    .roughness = remap(0, 1, 0.045, 1, roughness),
    .metalness = metalness,
    .ambientOcclusion = ambientOcclusion
  };

  // float3 V = normalize(uniforms.cameraPos.xyz);
  float3 V = normalize(-in.eyePosition);
  float3 Ng = normalize(in.eyeNormal);
  float3 N;
  
  if (!is_null_texture(normalTex)) {
    float3 T = normalize(in.eyeTangent);
    float3 B = cross(in.eyeNormal, in.eyeTangent) * in.tangentSign;
    float3x3 TBN = { T, B, Ng };

    float3 Nt = normalTex.sample(repeatSampler, in.uv).xyz * 2.0f - 1.0f;
    N = TBN * Nt;
  } else {
    N = Ng;
  }
  N = Ng;
  // return float4(N * 0.5 + 0.5, 1);

  Surface surface;
  surface.emitted = is_null_texture(emissionTex) ? float3(0) : emissionTex.sample(repeatSampler, in.uv).rgb;

  for (uint i = 0; i < uniforms.lightData.x; i++) {
    Light light = lights[i];

    // Directional Only for the moment.
    if (light.position.w != LightTypeDirectional) {
      continue;
    }

    float3 lightToPoint = light.position.xyz;
    float3 intensity = light.color.xyz * light.color.w;

    float3 L = normalize(-lightToPoint);
    float3 H = normalize(L + V);

    float NdotL = dot(N, L);
    float NdotV = dot(N, V);
    float NdotH = dot(N, H);
    float VdotH = dot(V, H);

    surface.reflected += intensity * saturate(NdotL) * BRDF(material, NdotL, NdotV, NdotH, VdotH);
    //surface.reflected += intensity * BRDF(material, NdotL, NdotV, NdotH, VdotH);
  }

  float3 color = surface.emitted + surface.reflected;
  float alpha = material.baseColor.a;

  return float4(color * alpha, alpha);
}
