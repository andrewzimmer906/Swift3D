//
//  NodeModifier.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

public struct ModifiedNodeContent<Content, Modifier> {
  var content: Content
  var modifier: Modifier
}

extension ModifiedNodeContent: Node where Content: Node, Modifier: NodeModifier {
  public var id: String { "" }
  
  public var printedTree: [String] {
    modifier.printedTree(content: content)
  }
  
  public var drawCommands: [any MetalDrawable] {
    modifier.drawCommands(content: content)
  }
}

public protocol NodeModifier {
  func printedTree(content: any Node) -> [String]
  func drawCommands(content: any Node) -> [any MetalDrawable]
}

// MARK: - Node Extension

extension Node {
  public func modifier<T>(_ modifier: T) -> ModifiedNodeContent<Self, T> {
    return .init(content: self, modifier: modifier)
  }
}
