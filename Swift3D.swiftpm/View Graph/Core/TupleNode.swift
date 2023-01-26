//
//  TupleNode.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import Foundation

struct TupleNode<T>: Node {
  var id: String { "" }
  var value: T
  
  var body: some Node {
    self
  }
  
  func desc() -> [String] {
    if let val = value as? (any Node, any Node) {
      return val.0.desc() + val.1.desc()
    }
    else if let val = value as? (any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc()
    }
    else if let val = value as? (any Node, any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc() + val.3.desc()
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc() + val.3.desc() + val.4.desc()
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc() + val.3.desc() + val.4.desc() + val.5.desc()
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc() + val.3.desc() + val.4.desc() + val.5.desc() + val.6.desc()
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc() + val.3.desc() + val.4.desc() + val.5.desc() + val.6.desc() + val.7.desc()
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc() + val.3.desc() + val.4.desc() + val.5.desc() + val.6.desc() + val.7.desc() + val.8.desc()
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.desc() + val.1.desc() + val.2.desc() + val.3.desc() + val.4.desc() + val.5.desc() + val.6.desc() + val.7.desc() + val.8.desc() + val.9.desc()
    }
    
    fatalError()
  }
  
  var drawCommands: [any MetalDrawable] {
    if let val = value as? (any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands + val.3.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands + val.3.drawCommands + val.4.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands + val.3.drawCommands + val.4.drawCommands + val.5.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands + val.3.drawCommands + val.4.drawCommands + val.5.drawCommands + val.6.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands + val.3.drawCommands + val.4.drawCommands + val.5.drawCommands + val.6.drawCommands + val.7.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands + val.3.drawCommands + val.4.drawCommands + val.5.drawCommands + val.6.drawCommands + val.7.drawCommands + val.8.drawCommands
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.drawCommands + val.1.drawCommands + val.2.drawCommands + val.3.drawCommands + val.4.drawCommands + val.5.drawCommands + val.6.drawCommands + val.7.drawCommands + val.8.drawCommands + val.9.drawCommands
    }
    
    fatalError()
  }
}
