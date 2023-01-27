//
//  PlaceCamera.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import UIKit
import Metal
import simd

// MARK: - NodeRenderCommand

struct PlaceCamera: MetalDrawable {
  let id: String
  let transform: float4x4 
  let cameraProjectionSettings: CameraProjectionSettings  
  let animations: [NodeTransition]?
  
  let storage: PlaceCamera.Storage  
  
  
  func withUpdated(transform: float4x4) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform)
  }
  
  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil)
  }
  
  func withUpdated(animations: [NodeTransition]) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil)
  }
  
  private func withUpdated(id: String?, 
                           animations: [NodeTransition]?,
                           transform: float4x4?) -> Self {
    .init(id: id ?? self.id,
          transform: transform ?? self.transform,
          cameraProjectionSettings: self.cameraProjectionSettings, 
          animations: animations ?? self.animations,         
          storage: storage)
  }
}

// MARK: - Updates

extension PlaceCamera {
  /// Updates the values in the command with any animations that are running.  
  func update(time: CFTimeInterval, previous: (any MetalDrawable)?) {
    if let dirtyTransform = attribute(at: time, cur: self.transform, prev: previous?.transform) {
      storage.set((dirtyTransform, self.cameraProjectionSettings))
    }
  }
  
  var needsRender: Bool { false }
  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?) {
    fatalError()
  }
}

// MARK: Storage
extension PlaceCamera {
  class Storage: MetalDrawable_Storage {    
    private(set) var device: MTLDevice?
    private(set) var surfaceAspect: Float?
    private(set) var viewProjBuffer: MTLBuffer?
  }
}

extension PlaceCamera.Storage {
  func set<Value>(_ value: Value) {
    if let tuple = value as? (float4x4, CameraProjectionSettings) {
      let viewM = tuple.0
      let camSettings = tuple.1
      
      let projM = float4x4.makePerspective(fovyRadians: camSettings.fov, 
                                           self.surfaceAspect ?? 1, 
                                           camSettings.zNear, 
                                           camSettings.zFar)
      let vpUniform = ViewProjectionUniform(projectionMatrix: projM, viewMatrix: viewM)      
      self.viewProjBuffer?.contents().storeBytes(of: vpUniform, as: ViewProjectionUniform.self)
    }
  }
  
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable)?,
               device: MTLDevice, 
               library: MetalShaderLibrary, 
               surfaceAspect: Float) {
    self.device = device
    self.surfaceAspect = surfaceAspect
    
    // Re-use previous buffers if they are the right size / data.
    if let prevStorage = previous?.storage as? PlaceCamera.Storage {
      self.viewProjBuffer = prevStorage.viewProjBuffer
    }
    
    if self.viewProjBuffer == nil {
      self.viewProjBuffer = device.makeBuffer(length: MemoryLayout<ViewProjectionUniform>.size)
    }
    
    if let command = command as? PlaceCamera {
      // Use the latest transform according to what our transitions will calculate
      let updatedTransform = command.attribute(at: CACurrentMediaTime(), cur: command.transform, prev: previous?.transform)    
      self.set((updatedTransform ?? command.transform, command.cameraProjectionSettings))      
    } else {
      fatalError()
    }
  }
}

// MARK: - Buffer Uniforms

struct ViewProjectionUniform {
  let projectionMatrix: float4x4
  let viewMatrix: float4x4
}
