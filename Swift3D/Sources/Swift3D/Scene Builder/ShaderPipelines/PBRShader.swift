//
//  StandardShader.swift
//
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import SwiftUI
import Metal
import simd

// MARK: - Init Helper

extension MetalDrawable_Shader where Self == PBRShader {
  public static func pbr(baseColor: MetalDrawable_Texture = Color.white,
                         emission: MetalDrawable_Texture? = nil,
                         normal: MetalDrawable_Texture? = nil,
                         roughness: MetalDrawable_Texture = Color(white: 0.5),
                         metalness: MetalDrawable_Texture = Color(white: 0),
                         occlusion: MetalDrawable_Texture? = nil) -> PBRShader {
    return .init(baseColor: baseColor,
                 emission: emission,
                 normal: normal,
                 roughness: roughness,
                 metalness: metalness,
                 ambientOcclusion: occlusion,
                 storage: PBRShader.Storage())
  }

  public static var pbr: PBRShader {
    return pbr()
  }
}

// MARK: - Shader

public struct PBRShader: MetalDrawable_Shader {
  let functions: (String, String) = ("pbr_vertex", "pbr_fragment")

  let baseColor: MetalDrawable_Texture
  let emission: MetalDrawable_Texture?
  let normal: MetalDrawable_Texture?
  let roughness: MetalDrawable_Texture
  let metalness: MetalDrawable_Texture
  let ambientOcclusion: MetalDrawable_Texture?

  let storage: Storage

  public func build(device: MTLDevice, library: MetalShaderLibrary, descriptor: MTLVertexDescriptor?) {
    // We store and use library directly because it does a lot of the reuse and caching of
    // shaders & textures for us.
    self.storage.library = library
    self.storage.pipeline = library.pipeline(for: functions.0, fragment: functions.1, vertexDescriptor: descriptor)
  }

  public func setTextures(encoder: MTLRenderCommandEncoder) {
    guard let library = storage.library else {
      return
    }

    encoder.setFragmentTexture(baseColor.mtlTexture(library), index: FragmentTextureIndex.baseColor.rawValue) // Albedo
    encoder.setFragmentTexture(roughness.mtlTexture(library), index: FragmentTextureIndex.roughness.rawValue) // Roughness
    encoder.setFragmentTexture(metalness.mtlTexture(library), index: FragmentTextureIndex.metalness.rawValue) // Metalness

    if let emission = emission {
      encoder.setFragmentTexture(emission.mtlTexture(library), index: FragmentTextureIndex.emission.rawValue) // Emission
    }
    if let normal = normal {
      encoder.setFragmentTexture(normal.mtlTexture(library), index: FragmentTextureIndex.normal.rawValue) // Normal
    }
    if let ambientOcclusion = ambientOcclusion {
      encoder.setFragmentTexture(ambientOcclusion.mtlTexture(library), index: FragmentTextureIndex.occlusion.rawValue) // Ambient Occlusion
    }
  }

  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    if let ps = storage.pipeline {
      encoder.setRenderPipelineState(ps)
    }
  }
}

extension PBRShader {
  class Storage {
    fileprivate var pipeline: MTLRenderPipelineState?
    fileprivate var library: MetalShaderLibrary?
  }
}
