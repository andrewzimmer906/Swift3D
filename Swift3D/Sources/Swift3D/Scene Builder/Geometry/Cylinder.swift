//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/15/23.
//

import Foundation
import ModelIO
import MetalKit

struct Cylinder: MetalDrawable_Geometry {
  var cacheKey: String { "Cyclinder_seg_16" }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    let asset = MDLMesh(cylinderWithExtent: .one,
                        segments: vector_uint2(16, 16),
                        inwardNormals: false,
                        topCap: true,
                        bottomCap: true,
                        geometryType: .triangles, allocator: allocator)
    asset.vertexDescriptor = Vertex.descriptor
    addOrthoTan(to: asset)
    return try MTKMesh(mesh: asset, device: device)
  }
}
