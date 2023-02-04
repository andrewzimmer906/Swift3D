//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

struct EmptyNode: Node {
  var id: String { "" }
  
  var body: some Node {
    self
  }
  
  var printedTree: [String] {
    []  
  }
  
  var drawCommands: [any MetalDrawable] {
    []
  }
}
