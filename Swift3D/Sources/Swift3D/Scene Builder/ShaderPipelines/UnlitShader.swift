//
//  Unlit.swift
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import Metal
import SwiftUI
import simd

// MARK: - Init Helper

extension MetalDrawable_Shader where Self == UnlitShader {
  public static func unlit(_ color: Color) -> UnlitShader {
    return UnlitShader(color)
  }
}

// MARK: - Unlit Shader

public struct UnlitShader: MetalDrawable_Shader {
  let functions: (String, String) = ("unlit_vertex", "unlit_fragment")
  let color: Color
  let storage: Storage
  
  init(_ color: Color, storage: Storage = Storage()) {
    self.color = color
    self.storage = storage
  }
  
  public func build(device: MTLDevice, library: MetalShaderLibrary, descriptor: MTLVertexDescriptor?) {
    self.storage.color = self.color.components
    self.storage.pipeline = library.pipeline(for: functions.0, fragment: functions.1, vertexDescriptor: descriptor)
  }
  
  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    if let ps = storage.pipeline { 
      encoder.setRenderPipelineState(ps)
    }
    encoder.setFragmentBytes(&storage.color, length: MemoryLayout<SIMD4<Float>>.size, index: 0)
  }
}


extension UnlitShader {
  class Storage {
    fileprivate var pipeline: MTLRenderPipelineState?
    var color: simd_float4 = .zero
  }
}
