//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/30/23.
//

import Foundation
import simd

struct OctaNode: Node, AcceptsColored {
  let id: String
  let divisions: Int
  
  init(id: String, divisions: Int = 1) {
    self.id = id
    self.divisions = divisions
  }
  
  var drawCommands: [any MetalDrawable] {
    [RenderGeometry(id: id, 
                    transform: float4x4.identity, 
                    geometry: Octahedron.get(divisions: divisions) as StandardGeometry,
                    shaderPipeline: .custom("simple_lit_vertex", "simple_lit_fragment", ColorUniform(color: .one)),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: false)]
  }
}
