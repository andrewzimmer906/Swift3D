//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import simd

struct ColorTriangleNode: Node {
  let id: String
  // let color: Color
  
  private var vertices: [ColoredVertices.Vertex] {
    [.init(pos: simd_float3(x: 0, y: 1, z: 0), col: simd_float4(1,0,0,1)),
     .init(pos: simd_float3(x: -1, y: -1, z: 0), col: simd_float4(0,1,0,1)),
     .init(pos: simd_float3(x: 1, y: -1, z: 0), col: simd_float4(0,0,1,1))]
  }
  
  var drawCommands: [any MetalDrawable] { 
    [RenderGeometry(id: id, 
                    transform: float4x4.identity, 
                    geometry: ColoredVertices(vertices: vertices), 
                    renderType: .triangles(1),
                    animations: nil,
                    storage: RenderGeometry.Storage())]
  }
}
