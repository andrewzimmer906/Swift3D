//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import UIKit
import Metal
import simd

// MARK: - Uniforms

struct LightsUniform {  
  let light1: simd_float4
  let light1Col: simd_float4
  
  let light2: simd_float4
  let light2Col: simd_float4
}

// MARK: - Command

struct PlaceLight: MetalDrawable {
  let id: String
  let transform: float4x4
  
  let type: LightType
  let color: simd_float4
  
  let animations: [NodeTransition]?
  
  // Use a static here as we are passing one uniform for 
  // all of our lights!
  var storage: PlaceLight.Storage {
    Self._storage
  }
  private static let _storage: PlaceLight.Storage = PlaceLight.Storage()
  
  func withUpdated(transform: float4x4) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform, color: nil)
  }
  
  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil, color: nil)
  }
  
  func withUpdated(animations: [NodeTransition]) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil, color: nil)
  }
  
  func withUpdated(color: simd_float4) -> any MetalDrawable {
    withUpdated(id: nil, animations: nil, transform: nil, color: color)
  }
  
  private func withUpdated(id: String?, 
                           animations: [NodeTransition]?,
                           transform: float4x4?,
                           color: simd_float4?) -> Self {
    .init(id: id ?? self.id,
          transform: transform ?? self.transform,
          type: type,
          color: color ?? self.color,
          animations: animations ?? self.animations)
  }
}

// MARK: - Updates

extension PlaceLight {  
  var needsRender: Bool { false }
  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?) {
    fatalError()
  }
  
  var uniformValues: (simd_float4, simd_float4) {
    let direction = transform.rotation.act(.back)
    return (simd_float4(direction, Float(type.rawValue)), color)
  }
}

// MARK: Storage
extension PlaceLight {
  class Storage: MetalDrawable_Storage {
    private(set) var device: MTLDevice?
    private(set) var lightsUniform: MTLBuffer?
  }
}

extension PlaceLight.Storage {
  func set<Value>(_ value: Value) {
    if let lights = value as? [PlaceLight] {
      var values0 = (simd_float4.zero, simd_float4.zero)
      var values1 = (simd_float4.zero, simd_float4.zero)
      if lights.count > 0 {
        values0 = lights[0].uniformValues        
      }
      if lights.count > 1 {
        values1 = lights[1].uniformValues        
      }
      
      let uniform = LightsUniform(light1: values0.0, light1Col: values0.1, light2: values1.0, light2Col: values1.1)
      self.lightsUniform?.contents().storeBytes(of: uniform, as: LightsUniform.self)
    }
  }
  
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable)?,
               device: MTLDevice, 
               library: MetalShaderLibrary, 
               surfaceAspect: Float) {
    self.device = device    
    if lightsUniform == nil {
      self.lightsUniform = device.makeBuffer(length: MemoryLayout<LightsUniform>.size)
    }
  }
}

extension PlaceLight {
  enum LightType: Int {
    case ambient = 1
    case directional = 2
  }
}
