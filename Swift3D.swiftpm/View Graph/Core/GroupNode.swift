//
//  GroupNode.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

struct GroupNode<Content>: Node where Content: Node {
  let id: String
  let content: Content
  
  init(id: String, 
       @SceneBuilder _ content: @escaping () -> Content) {
    self.id = id
    self.content = content()
  }
  
  func desc() -> [String] {
    content.desc().map { "\(id).\($0)" }
  }
  
  var drawCommands: [any MetalDrawable] {
    content.drawCommands.map { 
      $0.withUpdated(id: "\(id).\($0.id)")       
    }
  }
}
