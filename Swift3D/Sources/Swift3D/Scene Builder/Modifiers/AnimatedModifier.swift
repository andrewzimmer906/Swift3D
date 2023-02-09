//
//  AnimatedModifier.swift
//  
//
//  Created by Andrew Zimmer on 1/23/23.
//

import Foundation
import UIKit

// MARK: - Node Animation

public struct NodeTransition {
  let curve: Curve
  let attribute: Attribute
  let startTime: CFTimeInterval
}

public extension NodeTransition {
  enum Curve {
    case linear(Float)
    case easeIn(Float)
    case easeOut(Float)
    case easeInOut(Float)
  }
  
  enum Attribute {
    case all
  }
}

extension NodeTransition {
  public static func linear(_ duration: Float) -> NodeTransition {
    return .init(curve: .linear(duration), attribute: .all, startTime: CACurrentMediaTime())
  }
  
  public static func easeIn(_ duration: Float) -> NodeTransition {
    return .init(curve: .easeIn(duration), attribute: .all, startTime: CACurrentMediaTime())
  }
  public static func easeOut(_ duration: Float) -> NodeTransition {
    return .init(curve: .easeOut(duration), attribute: .all, startTime: CACurrentMediaTime())
  }
  public static func easeInOut(_ duration: Float) -> NodeTransition {
    return .init(curve: .easeInOut(duration), attribute: .all, startTime: CACurrentMediaTime())
  }
}

// MARK: - Animation Modifier

public struct TransitionModifier: NodeModifier {
  public let animation: NodeTransition
  
  public func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  public func drawCommands(content: any Node) -> [any MetalDrawable] {
    return content.drawCommands.map { command in
      var anims: [NodeTransition] = command.animations ?? []
      anims.append(animation)      
      return command.withUpdated(animations: anims)
    }
  }
}

// MARK: - Node Extension

extension Node {
  public func transition(_ animation: NodeTransition) -> ModifiedNodeContent<Self, TransitionModifier> {
    self.modifier(TransitionModifier(animation: animation))
  }
}
