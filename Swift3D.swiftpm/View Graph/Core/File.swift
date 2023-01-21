//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/20/23.
//

import Foundation

protocol Node {
  associatedtype Body: Node
  var id: String { get }
  var body: Self.Body { get }
  
  func desc() -> [String]
}

extension Array where Element == any Node {
  func desc() -> String {
    
    var output = ""
    self.enumerated().forEach() { idx, node in
      output.append("\(idx): \(node.desc())\n")
    }
    
    return output
  }
}

func makeCode(@TestBuilder _ content: () -> any Node) -> any Node {
  content()
}

@resultBuilder
struct TestBuilder {
  static func buildBlock() -> [any Node] { [] }
}


extension TestBuilder {
  static func buildBlock(_ node: any Node) -> any Node {
    node
  }
  
  /*static func buildBlock(_ nodes: any Node...) -> any Node {
    DrawnNode(id:"fake")
  }*/
  
  
  
  static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleNode<(C0, C1)> where C0: Node, C1: Node {
    return .init(value: (c0, c1))
  }
  
  static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleNode<(C0, C1, C2)> where C0: Node, C1: Node, C2: Node {
    return .init(value: (c0, c1, c2))
  }
  
  static func buildBlock(_ scenes: [any Node]) -> [any Node] {
    scenes
  }
}

func testTree() {
  let tree = makeCode { 
    //DrawnNode(id: "1")
    DrawnNode(id: "world").modifier(TransformingModifier(id: "hey"))
    DrawnNode(id: "fifty2").modified(id: "modification")
    //
    
    TransformNode(id: "2") {
      DrawnNode(id: "hello")
      DrawnNode(id: "world")
    }
    
    /*
    TransformNode(id: "1") {
      TransformNode(id: "2") {
        DrawnNode(id: "3")
        //DrawnNode(id: "4")
      }
    }*/
  }
  
  print("\n")
  print(tree)
  print("\n")
  print(tree.desc())
}

// MARK: - Test Node Types

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
    
    return ["TUPLE FAIL"]
  }
}

struct TransformNode<Content>: Node where Content: Node {
  let id: String
  let content: Content
  
  init(id: String, 
       @TestBuilder _ content: @escaping () -> Content) {
    self.id = id
    self.content = content()
  }
  
  var body: some Node {
    return content.body
  }
  
  func desc() -> [String] {
    body.desc().map { "\(id).\($0)" }
  }
}

//MARK: - Drawn Node

struct DrawnNode: Node {
  let id: String
  
  var body: some Node {
    self
  }
  
  func desc() -> [String] {
    ["\(String(describing:type(of: self))).\(id)"]    
  }
  
  func modified(id: String) -> ModifiedNodeContent<Self, TransformingModifier> {
    self.modifier(TransformingModifier(id: id))
  }
}

//MARK: - Modifiers

struct TransformingModifier: NodeModifier {
  let id: String
  
  func desc(content: any Node) -> [String] {
    content.desc().map {
      "\(id).\($0)"
    }
  }
}

struct ModifiedNodeContent<Content, Modifier> {
  var content: Content
  var modifier: Modifier
}

extension ModifiedNodeContent: Node where Content: Node, Modifier: NodeModifier {
  var id: String { "" }
  
  func desc() -> [String] {
    modifier.desc(content: content)
  }
  
  var body: some Node {
    self
  }
}

extension Node {
  func modifier<T>(_ modifier: T) -> ModifiedNodeContent<Self, T> {
    return .init(content: self, modifier: modifier)
  }
}

protocol NodeModifier {
  func desc(content: any Node) -> [String]
}

