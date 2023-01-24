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
  
  func desc(content: any Node) -> [String] {
    content.desc()
  }
  
  func drawCommands(content: any Node) -> [DrawCommand] {
    return content.drawCommands.map { command in
      switch command.transform {
      case .model(let modelMat):
        return command.copy(transform: .model(modelMat * transform))
      case .camera(let projMat, let viewMat): 
        return command.copy(transform: .camera(projMat, viewMat * transform))
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
