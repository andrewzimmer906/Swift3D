//
//  ConditionalNode.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

struct ConditionalNode<TrueContent, FalseContent>: Node where TrueContent: Node, FalseContent: Node {  
  enum Storage {
    case trueContent(TrueContent)
    case falseContent(FalseContent)
  }
  
  var id: String { fatalError() }
  var body: Never { fatalError() }
  
  private let storage: Storage
  init(storage: Storage) {
    self.storage = storage
  }
  
  func desc() -> [String] {
    switch storage {
    case .trueContent(let c):
      return c.desc()
    case .falseContent(let c):
      return c.desc()
    }
  }
  
  var drawCommands: [DrawCommand] {
    switch storage {
    case .trueContent(let c):
      return c.drawCommands
    case .falseContent(let c):
      return c.drawCommands
    }
  }
}
