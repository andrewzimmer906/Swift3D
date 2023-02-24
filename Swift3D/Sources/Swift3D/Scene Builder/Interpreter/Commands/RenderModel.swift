//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/20/23.
//

import Foundation
import UIKit
import Metal
import MetalKit
import simd

// MARK: - NodeRenderCommand

struct RenderModel: MetalDrawable, HasShaderPipeline {
  let id: String
  let transform: MetalDrawableData.Transform
  let model: Model
  let shaderPipeline: any MetalDrawable_Shader
  let overrideTextures: Bool
  let animations: [NodeTransition]?
  let storage: RenderModel.Storage




  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil, overrideTextures: nil)
  }

  func withUpdated(transform: MetalDrawableData.Transform) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform, overrideTextures: nil)
  }

  func withUpdated(animations: [NodeTransition]) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil, overrideTextures: nil)
  }

  func withUpdated(overrideTextures: Bool) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil, overrideTextures: overrideTextures)
  }

  func withUpdated<Shader: MetalDrawable_Shader>(shaderPipeline: Shader) -> any MetalDrawable {
    RenderModel(id: id,
                transform: transform,
                model: model,
                shaderPipeline: shaderPipeline,
                overrideTextures: overrideTextures,
                animations: animations,
                storage: storage)
  }

  private func withUpdated(id: String?,
                           animations: [NodeTransition]?,
                           transform: MetalDrawableData.Transform?,
                           overrideTextures: Bool?) -> Self {
    RenderModel(id: id ?? self.id,
                transform: transform ?? self.transform,
                model: self.model,
                shaderPipeline: self.shaderPipeline,
                overrideTextures: overrideTextures ?? self.overrideTextures,
                animations: animations ?? self.animations,
                storage: self.storage)
  }
}

// MARK: - Render

extension RenderModel {
  var needsRender: Bool { true }

  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?) {
    // Depth and Stencil
    encoder.setDepthStencilState(depthStencil)
    encoder.setFrontFacing(.counterClockwise)
    encoder.setCullMode(.back)

    // Vertices
    if let modelM = storage.modelMatBuffer {
      encoder.setVertexBuffer(modelM, offset: 0, index: 1)
    }

    shaderPipeline.setupEncoder(encoder: encoder)
    if overrideTextures {
      shaderPipeline.setTextures(encoder: encoder)
    }

    storage.meshAndTextures?.draw(encoder: encoder,
                                  useModelTextures: !overrideTextures)

    encoder.endEncoding()
  }
}

// MARK: - Storage

extension RenderModel {
  class Storage: MetalDrawable_Storage {
    private(set) var device: MTLDevice?

    private(set) var transform: MetalDrawableData.Transform = .identity
    private(set) var modelMatBuffer: MTLBuffer?

    fileprivate var meshAndTextures: MeshAndTextureStorage?
  }
}

extension RenderModel.Storage {
  func set<Value>(_ value: Value) {
    if let t = value as? MetalDrawableData.Transform {
      self.transform = t
      self.modelMatBuffer?.contents().storeBytes(of: t.value, as: float4x4.self)
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

  func build(_ command: (any MetalDrawable),
             previous: (any MetalDrawable_Storage)?,
             device: MTLDevice,
             shaderLibrary: MetalShaderLibrary,
             geometryLibrary: MetalGeometryLibrary,
             surfaceAspect: Float) {
    guard let command = command as? RenderModel else {
      fatalError()
    }

    let previous = previous as? RenderModel.Storage
    self.device = device

    if let previous = previous {
      copy(from: previous)
    }
    else {
      meshAndTextures = .init(device: device)
      meshAndTextures?.build(model: command.model,
                             geometryLibrary: geometryLibrary,
                             shaderLibrary: shaderLibrary)

      var transform = command.transform.value
      self.transform = command.transform
      self.modelMatBuffer = device.makeBuffer(bytes: &transform, length: float4x4.length)
    }

    command.shaderPipeline.build(device: device,
                                 library: shaderLibrary,
                                 descriptor: meshAndTextures?.vertexDescriptor)
  }

  func copy(from previous: RenderModel.Storage) {
    self.transform = previous.transform
    self.modelMatBuffer = previous.modelMatBuffer
    self.meshAndTextures = previous.meshAndTextures
  }
}

// MARK: - Model + Texture

typealias StorageMesh = (MTKMesh, MDLMesh)
extension RenderModel {
  fileprivate class MeshAndTextureStorage {
    let device: MTLDevice

    private lazy var textureLoader: MTKTextureLoader = {
      MTKTextureLoader(device: device)
    }()
    private(set) var textures: [URL: MTLTexture] = [:]
    private(set) var mesh: [StorageMesh] = []
    var vertexDescriptor: MTLVertexDescriptor? {
      if let modelDesc = mesh.first?.0.vertexDescriptor {
        return MTKMetalVertexDescriptorFromModelIO(modelDesc)
      }
      return nil
    }

    init(device: MTLDevice) {
      self.device = device
    }

    func set<Value>(_ value: Value) {
      if let texValue = value as? (URL, MTLTexture) {
        textures[texValue.0] = texValue.1
      } else if let meshValue = value as? StorageMesh {
        mesh.append(meshValue)
      }
    }

    func build(model: Model, geometryLibrary: MetalGeometryLibrary, shaderLibrary: MetalShaderLibrary) {
      do {
        let asset = try model.asset(device: device, allocator: geometryLibrary.allocator)
        asset.loadTextures()

        guard let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] else {
          fatalError()
        }

        // Load Meshes
        let mtkMeshes = try mdlMeshes.map { mdlMesh in
          return try MTKMesh(mesh: mdlMesh, device: device)
        }
        self.mesh = zip(mdlMeshes, mtkMeshes).map { ($1, $0) }

        // Load Textures
        let materials = mdlMeshes.flatMap {
          ($0.submeshes as? [MDLSubmesh] ?? []).compactMap { $0.material }
        }

        materials.forEach { material in
          set((material.url(for: .baseColor),
               material.texture(for: .baseColor, library: shaderLibrary, loader: textureLoader)))
        }
      } catch {
        fatalError("RenderModel Model Failure")
      }
    }

    func draw(encoder: MTLRenderCommandEncoder, useModelTextures: Bool) {
      for storageMesh in mesh {
        for (i, buffer) in storageMesh.0.vertexBuffers.enumerated() {
          encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
        }

        for (idx, submesh) in storageMesh.0.submeshes.enumerated() {
          if useModelTextures {
            if let sub = storageMesh.1.submeshes?[idx] as? MDLSubmesh,
               let mat = sub.material {
              setTextures(with: mat, encoder: encoder)
            }
          }

          // Draw
          let indexBuffer = submesh.indexBuffer
          encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                        indexCount: submesh.indexCount,
                                        indexType: submesh.indexType,
                                        indexBuffer: indexBuffer.buffer,
                                        indexBufferOffset: indexBuffer.offset)
        }
      }
    }

    func setTextures(with material: MDLMaterial, encoder: MTLRenderCommandEncoder) {
      if let url = material.url(for: .baseColor),
         let albedo = textures[url] {
        encoder.setFragmentTexture(albedo, index: 0)
      }
    }
  }
}
