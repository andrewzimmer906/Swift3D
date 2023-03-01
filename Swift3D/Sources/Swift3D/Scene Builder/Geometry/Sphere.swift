//
//  Sphere.swift
//  
//
//  Created by Andrew Zimmer on 2/8/23.
//

import Foundation
import ModelIO
import MetalKit


// MARK: - Sphere

struct Sphere: MetalDrawable_Geometry {
  var cacheKey: String { "Sphere_seg_16" }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    let asset = MDLMesh(sphereWithExtent: .one,
                        segments: vector_uint2(16, 16),
                        inwardNormals: false,
                        geometryType: .triangles,
                        allocator: allocator)
    asset.vertexDescriptor = Vertex.descriptor
    Self.addOrthoTan(to: asset)
    return try MTKMesh(mesh: asset, device: device)
  }
}

