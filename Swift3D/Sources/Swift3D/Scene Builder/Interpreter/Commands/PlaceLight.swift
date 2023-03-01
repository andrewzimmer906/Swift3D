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

// MARK: - Command

struct PlaceLight: MetalDrawable {
  let id: String
  let transform: MetalDrawableData.Transform
  
  let type: LightType
  let color: simd_float4
  
  let animations: [NodeTransition]?

  let storage: PlaceLight.Storage
  
  func withUpdated(transform: MetalDrawableData.Transform) -> Self {
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
                           transform: MetalDrawableData.Transform?,
                           color: simd_float4?) -> Self {
    .init(id: id ?? self.id,
          transform: transform ?? self.transform,
          type: type,
          color: color ?? self.color,
          animations: animations ?? self.animations,
          storage: self.storage)
  }
}

// MARK: - Updates

extension PlaceLight {  
  var needsRender: Bool { false }
  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?) {
    fatalError()
  }
  
  var uniformValues: Light {

    switch type {
    case .ambient:
      return Light(position: simd_float4(.zero, Float(type.rawValue)),
                                         color: color)
    case .directional:
      let direction = transform.value.rotation.act(.back)
      return Light(position: simd_float4(direction,
                                         Float(type.rawValue)),
                                         color: color)
    case .point:
      let pos = transform.value.translation
      return Light(position: simd_float4(pos,
                                         Float(type.rawValue)),
                                         color: color)
    }
  }
}

// MARK: Storage

extension PlaceLight {
  class Storage: MetalDrawable_Storage {
    private(set) var device: MTLDevice?
    private(set) var uniformValues: Light?
  }
}

extension PlaceLight.Storage {
  func set<Value>(_ value: Value) {
    if let light = value as? Light {
      self.uniformValues = light
    }
  }

  func update(time: CFTimeInterval, command: (any MetalDrawable), previous: (any MetalDrawable_Storage)?) {
    let previous = previous as? Self
    guard let command = command as? PlaceLight else {
      fatalError()
    }

    let uniformValues = attribute(at: time,
                                  cur: command.uniformValues,
                                  prev: previous?.uniformValues,
                                  animation: command.animations?.with([.all]))
    set(uniformValues)
  }

  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable_Storage)?,
               device: MTLDevice, 
               shaderLibrary: MetalShaderLibrary,
               geometryLibrary: MetalGeometryLibrary,
               surfaceAspect: Float) {
    self.device = device

    if let previous = previous as? PlaceLight.Storage {
      self.copy(from: previous)
    }
  }

  func copy(from previous: PlaceLight.Storage) {
    self.uniformValues = previous.uniformValues
  }
}

extension PlaceLight {
  enum LightType: Int {
    case ambient = 1
    case directional = 2
    case point = 3
  }
}
