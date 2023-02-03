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
  static func unlit(_ color: Color) -> UnlitShader {
    return UnlitShader(.with(color))
  }
}

// MARK: - Uniforms

struct ColorUniform {
  let color: simd_float4
  static func with(_ color: Color) -> ColorUniform {
    return ColorUniform(color: color.components)
  }
}

// MARK: - Unlit Shader

struct UnlitShader: MetalDrawable_Shader {
  let functions: (String, String) = ("unlit_vertex", "unlit_fragment")
  let colorUniform: ColorUniform
  let storage: Storage
  
  init(_ uniforms: ColorUniform, storage: Storage = Storage()) {
    self.colorUniform = uniforms
    self.storage = storage
  }
  
  func build(device: MTLDevice, library: MetalShaderLibrary, previous: (any MetalDrawable_Shader)?) {
    let previous = previous as? UnlitShader
    
    self.storage.uniformsBuffer = previous?.storage.uniformsBuffer
    if self.storage.uniformsBuffer == nil {        
      storage.uniformsBuffer = device.makeBuffer(length: MemoryLayout<ColorUniform>.size)
      storage.uniformsBuffer?.contents().storeBytes(of: self.colorUniform, as: ColorUniform.self)
    }
    
    self.storage.pipeline = library.pipeline(for: functions.0, fragment: functions.1)
  }
  
  func setupEncoder(encoder: MTLRenderCommandEncoder) {
    if let uniform = storage.uniformsBuffer {
      encoder.setVertexBuffer(uniform, offset: 0, index: 4)
    }
    
    if let ps = storage.pipeline { 
      encoder.setRenderPipelineState(ps)
    }
  }
}


extension UnlitShader {
  class Storage {
    fileprivate var uniformsBuffer: MTLBuffer?
    fileprivate var pipeline: MTLRenderPipelineState?
  }
}
