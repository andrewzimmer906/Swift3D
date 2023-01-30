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

protocol WithPipeline {
  func withUpdated(pipelineData: MetalDrawable_CustomShaderData) -> Self
}

// MARK: - NodeRenderCommand

struct RenderGeometry<Geometry: MetalDrawable_Geometry>: MetalDrawable, WithPipeline {  
  let id: String
  let transform: float4x4
  let geometry: Geometry
  let shaderPipeline: MetalDrawableData.ShaderPipeline?
  let renderType: MetalDrawableData.RenderType?  
  let animations: [NodeTransition]?
  let storage: RenderGeometry.Storage
  let cullBackfaces: Bool

  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil, shaderPipeline: nil)
  }
  
  func withUpdated(transform: float4x4) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform, shaderPipeline: nil)
  }
  
  func withUpdated(animations: [NodeTransition]) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil, shaderPipeline: nil)
  }
  
  func withUpdated(pipelineData: MetalDrawable_CustomShaderData) -> Self {
    let pipeline = self.shaderPipeline?.withCustomData(pipelineData)
    return withUpdated(id: nil, animations: nil, transform: nil, shaderPipeline: pipeline)
  }
  
  private func withUpdated(id: String?, 
                           animations: [NodeTransition]?,
                           transform: float4x4?,
                           shaderPipeline: MetalDrawableData.ShaderPipeline?) -> Self {
    .init(id: id ?? self.id, 
          transform: transform ?? self.transform, 
          geometry: self.geometry,
          shaderPipeline: shaderPipeline ?? self.shaderPipeline,
          renderType: self.renderType, 
          animations: animations ?? self.animations, 
          storage: self.storage,
          cullBackfaces: cullBackfaces)
  }
}

// MARK: - Render

extension RenderGeometry {  
  func update(time: CFTimeInterval, previous: (any MetalDrawable)?) {
    if let dirtyTransform = attribute(at: time, cur: self.transform, prev: previous?.transform) {
      storage.set(dirtyTransform)
    }
    
    switch self.shaderPipeline {
    case .custom(_, _, let data):
        storage.set(data)
    default:
      break
    }
  }
  
  var needsRender: Bool { true }
  
  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?) {
    // Depth and Stencil
    encoder.setDepthStencilState(depthStencil)
    encoder.setFrontFacing(.clockwise)
    encoder.setCullMode(cullBackfaces ? .back : .none)
    
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
    
    if let customV = storage.customValues {
      encoder.setVertexBuffer(customV, offset: 0, index: 4)
    }
    
    // Draw
    switch renderType {
    case .none:
      break
    case .triangles:
      if let indexBuffer = storage.indexBuffer {
        encoder.drawIndexedPrimitives(type: .triangle, 
                                      indexCount: self.geometry.numPoints, 
                                      indexType: .uint16, 
                                      indexBuffer: indexBuffer, 
                                      indexBufferOffset: 0, 
                                      instanceCount: self.geometry.numPoints / 3)
      }
      else {
        encoder.drawPrimitives(type: .triangle, 
                               vertexStart: 0, 
                               vertexCount: self.geometry.numPoints, 
                               instanceCount: self.geometry.numPoints / 3)
      }
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
    private(set) var indexBuffer: MTLBuffer?
    private(set) var modelMatBuffer: MTLBuffer?
    
    private(set) var customValues: MTLBuffer?
  }
}

extension RenderGeometry.Storage {
  func set<Value>(_ value: Value) {
    if let t = value as? float4x4 {
      self.modelMatBuffer?.contents().storeBytes(of: t, as: float4x4.self)
    }
    
    if let t = value as? MetalDrawable_CustomShaderData {
      t.set(self.customValues)
    }
  }
  
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable)?,
               device: MTLDevice, 
               library: MetalShaderLibrary, 
               surfaceAspect: Float) {
    guard let command = command as? RenderGeometry else {
      fatalError()
    }
    let previous = previous as? RenderGeometry
    
    self.device = device
    
    // Re-use previous buffers if they are the right size / data.
    if let prevStorage = previous?.storage as? RenderGeometry.Storage {
      if let prev_geo = previous?.geometry,
         command.geometry.isEqualTo(prev_geo) {
          self.vertexBuffer = prevStorage.vertexBuffer
          self.indexBuffer = prevStorage.indexBuffer
        }
      
      switch (command.shaderPipeline, previous?.shaderPipeline) {
      case (.custom(_, _, let dataA), .custom(_ , _, let dataB)):
        if dataA.sameType(dataB) {
          self.customValues = prevStorage.customValues
        }
      default:
        break
      }
      
      self.modelMatBuffer = prevStorage.modelMatBuffer
    }
    
    // Make new buffers where needed.
    if self.vertexBuffer == nil {
      self.vertexBuffer = command.geometry.createBuffer(device: device)
    }
    
    if self.indexBuffer == nil {
      self.indexBuffer = command.geometry.createIndexBuffer(device: device)
    }
    
    if self.modelMatBuffer == nil {
      self.modelMatBuffer = device.makeBuffer(length: float4x4.length)
    }
    
    // Use the latest transform according to what our transitions will calculate
    let updatedTransform = command.attribute(at: CACurrentMediaTime(), cur: command.transform, prev: previous?.transform)    
    set(updatedTransform ?? command.transform)

    // Set up our shader pipeline.
    if let shaderPipe = command.shaderPipeline {
      switch shaderPipe {
      case .standard(let vert, let frag):
        self.pipelineState = library.pipeline(for: vert, fragment: frag)
      case .custom(let vert, let frag, let data):
        self.pipelineState = library.pipeline(for: vert, fragment: frag)
        if self.customValues == nil {          
          self.customValues = data.createBuffer(device: device)          
        }
      }
    } else {
      self.pipelineState = library.pipeline(for: "basic_vertex", fragment: "basic_fragment")
    }
  }
}

