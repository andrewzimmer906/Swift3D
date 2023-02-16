//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/15/23.
//

import Foundation
import ModelIO
import MetalKit

struct Capsule: MetalDrawable_Geometry {
  var cacheKey: String { "Capsule_seg_16" }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    let asset = MDLMesh(capsuleWithExtent: simd_float3(x: 1, y: 3, z: 1),
                        cylinderSegments: vector_uint2(16, 16),
                        hemisphereSegments: 16,
                        inwardNormals: false,
                        geometryType: .triangles,
                        allocator: allocator)

    return try MTKMesh(mesh: asset, device: device)
  }
}
