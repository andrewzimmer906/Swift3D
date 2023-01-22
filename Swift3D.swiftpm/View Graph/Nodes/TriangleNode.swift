//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

struct TriangleNode: Node {
  
  let id: String
  
  func desc() -> [String] {
    ["\(String(describing:type(of: self))).\(id)"]  
  }
  
  var drawCommands: [DrawCommand] {
    let dc = DrawCommand()
    dc.geometry = .vertices([0.0,  0.75, 0.0,
                             -0.75, -0.75, 0.0,
                             0.75, -0.75, 0.0])
    return [dc]
  }
}
