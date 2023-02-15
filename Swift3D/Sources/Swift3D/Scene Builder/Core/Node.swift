//
//  Node.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

public protocol Node {
  associatedtype Body : Node
  @SceneBuilder @MainActor var body: Self.Body { get }

  var id: String { get }
  var printedTree: [String] { get }
  var drawCommands: [any MetalDrawable] { get }
}

extension Node {
  public var body: some Node {
    self
  }

  @MainActor public var drawCommands: [any MetalDrawable] {
    
    self.body.drawCommands
  }

  public var printedTree: [String] {
    ["\(id):\(String(describing:type(of: self)))"]
  }
}
