//
//  Shape3D.swift
//  
//
//  Created by Andrew Zimmer on 2/8/23.
//

import Foundation
import Metal
import MetalKit

public protocol MetalDrawable_Geometry {
  var cacheKey: String { get }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh
}

extension MetalDrawable_Geometry {
  func addOrthoTan(to mesh: MDLMesh) {
    let hasTexCoords = mesh.vertexAttributeData(forAttributeNamed: MDLVertexAttributeTextureCoordinate) != nil
    let hasNormals = mesh.vertexAttributeData(forAttributeNamed: MDLVertexAttributeNormal) != nil

    if (hasTexCoords && hasNormals) {
        mesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                             normalAttributeNamed: MDLVertexAttributeNormal,
                             tangentAttributeNamed: MDLVertexAttributeTangent)
    }
  }
}

// MARK: - Standard Vertex

struct Vertex {
  let position: simd_float3
  let normal: simd_float3
  let uv: simd_float2

  static var descriptor: MDLVertexDescriptor {
    let mdlVertexDescriptor = MDLVertexDescriptor()
    mdlVertexDescriptor.attributes = [
      MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0),
      MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0),
      MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 24, bufferIndex: 0),
      MDLVertexAttribute(name: MDLVertexAttributeTangent, format: .float4, offset: 32, bufferIndex: 0)
    ]

    mdlVertexDescriptor.layouts = [MDLVertexBufferLayout(stride: 48)]
    return mdlVertexDescriptor
  }
}

extension Array where Element == Vertex {
  var data: Data {
    let vertexSize = MemoryLayout<Float>.size * (3 + 3 + 2 + 4)
    let concat = self.flatMap({ v in
      [v.position.x, v.position.y, v.position.z,  // pos
       v.normal.x, v.normal.y, v.normal.z,  // normal
       v.uv.x, v.uv.y,  // uv
       Float(0), Float(0), Float(0), Float(0)]  // tangent placeholder.
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
