//
//  NodeRenderCommand.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import UIKit
import Metal
import simd

// MARK: - NodeRenderCommand

struct RenderGeometry: MetalDrawable {  
  let id: String
  let transform: float4x4
  let geometry: RawVertices?  
  let renderType: MetalDrawableData.RenderType?
  let animations: [NodeTransition]?
  let storage: RenderGeometry.Storage

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
          geometry: self.geometry, 
          renderType: self.renderType, 
          animations: animations ?? self.animations, 
          storage: self.storage)
  }
}

// MARK: - Render

extension RenderGeometry {
  func render(encoder: MTLRenderCommandEncoder) {
    // Shaders
    if let ps = storage.pipelineState {
      encoder.setRenderPipelineState(ps)
    }
    
    // Vertices
    if let vb = storage.vertexBuffer {
      encoder.setVertexBuffer(vb, offset: 0, index: 0)
    }
    
    if let modelM = storage.modelMatBuffer {
      encoder.setVertexBuffer(modelM, offset: 0, index: 1)
    }
    
    // Draw
    switch renderType {
    case .none:
      break
    case .triangles(let instanceCount):
      encoder.drawPrimitives(type: .triangle, 
                             vertexStart: 0, 
                             vertexCount: instanceCount * 3, 
                             instanceCount: instanceCount)
    }
    
    encoder.endEncoding()
  }
}

// MARK: - Storage

extension RenderGeometry {
  class Storage: MetalDrawable_Storage {    
    private(set) var device: MTLDevice?
    private(set) var pipelineState: MTLRenderPipelineState?
    private(set) var vertexBuffer: MTLBuffer?
    private(set) var modelMatBuffer: MTLBuffer?
  }
}

extension RenderGeometry.Storage {
  func set<Value>(_ value: Value) {
    if let t = value as? float4x4 {
      self.modelMatBuffer?.contents().storeBytes(of: t, as: float4x4.self)
    }
  }
  
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable)?,
               device: MTLDevice, 
               library: MetalShaderLibrary, 
               surfaceAspect: Float) {
    self.device = device
    
    // Re-use previous buffers if they are the right size / data.
    if let prevStorage = previous?.storage as? RenderGeometry.Storage {
      if let command_geo = command.geometry,
         let prev_geo = previous?.geometry,
         command_geo.isEqualTo(prev_geo) {
        self.vertexBuffer = prevStorage.vertexBuffer
      }
      
      self.modelMatBuffer = prevStorage.modelMatBuffer
    }
    
    // Make new buffers where needed.
    if self.vertexBuffer == nil {
      self.vertexBuffer = command.geometry?.createBuffer(device: device)
    }
    
    if self.modelMatBuffer == nil {
      self.modelMatBuffer = device.makeBuffer(length: float4x4.length)
    }
    
    // Use the latest transform according to what our transitions will calculate
    let updatedTransform = command.attribute(at: CACurrentMediaTime(), cur: command.transform, prev: previous?.transform)    
    set(updatedTransform ?? command.transform)

    self.pipelineState = library.pipeline(for: "basic_vertex", fragment: "basic_fragment") 
  }
}

