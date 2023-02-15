//
//  SceneBuilder3D.swift
//  
//
//  Created by Andrew Zimmer on 1/17/23.
//

import Foundation

@resultBuilder
public struct SceneBuilder {
  public static func buildBlock() -> EmptyNode {
    return EmptyNode()
  }
}

extension SceneBuilder {
  public static func buildBlock<Content>(_ content: Content) -> Content where Content: Node {
    content
  }
}

// MARK: - Control Flow Builder

extension SceneBuilder {
  public static func buildOptional<Content>(_ content: Content?) -> ConditionalNode<Content, EmptyNode> where Content: Node {
    if let c = content {
      return .init(storage: .trueContent(c))
    }
    else {
      return .init(storage: .falseContent(EmptyNode()))
    }
  }
  
  public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> ConditionalNode<TrueContent, FalseContent> where TrueContent: Node, FalseContent: Node {
      return .init(storage: .trueContent(first))
  }
  
  public static func buildEither<TrueContent, FalseContent>(second: FalseContent) ->
    ConditionalNode<TrueContent, FalseContent> where TrueContent: Node, FalseContent: Node {
      return .init(storage: .falseContent(second))
  }
}

// MARK: - Tuple Builder
extension SceneBuilder {
  public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleNode<(C0, C1)> where C0: Node, C1: Node {
    return .init(value: (c0, c1))
  }
  
  public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleNode<(C0, C1, C2)> where C0: Node, C1: Node, C2: Node {
    return .init(value: (c0, c1, c2))
  }
  
  public static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleNode<(C0, C1, C2, C3)> where C0: Node, C1: Node, C2: Node, C3: Node {
    return .init(value: (c0, c1, c2, c3))
  }
  
  public static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleNode<(C0, C1, C2, C3, C4)> where C0: Node, C1: Node, C2: Node, C3: Node, C4: Node {
    return .init(value: (c0, c1, c2, c3, c4))
  }
  
  public static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleNode<(C0, C1, C2, C3, C4, C5)> where C0: Node, C1: Node, C2: Node, C3: Node, C4: Node, C5: Node {
    return .init(value: (c0, c1, c2, c3, c4, c5))
  }
  
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleNode<(C0, C1, C2, C3, C4, C5, C6)> where C0: Node, C1: Node, C2: Node, C3: Node, C4: Node, C5: Node, C6: Node {
    return .init(value: (c0, c1, c2, c3, c4, c5, c6))
  }
  
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleNode<(C0, C1, C2, C3, C4, C5, C6, C7)> where C0: Node, C1: Node, C2: Node, C3: Node, C4: Node, C5: Node, C6: Node, C7: Node {
    return .init(value: (c0, c1, c2, c3, c4, c5, c6, c7))
  }
  
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleNode<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> where C0: Node, C1: Node, C2: Node, C3: Node, C4: Node, C5: Node, C6: Node, C7: Node, C8: Node {
    return .init(value: (c0, c1, c2, c3, c4, c5, c6, c7, c8))
  }
  
  public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleNode<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> where C0: Node, C1: Node, C2: Node, C3: Node, C4: Node, C5: Node, C6: Node, C7: Node, C8: Node, C9: Node {
    return .init(value: (c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
  }
}
