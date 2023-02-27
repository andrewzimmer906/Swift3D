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
  public var cacheKey: String { fatalError() }
  public func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    fatalError()
  }
  public func get(mesh: MTKMesh?) -> MTLVertexDescriptor? {
    fatalError()
  }
}

extension Never: MetalDrawable_Shader {
  public func setTextures(encoder: MTLRenderCommandEncoder) {
    fatalError()
  }

  public func build(device: MTLDevice, library: MetalShaderLibrary, descriptor: MTLVertexDescriptor?) {
    fatalError()
  }

  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    fatalError()
  }
}

extension Never: MetalDrawable_Texture {
  public func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    fatalError("Please specify a texture or use a model that has one premade.")
  }


}
