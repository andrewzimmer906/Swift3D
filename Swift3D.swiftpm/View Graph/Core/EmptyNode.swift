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
  
  func desc() -> [String] {
    []  
  }
  
  var drawCommands: [DrawCommand] {
    []
  }
}
