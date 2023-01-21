//
//  IdentityModifier.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

/// Useful primarily for testing!
struct IdentityModifier: NodeModifier {
  let id: String
  
  func desc(content: any Node) -> [String] {
    content.desc().map {
      "\(id).\($0)"
    }
  }
  
  func drawCommands(content: any Node) -> [DrawCommand] {
    return content.drawCommands
  }
}

extension Node {
  func modified(id: String) -> ModifiedNodeContent<Self, IdentityModifier> {
    self.modifier(IdentityModifier(id: id))
  }
}
