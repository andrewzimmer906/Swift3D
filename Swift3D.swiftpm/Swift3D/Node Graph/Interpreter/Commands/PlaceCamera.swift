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

// MARK: - Buffer Uniforms

struct ViewProjectionUniform {
  let projectionMatrix: float4x4
  let viewMatrix: float4x4
  let clipToViewMatrix: float4x4
}

// MARK: - Command

struct PlaceCamera: MetalDrawable, HasShaderPipeline {
  let id: String
  let transform: float4x4
  let cameraProjectionSettings: CameraProjectionSettings
  let shaderPipeline: (any MetalDrawable_Shader)?
  let animations: [NodeTransition]?
  //private var geometry: StandardGeometry { Octahedron.get(divisions: 3) }
  private var geometry: StandardGeometry { Cube.get() }

  let storage: PlaceCamera.Storage
  
  
  func withUpdated(transform: float4x4) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform, shaderPipeline: nil)
  }
  
  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil, shaderPipeline: nil)
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
    .init(id: id ?? self.id,
          transform: transform ?? self.transform,
          cameraProjectionSettings: self.cameraProjectionSettings,
          shaderPipeline: shaderPipeline ?? self.shaderPipeline,
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
  
  var needsRender: Bool { shaderPipeline != nil }

  // Render our skybox.
  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?) {
    guard let shaderPipeline = shaderPipeline else {
      fatalError()
    }

    // encoder.setDepthStencilState(depthStencil)
    encoder.setFrontFacing(.counterClockwise)
    encoder.setCullMode(.none)

    // Shaders and Uniforms
    shaderPipeline.setupEncoder(encoder: encoder)
    encoder.setFragmentBytes(&storage.skyboxInverseView, length: MemoryLayout<float4x4>.size, index: 0)
    encoder.setFragmentSamplerState(storage.samplerState, index: 0)

    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

    
    /*

    // Vertices
    if let vb = storage.skyboxVertices {
      encoder.setVertexBuffer(vb, offset: 0, index: 0)
    }

    // Transform
    if let modelM = storage.skyboxTransform {
      encoder.setVertexBuffer(modelM, offset: 0, index: 1)
    }

    // Shaders and Uniforms
    shaderPipeline.setupEncoder(encoder: encoder)

    // Draw
    if let indexBuffer = storage.skyboxIndices {
      encoder.drawIndexedPrimitives(type: .triangle,
                                    indexCount: self.geometry.numPoints,
                                    indexType: .uint16,
                                    indexBuffer: indexBuffer,
                                    indexBufferOffset: 0,
                                    instanceCount: self.geometry.numPoints / 3)
    }
*/
    encoder.endEncoding()
  }
}

// MARK: Storage
extension PlaceCamera {
  class Storage: MetalDrawable_Storage {    
    private(set) var device: MTLDevice?
    private(set) var surfaceAspect: Float?
    private(set) var viewProjBuffer: MTLBuffer?

    private(set) var skyboxVertices: MTLBuffer?
    private(set) var skyboxIndices: MTLBuffer?
    var skyboxTransform: MTLBuffer?
    var skyboxInverseView: float4x4 = .identity
    var samplerState: MTLSamplerState?
  }
}

extension PlaceCamera.Storage {
  func set<Value>(_ value: Value) {
    if let tuple = value as? (float4x4, CameraProjectionSettings) {
      let viewM = tuple.0
      let camSettings = tuple.1

      let projM = camSettings.matrix(aspect: self.surfaceAspect ?? 1)

      var viewDirectionMatrix = viewM
      viewDirectionMatrix.columns.3 = SIMD4<Float>(0, 0, 0, 1)
      let clipToViewDirectionTransform = (projM * viewDirectionMatrix).inverse


      let vpUniform = ViewProjectionUniform(projectionMatrix: projM, viewMatrix: viewM, clipToViewMatrix: clipToViewDirectionTransform)
      self.viewProjBuffer?.contents().storeBytes(of: vpUniform, as: ViewProjectionUniform.self)

      self.skyboxInverseView = clipToViewDirectionTransform
      // self.skyboxTransform?.contents().storeBytes(of: clipToViewDirectionTransform, as: float4x4.self)
    }
  }
  
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable)?,
               device: MTLDevice, 
               library: MetalShaderLibrary, 
               surfaceAspect: Float) {
    guard let command = command as? PlaceCamera else {
      fatalError()
    }

    let previous = previous as? PlaceCamera

    self.device = device
    self.surfaceAspect = surfaceAspect

    // Build the Pipeline
    command.shaderPipeline?.build(device: device, library: library, previous: previous?.shaderPipeline)
    
    // Re-use previous buffers if they are the right size / data.
    if let prevStorage = previous?.storage as? PlaceCamera.Storage {
      self.viewProjBuffer = prevStorage.viewProjBuffer
      self.skyboxVertices = prevStorage.skyboxVertices
      self.skyboxIndices = prevStorage.skyboxIndices
      self.skyboxTransform = prevStorage.skyboxTransform
    }
    
    if self.viewProjBuffer == nil {
      self.viewProjBuffer = device.makeBuffer(length: MemoryLayout<ViewProjectionUniform>.size)
    }

    if self.skyboxVertices == nil {
      self.skyboxVertices = command.geometry.createBuffer(device: device)
      self.skyboxIndices = command.geometry.createIndexBuffer(device: device)
    }

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.normalizedCoordinates = true
    samplerDescriptor.magFilter = .linear
    samplerDescriptor.minFilter = .linear
    samplerDescriptor.mipFilter = .linear
    samplerDescriptor.sAddressMode = .repeat
    samplerDescriptor.tAddressMode = .repeat
    samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!

    
    if self.skyboxTransform == nil {
      self.skyboxTransform = device.makeBuffer(length: MemoryLayout<float4x4>.size)
    }

    // Use the latest transform according to what our transitions will calculate
    let updatedTransform = command.attribute(at: CACurrentMediaTime(), cur: command.transform, prev: previous?.transform)
    self.set((updatedTransform ?? command.transform, command.cameraProjectionSettings))
    // self.set(command.skyboxPlacement(updatedTransform ?? command.transform))
  }
}
