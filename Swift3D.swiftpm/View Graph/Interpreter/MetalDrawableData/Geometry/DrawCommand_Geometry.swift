//
//  DrawCommand_Geometry.swift
//  
//
//  Created by Andrew Zimmer on 1/24/23.
//

import Foundation
import Metal
import simd


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
}

// MARK: - Float and Color

struct ColoredVertices: MetalDrawable_Geometry {
  struct Vertex {
    let pos: simd_float3
    let col: simd_float4
  }
  
  let vertices: [Vertex]
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    let dataSize = vertices.count * MemoryLayout<Vertex>.size
    return device.makeBuffer(bytes: vertices, length: dataSize)
  }
  
  func isEqualTo(_ other: MetalDrawable_Geometry) -> Bool {
    if let cast = other as? ColoredVertices {
      return vertices.count == cast.vertices.count
    }
    return false
  }
}

