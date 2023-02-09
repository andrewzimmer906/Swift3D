//
//  NodeRenderCommand.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import UIKit
import Metal
import MetalKit
import simd

protocol HasShaderPipeline {
  func withUpdated<Shader: MetalDrawable_Shader>(shaderPipeline: Shader) -> any MetalDrawable
}

// MARK: - NodeRenderCommand

struct RenderGeometry: MetalDrawable, HasShaderPipeline {
  let id: String
  let transform: float4x4
  let geometry: any MetalDrawable_Geometry
  let shaderPipeline: any MetalDrawable_Shader
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
  
  func withUpdated<Shader: MetalDrawable_Shader>(shaderPipeline: Shader) -> any MetalDrawable {
    withUpdated(id: nil, animations: nil, transform: nil, shaderPipeline: shaderPipeline)
  }
  
  private func withUpdated(id: String?,
                           animations: [NodeTransition]?,
                           transform: float4x4?, 
                           shaderPipeline: (any MetalDrawable_Shader)?) -> Self {
      RenderGeometry.init(id: id ?? self.id, 
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
  var needsRender: Bool { true }
  
  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?) {
    // Depth and Stencil
    encoder.setDepthStencilState(depthStencil)
    encoder.setFrontFacing(.clockwise)
    encoder.setCullMode(cullBackfaces ? .back : .none)    
    
    // Vertices
    if let vb = storage.vertexBuffer {
      encoder.setVertexBuffer(vb, offset: 0, index: 0)
    }
    
    if let modelM = storage.modelMatBuffer {
      encoder.setVertexBuffer(modelM, offset: 0, index: 1)
    }
    
    // Shaders and Uniforms
    self.shaderPipeline.setupEncoder(encoder: encoder)

    // Draw Meshes
    if let mesh = storage.mesh {
      for (i, buffer) in mesh.vertexBuffers.enumerated() {
        encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
      }

      for submesh in mesh.submeshes {
        let indexBuffer = submesh.indexBuffer
        encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                      indexCount: submesh.indexCount,
                                      indexType: submesh.indexType,
                                      indexBuffer: indexBuffer.buffer,
                                      indexBufferOffset: indexBuffer.offset)
      }
    }
    
    encoder.endEncoding()
  }
}

// MARK: - Storage

extension RenderGeometry {
  class Storage: MetalDrawable_Storage {    
    private(set) var device: MTLDevice?
    private(set) var mesh: MTKMesh?
    private(set) var vertexBuffer: MTLBuffer?
    private(set) var indexBuffer: MTLBuffer?
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
             shaderLibrary: MetalShaderLibrary,
             geometryLibrary: MetalGeometryLibrary,
             surfaceAspect: Float) {
    guard let command = command as? RenderGeometry else {
      fatalError()
    }
    
    let previous = previous as? RenderGeometry    
    self.device = device
    
    // Re-use previous buffers if they are the right size / data.
    if let prevStorage = previous?.storage as? RenderGeometry.Storage {
      self.modelMatBuffer = prevStorage.modelMatBuffer
    }
    
    // set up our shader pipeline
    self.mesh = geometryLibrary.cachedMesh(command.geometry)

    var vertexDescriptor: MTLVertexDescriptor?
    if let modelDescriptor = self.mesh?.vertexDescriptor {
      vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(modelDescriptor)
    }

    command.shaderPipeline.build(device: device,
                                 library: shaderLibrary)

    // Save Model Transform
    if self.modelMatBuffer == nil {
      self.modelMatBuffer = device.makeBuffer(length: float4x4.length)
    }

    // Use the latest transform according to what our transitions will calculate
    self.set(command.transform)
    command.update(time: CACurrentMediaTime(), previous: previous)
  }
}

