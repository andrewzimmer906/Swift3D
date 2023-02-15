//
//  IdentityModifier.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

/// Useful primarily for testing!
public struct IdentityModifier: NodeModifier {
  let id: String
  
  public func printedTree(content: any Node) -> [String] {
    content.printedTree.map {
      "\(id).\($0)"
    }
  }
  
  public func drawCommands(content: any Node) -> [any MetalDrawable] {
    return content.drawCommands
  }
}

// MARK: - Node Extension

extension Node {
  func modified(id: String) -> ModifiedNodeContent<Self, IdentityModifier> {
    self.modifier(IdentityModifier(id: id))
  }
}
