//
//  Never.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import Metal
import MetalKit

extension Never: MetalDrawable_Geometry {
  var cacheKey: String { fatalError() }
  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    fatalError()
  }
  func get(mesh: MTKMesh?) -> MTLVertexDescriptor? {
    fatalError()
  }
}

extension Never: MetalDrawable_Shader {
  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    fatalError()
  }

  public func build(device: MTLDevice, library: MetalShaderLibrary) {
    fatalError()
  }
}
