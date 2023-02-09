//
//  SkyboxShader.swift
//
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import Metal
import simd

// MARK: - Init Helper

extension MetalDrawable_Shader where Self == SkyboxShader {
  public static func skybox(_ texture: CubeMap) -> SkyboxShader {
    return .init(texture: texture,
                 storage: SkyboxShader.Storage())
  }
}

// MARK: - Shader

public struct SkyboxShader: MetalDrawable_Shader {
  let functions: (String, String) = ("skybox_vertex", "skybox_fragment")
  let texture: CubeMap
  let storage: Storage

  public func build(device: MTLDevice, library: MetalShaderLibrary, descriptor: MTLVertexDescriptor?) {
    // We store and use library directly because it does a lot of the reuse and caching of
    // shaders & textures for us.
    self.storage.library = library
  }

  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    guard
      let library = storage.library else {
      return
    }

    // Texture
    encoder.setFragmentTexture(texture.mtlTexture(library), index: 0)

    // Shaders
    encoder.setRenderPipelineState(library.pipeline(for: functions.0, fragment: functions.1))    
  }
}

extension SkyboxShader {
  class Storage {
    fileprivate var library: MetalShaderLibrary?
  }
}
