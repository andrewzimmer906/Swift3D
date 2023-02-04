//
//  AmbientLightNode.swift
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import simd

struct AmbientLightNode: Node, AcceptsColored {
  let id: String
  
  var drawCommands: [any MetalDrawable] {
    [
      PlaceLight(id: id, transform: .identity, type: .ambient, color: .one, animations: nil)
    ]
  }
}

struct DirectionalLightNode: Node, AcceptsColored {
  let id: String
  
  var drawCommands: [any MetalDrawable] {
    [
      PlaceLight(id: id, transform: .identity, type: .directional, color: .one, animations: nil)
    ]
  }
}
