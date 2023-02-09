//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/22/23.
//

import Foundation
import simd

public struct TransformModifier: NodeModifier {
  let transform: float4x4
  // let reverseApplication: Bool
  
  public func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  public func drawCommands(content: any Node) -> [any MetalDrawable] {    
    return content.drawCommands.map { command in
      //let updatedTransform = reverseApplication ? transform * command.transform : command.transform * transform
      let updatedTransform = transform * command.transform
      return command.withUpdated(transform: updatedTransform)
    }
  }
}

// MARK: - Node Extension

extension Node {
 public func transform(_ transform: float4x4) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: transform))
  }

  public func translated(_ translation: simd_float3) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: .translated(translation)))
  }

  public func rotated(angle: Float, axis: simd_float3) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: .rotated(angle: angle, axis: axis)))
  }

  public func scaled(_ scale: simd_float3) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: .scaled(scale)))
  }
}

/*
extension GroupNode {
  public func transform(_ transform: float4x4) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: transform, reverseApplication: true))      
  }

  public func translated(_ translation: simd_float3) -> ModifiedNodeContent<Self, TransformModifier> {
    self.modifier(TransformModifier(transform: .translated(translation), reverseApplication: true))
  }
}
*/
