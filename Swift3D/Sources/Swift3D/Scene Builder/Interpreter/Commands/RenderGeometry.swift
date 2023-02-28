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

protocol AcceptsViewPointUpdate {
  func update(viewPoint: float4x4)
}

protocol HasShaderPipeline {
  func withUpdated<Shader: MetalDrawable_Shader>(shaderPipeline: Shader) -> any MetalDrawable
}

// MARK: - NodeRenderCommand

struct RenderGeometry: MetalDrawable, HasShaderPipeline {
  let id: String
  let transform: MetalDrawableData.Transform
  let geometry: any MetalDrawable_Geometry
  let shaderPipeline: any MetalDrawable_Shader
  let renderType: MetalDrawableData.RenderType?  
  let animations: [NodeTransition]?
  let storage: RenderGeometry.Storage
  let cullBackfaces: Bool

  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil, shaderPipeline: nil)
  }
  
  func withUpdated(transform: MetalDrawableData.Transform) -> Self {
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
                           transform: MetalDrawableData.Transform?,
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
    encoder.setFrontFacing(.counterClockwise)
    encoder.setCullMode(cullBackfaces ? .back : .none)    
    
    // Vertices
    var bytes = VertexUniform(modelMatrix: storage.transform.value, normalMatrix: storage.normalMatrix)
    encoder.setVertexBytes(&bytes, length: MemoryLayout<VertexUniform>.size, index: 1)
    
    // Shaders and Uniforms
    self.shaderPipeline.setupEncoder(encoder: encoder)
    self.shaderPipeline.setTextures(encoder: encoder)

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
  class Storage: MetalDrawable_Storage, AcceptsViewPointUpdate {
    private(set) var device: MTLDevice?
    private(set) var mesh: MTKMesh?

    private(set) var normalMatrix: float3x3 = float3x3(1)
    private(set) var transform: MetalDrawableData.Transform = .identity
  }
}

extension RenderGeometry.Storage {
  func set<Value>(_ value: Value) {
    if let t = value as? MetalDrawableData.Transform {
      self.transform = t
    } else if let t = value as? float4x4 {
      let mvMat = t * self.transform.value
      self.normalMatrix = mvMat.upperLeft3x3.transpose.inverse
    }
  }

  func update(time: CFTimeInterval,
              command: (any MetalDrawable),
              previous: (any MetalDrawable_Storage)?) {
    let previous = previous as? RenderGeometry.Storage
    let transform = attribute(at: time,
                              cur: command.transform,
                              prev: previous?.transform,
                              animation: command.animations?.with([.all]))
    set(transform)
  }

  func update(viewPoint: float4x4) {
    set(viewPoint)
  }
  
  func build(_ command: (any MetalDrawable),
             previous: (any MetalDrawable_Storage)?,
             device: MTLDevice,
             shaderLibrary: MetalShaderLibrary,
             geometryLibrary: MetalGeometryLibrary,
             surfaceAspect: Float) {
    guard let command = command as? RenderGeometry else {
      fatalError()
    }
    
    let previous = previous as? RenderGeometry.Storage
    self.device = device


    if let previous = previous {
      copy(from: previous)
    }
    else {
      self.transform = command.transform
      self.mesh = geometryLibrary.cachedMesh(command.geometry)
    }
    
    // set up our shader pipeline
    var vertexDescriptor: MTLVertexDescriptor?
    if let modelDescriptor = self.mesh?.vertexDescriptor {
      vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(modelDescriptor)
    }

    command.shaderPipeline.build(device: device,
                                 library: shaderLibrary,
                                 descriptor: vertexDescriptor)
  }

  func copy(from previous: RenderGeometry.Storage) {
    self.transform = previous.transform

    self.mesh = previous.mesh
  }
}

