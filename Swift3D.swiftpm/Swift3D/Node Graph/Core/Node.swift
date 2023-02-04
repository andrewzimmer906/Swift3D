//
//  Node.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

protocol Node {
  associatedtype Body : Node
  @SceneBuilder @MainActor var body: Self.Body { get }

  var id: String { get }
  var printedTree: [String] { get }
  var drawCommands: [any MetalDrawable] { get }
}

extension Node {
  var body: some Node {
    self
  }

  @MainActor var drawCommands: [any MetalDrawable] {
    
    self.body.drawCommands
  }

  var printedTree: [String] {
    ["\(id):\(String(describing:type(of: self)))"]
  }
}
