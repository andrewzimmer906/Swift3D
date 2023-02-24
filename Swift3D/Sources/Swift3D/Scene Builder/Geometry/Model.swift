//
//  Model.swift
//  
//
//  Created by Andrew Zimmer on 2/7/23.
//

import Foundation
import ModelIO
import MetalKit

enum ModelLoadError: Error {
  case unsupportedType
  case noMeshes
  case noTextures
}

struct Model: MetalDrawable_Geometry {
  let url: URL
  var cacheKey: String { "some_model" }

  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    let asset = try asset(device: device, allocator: allocator)
    let meshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh]
    guard let assetMesh = meshes?.first else {
      throw ModelLoadError.noMeshes
    }

    return try MTKMesh(mesh: assetMesh, device: device)
  }

  func asset(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MDLAsset {
    guard MDLAsset.canImportFileExtension(url.pathExtension) else {
      throw ModelLoadError.unsupportedType
    }
    let asset = MDLAsset(url: url, vertexDescriptor: Vertex.descriptor, bufferAllocator: allocator)
    return asset
  }
}

extension MDLMaterial {
  private static let options: [MTKTextureLoader.Option : Any] = [
    .textureUsage : MTLTextureUsage.shaderRead.rawValue,
    .textureStorageMode : MTLStorageMode.private.rawValue,
    .origin : MTKTextureLoader.Origin.bottomLeft.rawValue
  ]

  func url(for semantic: MDLMaterialSemantic) -> URL? {
    if let prop = self.property(with: semantic) {
      let type = prop.type
      switch type {
      case .texture:
        return prop.urlValue
      default:
        break
      }
    }
    
    return nil
  }

  func texture(for semantic: MDLMaterialSemantic,
               library: MetalShaderLibrary,
               loader: MTKTextureLoader) -> MTLTexture? {
    if let prop = self.property(with: semantic) {
      let type = prop.type
      switch type {
      case .texture:
        if let url = prop.urlValue,
           let tex = try? loader.newTexture(URL: url, options: Self.options) {
          return tex
        }

      default:
        break
      }
    }

    return nil
  }
}
