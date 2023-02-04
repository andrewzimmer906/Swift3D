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
  
  var printedTree: [String] {
    if let val = value as? (any Node, any Node) {
      return val.0.printedTree + val.1.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree + val.3.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree + val.3.printedTree + val.4.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree + val.3.printedTree + val.4.printedTree + val.5.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree + val.3.printedTree + val.4.printedTree + val.5.printedTree + val.6.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree + val.3.printedTree + val.4.printedTree + val.5.printedTree + val.6.printedTree + val.7.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree + val.3.printedTree + val.4.printedTree + val.5.printedTree + val.6.printedTree + val.7.printedTree + val.8.printedTree
    }
    else if let val = value as? (any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node, any Node) {
      return val.0.printedTree + val.1.printedTree + val.2.printedTree + val.3.printedTree + val.4.printedTree + val.5.printedTree + val.6.printedTree + val.7.printedTree + val.8.printedTree + val.9.printedTree
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
