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

// UV Wrap Data -> https://www.kodeco.com/719-metal-tutorial-with-swift-3-part-3-adding-texture#toc-anchor-009
extension Cube where Geometry == StandardGeometry {
  static func get() -> Geometry {
    StandardGeometry(vertices: [
      // Bottom
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5),  uv: simd_float2(x: 0.25, y: 0.5), normal: .down),
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: simd_float2(x: 0.25, y: 0.75), normal: .down),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5),  uv: simd_float2(x: 0.5, y: 0.75), normal: .down),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5),   uv: simd_float2(x: 0.5, y: 0.5), normal: .down),

      // Back
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: simd_float2(x: 1, y: 0.25), normal: .forward),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5),  uv: simd_float2(x: 1, y: 0.5), normal: .forward),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5),   uv: simd_float2(x: 0.75, y: 0.5), normal: .forward),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5),  uv: simd_float2(x: 0.75, y: 0.25), normal: .forward),
      
      // Front
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: simd_float2(x: 0.25, y: 0.25), normal: .back),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5),  uv: simd_float2(x: 0.25, y: 0.5), normal: .back),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5),   uv: simd_float2(x: 0.5, y: 0.5), normal: .back),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5),  uv: simd_float2(x: 0.5, y: 0.25), normal: .back),
      
      // Left
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0.5), uv: simd_float2(x: 0.25, y: 0.25), normal: .left),
      .init(position: simd_float3(x: -0.5, y: -0.5, z: -0.5), uv: simd_float2(x: 0, y: 0.25), normal: .left),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv: simd_float2(x: 0, y: 0.5), normal: .left),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: simd_float2(x: 0.25, y: 0.5), normal: .left),
      
      // Right
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0.5), uv: simd_float2(x: 0.5, y: 0.25), normal: .right),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: -0.5), uv: simd_float2(x: 0.75, y: 0.25), normal: .right),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv: simd_float2(x: 0.75, y: 0.5), normal: .right),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv: simd_float2(x: 0.5, y: 0.5), normal: .right),
      
      // Top
      .init(position: simd_float3(x: -0.5, y: 0.5, z: 0.5), uv: simd_float2(x: 0.25, y: 0), normal: .up),
      .init(position: simd_float3(x: -0.5, y: 0.5, z: -0.5), uv:  simd_float2(x: 0.25, y: 0.25), normal: .up),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: -0.5), uv:  simd_float2(x: 0.5, y: 0.25), normal: .up),
      .init(position: simd_float3(x: 0.5, y: 0.5, z: 0.5), uv:  simd_float2(x: 0.5, y: 0), normal: .up),
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
