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
}

// MARK: - Command

struct PlaceCamera: MetalDrawable, HasShaderPipeline {
  let id: String
  let transform: MetalDrawableData.Transform
  let projection: CameraProjection
  let shaderPipeline: (any MetalDrawable_Shader)?
  let animations: [NodeTransition]?

  let storage: PlaceCamera.Storage
  
  
  func withUpdated(transform: MetalDrawableData.Transform) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform, shaderPipeline: nil, projection: nil)
  }
  
  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil, shaderPipeline: nil, projection: nil)
  }
  
  func withUpdated(animations: [NodeTransition]) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil, shaderPipeline: nil, projection: nil)
  }

  func withUpdated(projection: CameraProjection) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil, shaderPipeline: nil, projection: projection)
  }

  func withUpdated<Shader: MetalDrawable_Shader>(shaderPipeline: Shader) -> any MetalDrawable {
    withUpdated(id: nil, animations: nil, transform: nil, shaderPipeline: shaderPipeline, projection: nil)
  }
  
  private func withUpdated(id: String?,
                           animations: [NodeTransition]?,
                           transform: MetalDrawableData.Transform?,
                           shaderPipeline: (any MetalDrawable_Shader)?,
                           projection: CameraProjection?) -> Self {
    .init(id: id ?? self.id,
          transform: transform ?? self.transform,
          projection: projection ?? self.projection,
          shaderPipeline: shaderPipeline ?? self.shaderPipeline,
          animations: animations ?? self.animations,
          storage: storage)
  }
}

// MARK: - Updates

extension PlaceCamera {
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
    shaderPipeline.setTextures(encoder: encoder)
    
    encoder.setFragmentBytes(&storage.skyboxInverseView, length: MemoryLayout<float4x4>.size, index: 0)
    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    encoder.endEncoding()
  }

  var latestViewPoint: float4x4 {
    self.storage.view.value
  }
}

// MARK: Storage
extension PlaceCamera {
  class Storage: MetalDrawable_Storage {
    private(set) var device: MTLDevice?
    private(set) var surfaceAspect: Float = 1
    private(set) var viewProjBuffer: MTLBuffer?

    private(set) var view: MetalDrawableData.Transform = .identity
    private(set) var projection: float4x4?
    var skyboxInverseView: float4x4 = .identity
  }
}

extension PlaceCamera.Storage {
  func set<Value>(_ value: Value) {
    if let tuple = value as? (MetalDrawableData.Transform, float4x4) {
      // Update matrices
      self.view = .init(value: tuple.0.value)
      let view = self.view.value.inverse
      let proj = tuple.1
      self.projection = proj

      // Update uniform
      let vpUniform = ViewProjectionUniform(projectionMatrix: proj, viewMatrix: view)
      self.viewProjBuffer?.contents().storeBytes(of: vpUniform, as: ViewProjectionUniform.self)

      // Skybox inverse view matrix.
      var viewDirectionMatrix = view
      viewDirectionMatrix.columns.3 = SIMD4<Float>(0, 0, 0, 1)
      let clipToViewDirectionTransform = (proj * viewDirectionMatrix).inverse
      self.skyboxInverseView = clipToViewDirectionTransform
    }
  }

  func update(time: CFTimeInterval, command: (any MetalDrawable), previous: (any MetalDrawable_Storage)?) {
    let previous = previous as? Self
    guard let command = command as? PlaceCamera else {
      fatalError()
    }

    let view = attribute(at: time,
                         cur: command.transform,
                         prev: previous?.view,
                         animation: command.animations?.with([.all]))

    let targetProj = command.projection.matrix(aspect: self.surfaceAspect)
    let projection = attribute(at: time,
                               cur: targetProj,
                               prev: previous?.projection,
                               animation: command.animations?.with([.all]))

    self.set((view, projection))
  }
  
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable_Storage)?,
               device: MTLDevice, 
               shaderLibrary: MetalShaderLibrary,
               geometryLibrary: MetalGeometryLibrary,
               surfaceAspect: Float) {
    let previous = previous as? Self
    guard let command = command as? PlaceCamera else {
      fatalError()
    }

    self.device = device
    self.surfaceAspect = surfaceAspect

    // Build the Pipeline
    command.shaderPipeline?.build(device: device, library: shaderLibrary, descriptor: nil)
    
    // Re-use previous buffers if they are the right size / data and
    // copy data from previous storage for animations.
    if let previous = previous {
      self.copy(from: previous)
    } else {
      // Make the buffers / data from scratch!
      self.viewProjBuffer = device.makeBuffer(length: MemoryLayout<ViewProjectionUniform>.size)
      self.set((command.transform, command.projection.matrix(aspect: self.surfaceAspect)))
    }
  }

  // Attempt to reuse any generated data or buffers from the existing storage from previous.
  func copy(from previous: PlaceCamera.Storage) {
    self.viewProjBuffer = previous.viewProjBuffer
    self.view = previous.view
    self.projection = previous.projection
    self.skyboxInverseView = previous.skyboxInverseView
  }
}
