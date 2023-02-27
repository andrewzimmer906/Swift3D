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
    addOrthoTan(to: assetMesh)

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

  func key(for semantic: MDLMaterialSemantic) -> String? {

    if let prop = self.property(with: semantic) {
      let type = prop.type
      switch type {
      case .float3:
        fallthrough
      case .float4:
        fallthrough
      case .color:
        let color = color(from: prop)
        return "Color(r(\(color.x))_g(\(color.y)_b(\(color.z)_a(\(color.w))"
      case .texture:
        return "type: \(semantic.rawValue)_\(prop.urlValue?.absoluteString ?? "")"
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
      case .float3:
        fallthrough
      case .float4:
        fallthrough
      case .color:
        let col = color(from: prop)
        return library.texture(color: col)

      case .texture:
        if let mdlTex = prop.textureSamplerValue?.texture {
          let tex = try? loader.newTexture(texture: mdlTex, options: Self.options)
          return tex
        }

      default:
        break
      }
    }

    return nil
  }

  private func color(from prop: MDLMaterialProperty) -> simd_float4 {
    switch prop.type {
    case .float4:
      return simd_float4(prop.float3Value, 1)
    case .float3:
      return prop.float4Value
    case .color:
      let color = prop.color ?? CGColor(red: 1, green: 1, blue: 1, alpha: 1)
      if let components = color.components,
         color.numberOfComponents == 4 {
        return simd_float4(Float(components[0]), Float(components[1]), Float(components[2]), Float(components[3]))
      }
    default:
      break
    }

    return .zero
  }
}
