//
//  NodeModifier.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

struct ModifiedNodeContent<Content, Modifier> {
  var content: Content
  var modifier: Modifier
}

extension ModifiedNodeContent: Node where Content: Node, Modifier: NodeModifier {
  var id: String { "" }
  
  func desc() -> [String] {
    modifier.desc(content: content)
  }
  
  var drawCommands: [DrawCommand] {
    modifier.drawCommands(content: content)
  }
}

protocol NodeModifier {
  func desc(content: any Node) -> [String]
  func drawCommands(content: any Node) -> [DrawCommand]
}

// MARK: - Node Extension

extension Node {
  func modifier<T>(_ modifier: T) -> ModifiedNodeContent<Self, T> {
    return .init(content: self, modifier: modifier)
  }
}
