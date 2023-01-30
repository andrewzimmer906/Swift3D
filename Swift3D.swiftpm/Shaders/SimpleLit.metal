#include <metal_stdlib>
using namespace metal;

struct Uniforms {
  float4x4 modelMatrix;
};

struct ViewProjectionUniform {
  float4x4 projectionMatrix;
  float4x4 viewMatrix;
};

struct Lights {  
  float4 light1;
  float4 light1Col;
  
  float4 light2;
  float4 light2Col;
};

struct CustomShaderUniform {
  float4 textureColor;
};

struct VertexIn {
  float3 position;
  float2 uv;
  float3 normal;
};

struct VertexOut {
  float4 position [[position]];  //1
  float4 vPosition;
  float3 normal;  
  float4 color;
  Lights lights;
};

// Helpers
float3 calculateLight(float type, float3 light, float3 col, float3 normal, float4 vPos) {
  if (type == 1) { // ambient
    return col;
  }
  
  if (type == 2) { // directional
    float diffuseFactor = saturate(dot(normal, light));
    
    float3 eye = normalize(vPos.xyz);
    float3 reflection = reflect(light.xyz, normal);
    float specFactor = pow(max(0.0, dot(reflection, eye)), 2) * diffuseFactor;
    
    return (specFactor + diffuseFactor) * col;
  }
  
  return float3(0, 0, 0); // none
}

// We'll eventually want position for point lights, but whatevers
float3 calculateLighting(Lights lights, float3 normal, float4 vPos) {
  float3 light1 = calculateLight(lights.light1.w, lights.light1.xyz, lights.light1Col.xyz, normal, vPos);
  float3 light2 = calculateLight(lights.light2.w, lights.light2.xyz, lights.light2Col.xyz, normal, vPos);  
  return light1 + light2;
}

// --

vertex VertexOut simple_lit_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           const device Lights& lights [[ buffer(3) ]],
                           const device CustomShaderUniform& customValues [[ buffer(4) ]],
                                   
                           unsigned int vid [[ vertex_id ]]) {
  VertexIn in = vertex_array[vid];
  VertexOut out;
  
  float4x4 m_matrix = uniforms.modelMatrix;
  float4x4 mv_matrix =  vpUniforms.viewMatrix * uniforms.modelMatrix;
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;
  
  out.position = mvp_matrix * float4(in.position, 1.0);
  out.vPosition = mv_matrix * float4(in.position, 1.0);
  out.normal = (m_matrix * float4(in.normal, 0.0)).xyz;
  
  out.color = customValues.textureColor; //float3(0.5) + in.normal * 0.5;
  out.lights = lights;
  
  return out;
}

fragment float4 simple_lit_fragment(VertexOut in [[stage_in]]) {
  float3 lighting = calculateLighting(in.lights, in.normal, in.vPosition);
  return float4((lighting * in.color.xyz).xyz, 1.0);
}


