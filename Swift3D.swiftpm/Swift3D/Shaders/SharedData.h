//
//  SharedData.h
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

#ifndef SharedData_h
#define SharedData_h

struct Uniforms {
  float4x4 modelMatrix;
};

struct ViewProjectionUniform {
  float4x4 projectionMatrix;
  float4x4 viewMatrix;
};



// Normal, UV, Vertex
struct VertexIn {
  float3 position;
  float2 uv;
  float3 normal;
};

constexpr sampler textureSampler (address::repeat);

#endif /* Header_h */
