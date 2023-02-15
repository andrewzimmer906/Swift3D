//
//  GroupNode.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

public struct GroupNode<Content>: Node where Content: Node {
  public let id: String
  public let content: Content
  
  public init(id: String,
       @SceneBuilder _ content: @escaping () -> Content) {
    self.id = id
    self.content = content()
  }

  public var body: some Node {
    self.content
  }
  
  public var printedTree: [String] {
    content.printedTree.map { "\(id).\($0)" }
  }
  
  public var drawCommands: [any MetalDrawable] {
    content.drawCommands.map { 
      $0.withUpdated(id: "\(id).\($0.id)")       
    }
  }
}
