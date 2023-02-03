//
//  StandardShader.swift
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import Metal
import simd

// MARK: - Init Helper

extension MetalDrawable_Shader where Self == StandardShader {
  static func standard(albedo: MetalDrawable_Texture,
                       albedoScaling: simd_float2 = .one,
                       specPow: Float = 1,
                       rimPow: Float = 0) -> StandardShader {
    
    return .init(albedo: albedo,
                 uniform: StandardUniform(
                  lightingSettings: simd_float4(specPow, rimPow, 0, 0),
                  albedoTextureScaling: simd_float4(x: albedoScaling.x, y: albedoScaling.y, z: 0, w: 0)),
                 storage: StandardShader.Storage())
  }
}

// MARK: - Uniforms

fileprivate struct StandardUniform {
  let lightingSettings: simd_float4
  let albedoTextureScaling: simd_float4;
}

// MARK: - Shader

struct StandardShader: MetalDrawable_Shader {
  let functions: (String, String) = ("standard_vertex", "standard_fragment")
  let albedo: MetalDrawable_Texture
  fileprivate let uniform: StandardUniform

  let storage: Storage
  
  func build(device: MTLDevice, library: MetalShaderLibrary, previous: (any MetalDrawable_Shader)?) {
    let previous = previous as? StandardShader
    
    self.storage.uniformsBuffer = previous?.storage.uniformsBuffer
    if self.storage.uniformsBuffer == nil {
      storage.uniformsBuffer = device.makeBuffer(length: MemoryLayout<StandardUniform>.size)
      storage.uniformsBuffer?.contents().storeBytes(of: self.uniform, as: StandardUniform.self)
    }

    // We store and use library directly because it does a lot of the reuse and caching of
    // shaders & textures for us.
    self.storage.library = library
  }
  
  func setupEncoder(encoder: MTLRenderCommandEncoder) {
    guard let uniformBuffer = storage.uniformsBuffer,
          let library = storage.library else {
      return
    }

    // Uniforms
    encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 4)

    // Albedo
    encoder.setFragmentTexture(albedo.mtlTexture(library), index: 0)

    // Shaders
    encoder.setRenderPipelineState(library.pipeline(for: functions.0, fragment: functions.1))
  }
}

extension StandardShader {
  class Storage {
    fileprivate var uniformsBuffer: MTLBuffer?
    fileprivate var library: MetalShaderLibrary?
  }
}
