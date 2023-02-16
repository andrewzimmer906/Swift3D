//
//  Cone.swift
//  
//
//  Created by Andrew Zimmer on 2/15/23.
//

import Foundation
import ModelIO
import MetalKit

struct Cone: MetalDrawable_Geometry {
  var cacheKey: String { "Cone_seg_16" }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    let asset = MDLMesh(coneWithExtent: .one * 2,
                        segments: vector_uint2(16, 16),
                        inwardNormals: false,
                        cap: true,
                        geometryType: .triangles,
                        allocator: allocator)

    return try MTKMesh(mesh: asset, device: device)
  }
}
