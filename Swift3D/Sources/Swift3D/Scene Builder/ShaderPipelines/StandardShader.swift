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
  public static func standard(albedo: MetalDrawable_Texture,
                              albedoScaling: simd_float2 = .one,
                              specPow: Float = 2,
                              rimPow: Float = 2) -> StandardShader {
    
    return .init(albedo: albedo,
                 material: MaterialSettings(
                  lightingSettings: simd_float4(specPow, rimPow, 0, 0),
                  albedoTextureScaling: simd_float4(x: albedoScaling.x, y: albedoScaling.y, z: 0, w: 0)),
                 storage: StandardShader.Storage())
  }
}

// MARK: - Uniforms

fileprivate struct MaterialSettings {
  let lightingSettings: simd_float4
  let albedoTextureScaling: simd_float4;
}

// MARK: - Shader

public struct StandardShader: MetalDrawable_Shader {
  let functions: (String, String) = ("standard_vertex", "standard_fragment")
  let albedo: MetalDrawable_Texture
  fileprivate let material: MaterialSettings

  let storage: Storage
  
  public func build(device: MTLDevice, library: MetalShaderLibrary, descriptor: MTLVertexDescriptor?) {
    // We store and use library directly because it does a lot of the reuse and caching of
    // shaders & textures for us.
    self.storage.library = library
    self.storage.pipeline = library.pipeline(for: functions.0, fragment: functions.1, vertexDescriptor: descriptor)
    self.storage.material = self.material
  }
  
  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    guard let library = storage.library else {
      return
    }

    // Albedo
    encoder.setFragmentTexture(albedo.mtlTexture(library), index: 0)
    encoder.setFragmentBytes(&storage.material, length: MemoryLayout<MaterialSettings>.size, index: 0)

    if let ps = storage.pipeline {
      encoder.setRenderPipelineState(ps)
    }
  }
}

extension StandardShader {
  class Storage {
    fileprivate var material: MaterialSettings = .init(lightingSettings: .zero, albedoTextureScaling: .zero)
    fileprivate var pipeline: MTLRenderPipelineState?
    fileprivate var library: MetalShaderLibrary?
  }
}