//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/27/23.
//

import Foundation
import simd

struct CubeNode: Node {
  let id: String
  
  var drawCommands: [any MetalDrawable] { 
    [RenderGeometry(id: id, 
                    transform: float4x4.identity, 
                    geometry: Cube.get() as StandardGeometry, 
                    shaderPipeline: .standard("simple_lit_vertex", "simple_lit_fragment"),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: true)]
  }
}
