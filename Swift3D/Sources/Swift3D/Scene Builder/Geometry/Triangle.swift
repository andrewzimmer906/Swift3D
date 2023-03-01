//
//  Triangle.swift
//  
//
//  Created by Andrew Zimmer on 1/27/23.
//

import Foundation
import ModelIO
import MetalKit
import Metal
import simd

struct Triangle: MetalDrawable_Geometry {
  var cacheKey: String { "Triangle" }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    let vertices: [Vertex] = [
      .init(position: .init(x: 0, y: 0.5, z: 0), normal: .back, uv: simd_float2(0.5, 1)),
      .init(position: .init(x: -0.5, y: -0.5, z: 0), normal: .back, uv: simd_float2(0, 0)),
      .init(position: .init(x: 0.5, y: -0.5, z: 0), normal: .back, uv: simd_float2(1, 0))
    ]

    let indices: [Int16] = [0,1,2]
    let vertexBuffer = allocator.newBuffer(with: vertices.data,
                                           type: .vertex)
    let indexBuffer = allocator.newBuffer(with: indices.data,
                                          type: .index)

    let asset = MDLMesh(vertexBuffer: vertexBuffer, vertexCount: 3,
                        descriptor: Vertex.descriptor,
                        submeshes: [.init(indexBuffer: indexBuffer, indexCount: 3, indexType: .uInt16, geometryType: MDLGeometryType.triangles, material: nil)])
    Self.addOrthoTan(to: asset)

    return try MTKMesh(mesh: asset, device: device)
  }
}
