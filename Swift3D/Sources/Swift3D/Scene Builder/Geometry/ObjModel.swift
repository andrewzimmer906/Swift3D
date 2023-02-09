//
//  Model.swift
//  
//
//  Created by Andrew Zimmer on 2/7/23.
//

import Foundation
import ModelIO
import MetalKit

enum ObjLoadError: Error {
  case unsupportedType
  case noMeshes
}

struct ObjModel: MetalDrawable_Geometry {
  let url: URL
  var cacheKey: String { "obj_model" }

  func get(device: MTLDevice, allocator: MTKMeshBufferAllocator) throws -> MTKMesh {
    guard MDLAsset.canImportFileExtension("obj") else {
      throw ObjLoadError.unsupportedType
    }
    
    let asset = MDLAsset(url: url, vertexDescriptor: Vertex.descriptor, bufferAllocator: allocator)
    let meshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh]
    guard let assetMesh = meshes?.first else {
      throw ObjLoadError.noMeshes
    }

    return try MTKMesh(mesh: assetMesh, device: device)
  }
}
