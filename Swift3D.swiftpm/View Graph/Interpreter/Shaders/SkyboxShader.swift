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

extension MetalDrawable_Shader where Self == StandardShader {
  static func skybox(_ texture: MetalDrawable_Texture, scaledBy: simd_float2) -> SkyboxShader {
    return .init(texture: texture,
                 uniform: SkyboxUniform(textureScaling: simd_float4(x: scaledBy.x, y: scaledBy.y, z: 0, w: 0)),
                 storage: SkyboxShader.Storage())
  }
}

// MARK: - Uniforms

fileprivate struct SkyboxUniform {
  let textureScaling: simd_float4;
}

// MARK: - Shader

struct SkyboxShader: MetalDrawable_Shader {
  let functions: (String, String) = ("skybox_vertex", "skybox_fragment")
  let texture: MetalDrawable_Texture
  fileprivate let uniform: SkyboxUniform
  let storage: Storage

  func build(device: MTLDevice, library: MetalShaderLibrary, previous: (any MetalDrawable_Shader)?) {
    let previous = previous as? SkyboxShader

    // uniform storage
    self.storage.uniformsBuffer = previous?.storage.uniformsBuffer
    if self.storage.uniformsBuffer == nil {
      storage.uniformsBuffer = device.makeBuffer(length: MemoryLayout<SkyboxUniform>.size)
      storage.uniformsBuffer?.contents().storeBytes(of: self.uniform, as: SkyboxUniform.self)
    }

    // We store and use library directly because it does a lot of the reuse and caching of
    // shaders & textures for us.
    self.storage.library = library
  }

  func setupEncoder(encoder: MTLRenderCommandEncoder) {
    guard
      let uniformBuffer = storage.uniformsBuffer,
      let library = storage.library else {
      return
    }

    // Uniforms
    encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 4)

    // Texture
    encoder.setFragmentTexture(texture.mtlTexture(library), index: 0)

    // Shaders
    encoder.setRenderPipelineState(library.pipeline(for: functions.0, fragment: functions.1))
  }
}

extension SkyboxShader {
  class Storage {
    fileprivate var uniformsBuffer: MTLBuffer?
    fileprivate var library: MetalShaderLibrary?
  }
}
