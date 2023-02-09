//
//  Cube.swift
//  
//
//  Created by Andrew Zimmer on 0.5/27/23.
//

import Foundation
import ModelIO
import MetalKit
import Metal
import simd

struct Cube: MetalDrawable_Geometry {
  var cacheKey: String { "Cube" }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    let vertexBuffer = allocator.newBuffer(with: vertices.data,
                                           type: .vertex)
    let indexBuffer = allocator.newBuffer(with: indices.data,
                                          type: .index)

    let asset = MDLMesh(vertexBuffer: vertexBuffer, vertexCount: 24,
                        descriptor: Vertex.descriptor,
                        submeshes: [.init(indexBuffer: indexBuffer, indexCount: 36, indexType: .uInt16, geometryType: MDLGeometryType.triangles, material: nil)])

    return try MTKMesh(mesh: asset, device: device)
  }

  private var vertices: [Vertex] {
    // Bottom
    [.init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), normal: .down,  uv: simd_float2(x: 0.25, y: 0.5)),
     .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), normal: .down, uv: simd_float2(x: 0.25, y: 0.75)),
     .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), normal: .down,  uv: simd_float2(x: 0.5, y: 0.75)),
     .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5),  normal: .down,  uv: simd_float2(x: 0.5, y: 0.5)),

     // Back
     .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), normal: .forward, uv: simd_float2(x: 1, y: 0.25)),
     .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), normal: .forward,  uv: simd_float2(x: 1, y: 0.5)),
     .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), normal: .forward,   uv: simd_float2(x: 0.75, y: 0.5)),
     .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), normal: .forward,  uv: simd_float2(x: 0.75, y: 0.25)),

     // Front
     .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), normal: .back, uv: simd_float2(x: 0.25, y: 0.25)),
     .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), normal: .back,  uv: simd_float2(x: 0.25, y: 0.5)),
     .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), normal: .back,   uv: simd_float2(x: 0.5, y: 0.5)),
     .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), normal: .back,  uv: simd_float2(x: 0.5, y: 0.25)),

     // Left
     .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), normal: .left, uv: simd_float2(x: 0.25, y: 0.25)),
     .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), normal: .left, uv: simd_float2(x: 0, y: 0.25)),
     .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), normal: .left, uv: simd_float2(x: 0, y: 0.5)),
     .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), normal: .left, uv: simd_float2(x: 0.25, y: 0.5)),

     // Right
     .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), normal: .right, uv: simd_float2(x: 0.5, y: 0.25)),
     .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), normal: .right, uv: simd_float2(x: 0.75, y: 0.25)),
     .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), normal: .right, uv: simd_float2(x: 0.75, y: 0.5)),
     .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), normal: .right, uv: simd_float2(x: 0.5, y: 0.5)),

     // Top
     .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), normal: .up, uv: simd_float2(x: 0.25, y: 0)),
     .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), normal: .up, uv:  simd_float2(x: 0.25, y: 0.25)),
     .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), normal: .up, uv:  simd_float2(x: 0.5, y: 0.25)),
     .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), normal: .up, uv:  simd_float2(x: 0.5, y: 0))]
  }

  private var indices: [Int16] {
    [
      // Bottom
      0, 2, 1,
      0, 3, 2,

      // Back
      4, 6, 5,
      4, 7, 6,

      // Front
      8, 9, 10,
      8, 10, 11,

      // Left
      12, 13, 14,
      12, 14, 15,

      // Right
      16, 18, 17,
      16, 19, 18,

      // Top
      20, 21, 22,
      20, 22, 23,
    ]
  }
}
