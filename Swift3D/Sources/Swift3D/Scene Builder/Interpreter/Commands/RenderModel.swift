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
  let shaderPipeline: (any MetalDrawable_Shader)?
  let animations: [NodeTransition]?
  let storage: RenderModel.Storage

  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil)
  }

  func withUpdated(transform: MetalDrawableData.Transform) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform)
  }

  func withUpdated(animations: [NodeTransition]) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil)
  }

  func withUpdated<Shader: MetalDrawable_Shader>(shaderPipeline: Shader) -> any MetalDrawable {
    RenderModel(id: id,
                transform: transform,
                model: self.model,
                shaderPipeline: shaderPipeline,
                animations: animations,
                storage: self.storage)
  }

  private func withUpdated(id: String?,
                           animations: [NodeTransition]?,
                           transform: MetalDrawableData.Transform?) -> Self {
    RenderModel(id: id ?? self.id,
                transform: transform ?? self.transform,
                model: self.model,
                shaderPipeline: self.shaderPipeline,
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

    // Shaders and Uniforms
    if let pipeline = self.shaderPipeline {
      pipeline.setupEncoder(encoder: encoder)
    }
    else {
      if let ps = storage.customPipeline {
        encoder.setRenderPipelineState(ps)
      }

      var mat = MaterialSettings(
       lightingSettings: simd_float4(2, 2, 0, 0),
       albedoTextureScaling: simd_float4(x: 1, y: 1, z: 0, w: 0))

      encoder.setFragmentBytes(&mat, length: MemoryLayout<MaterialSettings>.size, index: FragmentBufferIndex.material.rawValue)
    }

    // Draw Meshes
    for mesh in storage.mesh {
      for (i, buffer) in mesh.0.vertexBuffers.enumerated() {
        encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
      }

      // TODO: Gotta wrap this into another class and simplify this flow.
      for (idx, submesh) in mesh.0.submeshes.enumerated() {
        if let mdlSubMesh = mesh.1.submeshes?[idx] as? MDLSubmesh,
           let material = mdlSubMesh.material {
          if let url = material.property(with: .baseColor)?.urlValue,
             let texture = storage.textures[url] {
            encoder.setFragmentTexture(texture, index: 0)
          }
        }

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

typealias StorageMesh = (MTKMesh, MDLMesh)

extension RenderModel {
  class Storage: MetalDrawable_Storage {
    private(set) var device: MTLDevice?

    private(set) var transform: MetalDrawableData.Transform = .identity
    private(set) var modelMatBuffer: MTLBuffer?

    private(set) var textures: [URL: MTLTexture] = [:]
    private(set) var mesh: [StorageMesh] = []
    private(set) var customPipeline: MTLRenderPipelineState?
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
      var transform = command.transform.value
      self.transform = command.transform
      self.modelMatBuffer = device.makeBuffer(bytes: &transform, length: float4x4.length)

      do {
        let asset = try command.model.asset(device: device, allocator: geometryLibrary.allocator)
        asset.loadTextures()

        guard let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] else {
          fatalError()
        }

        // Meshes
        let mtkMeshes = try mdlMeshes.map { mdlMesh in
          return try MTKMesh(mesh: mdlMesh, device: device)
        }
        self.mesh = zip(mdlMeshes, mtkMeshes).map { ($1, $0) }

        // Textures
        let materials = mdlMeshes.flatMap {
          if let subs = $0.submeshes as? [MDLSubmesh] {
            return subs.compactMap { $0.material }
          }
          return []
        }
        self.textures = textures(for: materials, device: device)
      } catch {
        fatalError("RenderModel Model Failure")
      }
    }

    // Set up our shader pipelines
    var vertexDescriptor: MTLVertexDescriptor?
    if let modelDescriptor = self.mesh.first?.0.vertexDescriptor {
      vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(modelDescriptor)
    }

    if let shader = command.shaderPipeline {
      shader.build(device: device,
                   library: shaderLibrary,
                   descriptor: vertexDescriptor)
    } else {
      customPipeline = shaderLibrary.pipeline(for: "standard_vertex",
                                        fragment: "standard_fragment",
                                        vertexDescriptor: vertexDescriptor)
    }
  }

  func copy(from previous: RenderModel.Storage) {
    self.transform = previous.transform
    self.modelMatBuffer = previous.modelMatBuffer
    self.mesh = previous.mesh
    self.textures = previous.textures
  }

  private func textures(for materials: [MDLMaterial], device: MTLDevice) -> [URL: MTLTexture] {
    var mutTex: [URL: MTLTexture] = [:]
    let textureLoader = MTKTextureLoader(device: device)


    for material in materials {
      if let baseCol = texture(for: .baseColor, in: material, loader: textureLoader) {
        mutTex[baseCol.0] = baseCol.1
      }
    }

    return mutTex
  }

  private func texture(for semantic: MDLMaterialSemantic, in material: MDLMaterial, loader: MTKTextureLoader) -> (URL, MTLTexture)? {
    let options: [MTKTextureLoader.Option : Any] = [
        .textureUsage : MTLTextureUsage.shaderRead.rawValue,
        .textureStorageMode : MTLStorageMode.private.rawValue,
        .origin : MTKTextureLoader.Origin.bottomLeft.rawValue
    ]

    for i in 0..<material.count {
      if let property = material[i] {
        let type = property.type
        print("Property (\(i): \(property) - \(type)")
      }
    }

    if let prop = material.property(with: semantic) {
      let type = prop.type
      if type == .texture,
        let url = prop.urlValue,
         let tex = try? loader.newTexture(URL: url, options: options) {
        return (url, tex)
      }
    }

    return nil
  }
}

