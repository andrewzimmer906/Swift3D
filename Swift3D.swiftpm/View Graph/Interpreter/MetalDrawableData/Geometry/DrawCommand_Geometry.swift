//
//  DrawCommand_Geometry.swift
//  
//
//  Created by Andrew Zimmer on 1/24/23.
//

import Foundation
import Metal


// MARK: - Geometry

protocol MetalDrawable_Geometry {
  func createBuffer(device: MTLDevice) -> MTLBuffer?
  func isEqualTo(_ other: MetalDrawable_Geometry) -> Bool
}

extension MetalDrawable_Geometry where Self: Equatable {
  func isEqualTo(_ other: MetalDrawable_Geometry) -> Bool {
      guard let geo = other as? Self else { return false }
      return self == geo
  }
}

// MARK: - Raw Floats

struct RawVertices: MetalDrawable_Geometry, Equatable {
  let vertices: [Float]
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    let dataSize = vertices.count * MemoryLayout<Float>.size
    return device.makeBuffer(bytes: vertices, length: dataSize)
  }
  
  static func == (lhs: Self, rhs: any MetalDrawable_Geometry) -> Bool {
    if let rhs = rhs as? RawVertices {
      return lhs.vertices.count == rhs.vertices.count 
    }
    
    return false
  }
}

