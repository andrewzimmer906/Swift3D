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
  
  func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  func drawCommands(content: any Node) -> [any MetalDrawable] {
    return content.drawCommands.map { command in
      switch command.transform {
      case .model(let modelMat):
        return command.withUpdated(transform: .model(modelMat * transform))
      case .camera(let projMat, let viewMat): 
        return command.withUpdated(transform: .camera(projMat, viewMat * transform))
      }
    }
  }
}

// MARK: - Node Extension

extension Node {
  func transform(_ transform: float4x4) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: transform))
  }
}
