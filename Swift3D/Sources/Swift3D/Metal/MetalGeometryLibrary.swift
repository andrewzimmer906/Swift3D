//
//  MetalGeometryLibrary.swift
//  
//
//  Created by Andrew Zimmer on 2/7/23.
//

import Foundation
import Metal
import MetalKit
import ModelIO

public class MetalGeometryLibrary {
  // TODO: Limit the size of this fella.
  private var mdlModels: [String: MTKMesh] = [:]

  let device: MTLDevice
  lazy var allocator: MTKMeshBufferAllocator = {
    MTKMeshBufferAllocator(device: device)
  }()

  public init(device: MTLDevice) {
    self.device = device
  }

  func cachedMesh(_ geometry: MetalDrawable_Geometry) -> MTKMesh {
    if let asset = mdlModels[geometry.cacheKey] {
      return asset
    }

    do {
      let asset = try geometry.get(device: device, allocator: allocator)
      mdlModels[geometry.cacheKey] = asset
      return asset
    } catch {
      fatalError()
    }
  }
}
