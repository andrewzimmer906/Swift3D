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

/*
protocol MetalDrawable_Geometry {
  var numPoints: Int { get }
  
  func createBuffer(device: MTLDevice) -> MTLBuffer?
  func createIndexBuffer(device: MTLDevice) -> MTLBuffer?
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
  var numPoints: Int {
    vertices.count / 3
  }
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    let dataSize = vertices.count * MemoryLayout<Float>.size
    return device.makeBuffer(bytes: vertices, length: dataSize)
  }
  
  func createIndexBuffer(device: MTLDevice) -> MTLBuffer? {
    nil
  }
}

// MARK: - Float and Color

struct ColoredVertices: MetalDrawable_Geometry {
  struct Vertex {
    let pos: simd_float3
    let col: simd_float4
  }
  
  var numPoints: Int {
    vertices.count
  }
  
  let vertices: [Vertex]
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    let dataSize = vertices.count * MemoryLayout<Vertex>.size
    return device.makeBuffer(bytes: vertices, length: dataSize)
  }
  
  func createIndexBuffer(device: MTLDevice) -> MTLBuffer? {
    nil
  }
  
  func isEqualTo(_ other: MetalDrawable_Geometry) -> Bool {
    if let cast = other as? ColoredVertices {
      return vertices.count == cast.vertices.count
    }
    return false
  }
}

// MARK: - Float and Normal (probably standard)

struct StandardGeometry: MetalDrawable_Geometry {
  struct Vertex {
    let position: simd_float3
    let uv: simd_float2
    let normal: simd_float3
  }
  
  let vertices: [Vertex]
  let indices: [Int16]?
  
  var numPoints: Int {
    if let indices = indices,
       indices.count > 0 {
      return indices.count
    }
    
    return vertices.count
  }
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    let dataSize = vertices.count * MemoryLayout<Vertex>.size
    return device.makeBuffer(bytes: vertices, length: dataSize)
  }
  
  func createIndexBuffer(device: MTLDevice) -> MTLBuffer? {
    if let indices = indices, indices.count > 0 {
      return device.makeBuffer(bytes: indices, length: MemoryLayout<Int16>.size * indices.count)
    }
    
    return nil
  }
  
  func isEqualTo(_ other: MetalDrawable_Geometry) -> Bool {
    if let cast = other as? Self {
      return vertices.count == cast.vertices.count && 
        (indices?.count ?? 0) == (cast.indices?.count ?? 0)
    }
    return false
  }
}
*/
