//
//  Cube.swift
//  
//
//  Created by Andrew Zimmer on 0.5/27/23.
//

import Foundation
import simd

struct Cube<Geometry: MetalDrawable_Geometry> {
  static func get() -> Geometry {
    fatalError()
  }
}

extension Cube where Geometry == StandardGeometry {
  static func get() -> Geometry {
    StandardGeometry(vertices: [
      // Bottom
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: .zero, normal: .down),
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: .zero, normal: .down),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), uv: .zero, normal: .down),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), uv: .zero, normal: .down),
      
      // Back
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: .zero, normal: .forward),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: .zero, normal: .forward),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv: .zero, normal: .forward),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), uv: .zero, normal: .forward),
      
      // Front
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: .zero, normal: .back),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv: .zero, normal: .back),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv: .zero, normal: .back),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), uv: .zero, normal: .back),
      
      // Left
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: .zero, normal: .left),
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: .zero, normal: .left),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: .zero, normal: .left),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv: .zero, normal: .left),
      
      // Right
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), uv: .zero, normal: .right),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), uv: .zero, normal: .right),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv: .zero, normal: .right),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv: .zero, normal: .right),
      
      // Top
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv: .zero, normal: .up),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: .zero, normal: .up),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv: .zero, normal: .up),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv: .zero, normal: .up),
    ], indices: [
      // Bottom      
      0, 1, 2,
      0, 2, 3,
      
      // Back
      4, 5, 6,
      4, 6, 7,
      
      // Front
      8, 10, 9,
      8, 11, 10,
      
      // Left
      12, 14, 13,
      12, 15, 14,
      
      // Right
      16, 17, 18,
      16, 18, 19,
      
      // Top
      20, 22, 21,
      20, 23, 22,
    ])
  }
}
