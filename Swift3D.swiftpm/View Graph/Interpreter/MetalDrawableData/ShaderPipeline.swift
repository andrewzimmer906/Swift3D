//
//  ShaderPipeline.swift
//  
//
//  Created by Andrew Zimmer on 1/27/23.
//

import Foundation
import Metal
import simd

// MARK: - Shader Pipeline
extension MetalDrawableData {
  enum ShaderPipeline {
    case standard(String, String)
    case custom(String, String, MetalDrawable_CustomShaderData)
  }
}

extension MetalDrawableData.ShaderPipeline: Equatable {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.standard(let vA, let fA), .standard(let vB, let fB)):
      return vA == vB && fA == fB
    case (.custom(let vA, let fA, _), .custom(let vB, let fB, _)):
      return vA == vB && fA == fB
    default:
      return false
    }
  }
}

extension MetalDrawableData.ShaderPipeline {
  func withCustomData(_ data: MetalDrawable_CustomShaderData) -> MetalDrawableData.ShaderPipeline {
    switch self {
    case .standard(let vert, let frag):
      return .custom(vert, frag, data)      
    case .custom(let vert, let frag, _):
      return .custom(vert, frag, data)
    }
  }
}

// MARK: - Custom Shader

protocol MetalDrawable_CustomShaderData {
  func createBuffer(device: MTLDevice) -> MTLBuffer?
  func sameType(_ other: MetalDrawable_CustomShaderData) -> Bool
  func set(_ buffer: MTLBuffer?)
}

extension MetalDrawable_CustomShaderData {
  func sameType(_ other: MetalDrawable_CustomShaderData) -> Bool {  
    (other is Self)
  }
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    let dataSize = MemoryLayout<Self>.size
    return device.makeBuffer(length: dataSize)
  }
  
  func set(_ buffer: MTLBuffer?) {
    buffer?.contents().storeBytes(of: self, as: Self.self)
  }
}

struct ColorUniform: MetalDrawable_CustomShaderData {  
  let color: simd_float4
}
