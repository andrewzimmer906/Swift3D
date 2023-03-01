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
  float tangentSign [[flat]];
  float3 worldNormal;
  float3 worldTangent;
  float2 uv;
};

// --

vertex VertexOut pbr_vertex(VertexIn in [[stage_in]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]]) {

  float4x4 m_matrix =      uniforms.modelMatrix;
  // float4x4 mv_matrix =      vpUniforms.viewMatrix * uniforms.modelMatrix;
  float4x4 mvp_matrix =    vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;

  float4 modelPosition = float4(in.position, 1);
  float4 worldPosition = m_matrix * modelPosition;

  VertexOut out {
    .position = mvp_matrix * modelPosition,
    .worldPos = worldPosition.xyz,
    .worldNormal = normalize((m_matrix * float4(in.normal, 0.0))).xyz,
    .worldTangent = normalize((m_matrix * float4(in.tangent.xyz, 0.0))).xyz,
    .tangentSign = in.tangent.w,
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

  float3 V = normalize(uniforms.cameraPos.xyz);
  float3 N;

  if (!is_null_texture(normalTex)) {
    float3 Wt = normalize(in.worldTangent);
    float3 Wn = normalize(in.worldNormal);
    float3 Wb = cross(Wn, Wt) * in.tangentSign;
    float3x3 TBN = { Wt, Wb, Wn };

    float3 Nt = normalTex.sample(repeatSampler, in.uv).xyz * 2.0f - 1.0f;
    N = (TBN * Nt);
  } else {
    N = in.worldNormal;
  }

  // Normal Test
  //return float4(N * 0.5 + 0.5, 1);

  Surface surface;
  surface.emitted = is_null_texture(emissionTex) ? float3(0) : emissionTex.sample(repeatSampler, in.uv).rgb;

  for (uint i = 0; i < uniforms.lightData.x; i++) {
    Light light = lights[i];
    float3 lightToPoint = light.directionToPoint(in.worldPos);
    float3 intensity = light.evaluateIntensity(lightToPoint);

    float3 L = normalize(-lightToPoint);
    float3 H = normalize(L + V);

    float NdotL = dot(N, L);
    float NdotV = dot(N, V);
    float NdotH = dot(N, H);
    float VdotH = dot(V, H);

    if(light.position.w == LightTypeAmbient) {
      // Opt out of PBR for an ambient light. We just assume a perfect reflection here.
      surface.reflected += intensity * material.baseColor.xyz;
    } else {
      surface.reflected += intensity * saturate(NdotL) * BRDF(material, NdotL, NdotV, NdotH, VdotH);
    }
  }

  float3 color = surface.emitted + surface.reflected;
  float alpha = material.baseColor.a;

  return float4(saturate(color) * alpha, alpha);
}
