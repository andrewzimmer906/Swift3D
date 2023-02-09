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
  float3 position [[attribute(0)]];
  float3 normal [[attribute(1)]];
  float2 uv [[attribute(2)]];
};

constexpr sampler textureSampler (address::repeat);

#endif /* Header_h */
