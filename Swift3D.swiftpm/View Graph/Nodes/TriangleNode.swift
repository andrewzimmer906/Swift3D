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
  
  var drawCommands: [DrawCommand] {
    [DrawCommand(command: .draw(id), 
                 geometry: .vertices(vertices), 
                 transform: .model(float4x4.identity), 
                 renderType: .triangles(1),
                 animations: nil,
                 storage: DrawCommand.Storage())]
  }
  
  func desc() -> [String] {
    ["\(String(describing:type(of: self))).\(id)"]  
  }  
}
