//
//  Shape3D.swift
//  
//
//  Created by Andrew Zimmer on 2/8/23.
//

import Foundation
import Metal
import MetalKit

protocol MetalDrawable_Geometry {
  var cacheKey: String { get }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh
}

// MARK: - Standard Vertex

struct Vertex {
  let position: simd_float3
  let normal: simd_float3
  let uv: simd_float2

  static var descriptor: MDLVertexDescriptor {
    let mdlVertexDescriptor = MDLVertexDescriptor()

    mdlVertexDescriptor.attributes.add(MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0))
    mdlVertexDescriptor.attributes.add(MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0))
    mdlVertexDescriptor.attributes.add(MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 24, bufferIndex: 0))

    mdlVertexDescriptor.layouts.add(MDLVertexBufferLayout(stride: 32))

    return mdlVertexDescriptor
  }
}

extension Array where Element == Vertex {
  var data: Data {
    let vertexSize = MemoryLayout<Float>.size * (3 + 3 + 2)
    let concat = self.flatMap({ v in
      [v.position.x, v.position.y, v.position.z, v.normal.x, v.normal.y, v.normal.z, v.uv.x, v.uv.y]
    })
    return Data(bytes: concat, count: vertexSize * self.count)
  }
}

extension Array where Element == Int16 {
  var data: Data {
    let itemSize = MemoryLayout<Int16>.size
    return Data(bytes: self, count: itemSize * self.count)
  }
}
