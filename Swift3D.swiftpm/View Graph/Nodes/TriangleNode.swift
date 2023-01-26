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
  
  private var vertices: [Float] {
    [ 0.0,  1.0, 0.0,
     -1.0, -1.0, 0.0,
      1.0, -1.0, 0.0]
  }
  
  var drawCommands: [any MetalDrawable] { 
    [RenderGeometry(id: id, 
                    transform: float4x4.identity, 
                    geometry: RawVertices(vertices: vertices), 
                    renderType: .triangles(1),
                    animations: nil,
                    storage: RenderGeometry.Storage())]
  }
}
