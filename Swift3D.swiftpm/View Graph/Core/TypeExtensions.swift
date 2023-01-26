//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/17/23.
//

import Foundation

// MARK: - Never

extension Never: Node {
  var id: String {
    fatalError()
  }
  
  func desc() -> [String] {
    fatalError()
  }
  
  var drawCommands: [any MetalDrawable] {
    fatalError()
  }  
}

// MARK: - Array Print Description

extension Array where Element == any Node {
  var description: String {
    
    var output = ""
    self.enumerated().forEach() { idx, node in
      output.append("\(idx): \(node.desc())\n")
    }
    
    return output
  }
}

