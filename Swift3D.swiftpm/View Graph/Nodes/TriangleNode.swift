//
//  TriangleNode.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import simd

struct TriangleNode: Node {
  let id: String
  
  var drawCommands: [any MetalDrawable] { 
    [RenderGeometry(id: id, 
                    transform: float4x4.identity, 
                    geometry: Triangle.get() as StandardGeometry,
                    shaderPipeline: .standard("simple_lit_vertex", "simple_lit_fragment"),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: false)]
  }
}
