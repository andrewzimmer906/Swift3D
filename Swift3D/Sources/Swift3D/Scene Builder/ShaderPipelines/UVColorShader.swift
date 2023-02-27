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

extension MetalDrawable_Shader where Self == UVColorShader {
  public static var uvColored: UVColorShader {
    .init(material: .init(lightingSettings: simd_float4(x: 4, y: 4, z: 0, w: 0),
                          albedoTextureScaling: .zero),
          storage: .init())
  }
}

// MARK: - Shader

public struct UVColorShader: MetalDrawable_Shader {
  let functions: (String, String) = ("uv_color_vertex", "uv_color_fragment")
  fileprivate let material: MaterialSettings

  let storage: Storage

  public func build(device: MTLDevice, library: MetalShaderLibrary, descriptor: MTLVertexDescriptor?) {
    // We store and use library directly because it does a lot of the reuse and caching of
    // shaders & textures for us.
    self.storage.pipeline = library.pipeline(for: functions.0, fragment: functions.1, vertexDescriptor: descriptor)
    self.storage.material = self.material
  }

  public func setTextures(encoder: MTLRenderCommandEncoder) { }

  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    encoder.setFragmentBytes(&storage.material, length: MemoryLayout<MaterialSettings>.size, index: FragmentBufferIndex.material.rawValue)
    if let ps = storage.pipeline {
      encoder.setRenderPipelineState(ps)
    }
  }
}

extension UVColorShader {
  class Storage {
    fileprivate var material: MaterialSettings = .init(lightingSettings: .zero, albedoTextureScaling: .zero)
    fileprivate var pipeline: MTLRenderPipelineState?
  }
}
