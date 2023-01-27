//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/22/23.
//

import Foundation
import simd

struct TransformModifier: NodeModifier {
  let transform: float4x4
  let reverseApplication: Bool
  
  func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  func drawCommands(content: any Node) -> [any MetalDrawable] {    
    return content.drawCommands.map { command in
      let updatedTransform = reverseApplication ? transform * command.transform : command.transform * transform
      return command.withUpdated(transform: updatedTransform)
    }
  }
}

// MARK: - Node Extension

extension Node {
  func transform(_ transform: float4x4) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: transform, reverseApplication: false))      
  }
}

extension GroupNode {
  func transform(_ transform: float4x4) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: transform, reverseApplication: true))      
  }
}
