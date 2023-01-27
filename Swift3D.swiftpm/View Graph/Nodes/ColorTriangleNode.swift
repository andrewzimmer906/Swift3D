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
  
  var drawCommands: [any MetalDrawable] { 
    [RenderGeometry(id: id, 
                    transform: float4x4.identity, 
                    geometry: Triangle.get() as ColoredVertices, 
                    shaderPipeline: .standard("basic_col_vertex", "basic_col_fragment"),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: false)]
  }
}
