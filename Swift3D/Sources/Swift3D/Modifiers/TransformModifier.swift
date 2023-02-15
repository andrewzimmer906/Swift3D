//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/22/23.
//

import Foundation
import simd

public struct TransformModifier: NodeModifier {
  let transform: MetalDrawableData.Transform
  
  public func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  public func drawCommands(content: any Node) -> [any MetalDrawable] {    
    return content.drawCommands.map { command in
      let updatedTransform: MetalDrawableData.Transform = .transform(transform.value * command.transform.value)
      return command.withUpdated(transform: updatedTransform)
    }
  }
}

// MARK: - Node Extension

extension Node {
 public func transform(_ transform: float4x4) -> ModifiedNodeContent<Self, TransformModifier> {
   self.modifier(TransformModifier(transform: .transform(transform)))
  }

  public func translated(_ translation: simd_float3) -> ModifiedNodeContent<Self, TransformModifier> {
    self.transform(.translated(translation))
  }

  public func rotated(angle: Float, axis: simd_float3) -> ModifiedNodeContent<Self, TransformModifier> {
    self.transform(.rotated(angle: angle, axis: axis))
  }

  public func scaled(_ scale: simd_float3) -> ModifiedNodeContent<Self, TransformModifier> {
    self.transform(.scaled(scale))
  }
}
