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
  var cacheKey: String { "obj_model" }

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

  func textures(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTLTexture {
    let asset = MDLAsset(url: url, vertexDescriptor: Vertex.descriptor, bufferAllocator: allocator)
    asset.loadTextures()

    let textureLoader = MTKTextureLoader(device: device)
    let options: [MTKTextureLoader.Option : Any] = [
        .textureUsage : MTLTextureUsage.shaderRead.rawValue,
        .textureStorageMode : MTLStorageMode.private.rawValue,
        .origin : MTKTextureLoader.Origin.bottomLeft.rawValue
    ]

    let meshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh]
    let firstSubmesh = meshes?.first?.submeshes?.firstObject as? MDLSubmesh

    let material = firstSubmesh?.material

    if let baseColorProperty = material?.property(
        with: MDLMaterialSemantic.baseColor)
    {
        if baseColorProperty.type == .texture,
           let textureURL = baseColorProperty.urlValue
        {
            if let texture = try? textureLoader.newTexture(
                URL: textureURL,
                options: options) {
              return texture
            }
        }
    }

    throw ModelLoadError.noTextures
  }
}
