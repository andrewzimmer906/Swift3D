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
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: .zero, normal: .down),
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: .zero, normal: .down),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), uv: .zero, normal: .down),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), uv: .zero, normal: .down),
      
      // Back
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: .zero, normal: .forward),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv: .zero, normal: .forward),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv: .zero, normal: .forward),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), uv: .zero, normal: .forward),
      
      // Front
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: .zero, normal: .back),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: .zero, normal: .back),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv: .zero, normal: .back),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), uv: .zero, normal: .back),
      
      // Left
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: .zero, normal: .left),
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: .zero, normal: .left),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv: .zero, normal: .left),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: .zero, normal: .left),
      
      // Right
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), uv: .zero, normal: .right),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), uv: .zero, normal: .right),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv: .zero, normal: .right),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv: .zero, normal: .right),
      
      // Top
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: .zero, normal: .up),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv: .zero, normal: .up),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv: .zero, normal: .up),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv: .zero, normal: .up),
    ], indices: [
      // Bottom      
      0, 2, 1,
      0, 3, 2,
      
      // Back
      4, 6, 5,
      4, 7, 6,
      
      // Front
      8, 9, 10,
      8, 10, 11,
      
      // Left
      12, 13, 14,
      12, 14, 15,
      
      // Right
      16, 18, 17,
      16, 19, 18,
      
      // Top
      20, 21, 22,
      20, 22, 23,
    ])
  }
}
