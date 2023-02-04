//
//  Triangle.swift
//  
//
//  Created by Andrew Zimmer on 1/27/23.
//

import Foundation
import simd

struct Triangle<Geometry: MetalDrawable_Geometry> {
  static func get() -> Geometry {
    fatalError()
  }
}

extension Triangle where Geometry == RawVertices {
  static func get() -> Geometry {
    return RawVertices(vertices: [ 0.0,  1.0, 0.0,
                                   -1.0, -1.0, 0.0,
                                   1.0, -1.0, 0.0])
  }
}

extension Triangle where Geometry == ColoredVertices {
  static func get() -> Geometry {
    ColoredVertices(vertices:
                      [.init(pos: simd_float3(x: 0, y: 1, z: 0), col: simd_float4(1,0,0,1)),
                       .init(pos: simd_float3(x: -1, y: -1, z: 0), col: simd_float4(0,1,0,1)),
                       .init(pos: simd_float3(x: 1, y: -1, z: 0), col: simd_float4(0,0,1,1))]) 
  }
}

extension Triangle where Geometry == StandardGeometry {
  static func get() -> Geometry {
    StandardGeometry(vertices: [
      .init(position: simd_float3(x: 0, y: 0.5, z: 0), uv: simd_float2(x: 0.5, y: 1), normal: .back),
      .init(position: simd_float3(x: -0.5, y: -0.5, z: 0), uv: simd_float2(x: 0, y: 0), normal: .back),
      .init(position: simd_float3(x: 0.5, y: -0.5, z: 0), uv: simd_float2(x: 1, y: 0),  normal: .back)    
    ], indices: [0,1,2])
  }
}
