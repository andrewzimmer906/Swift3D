//
//  ShaderPipelineModifier.swift
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import simd
import SwiftUI

public struct ShaderModifier: NodeModifier {
  let shader: any MetalDrawable_Shader
  
  public func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  public func drawCommands(content: any Node) -> [any MetalDrawable] {    
    return content.drawCommands.map {
      if let cmd = $0 as? any HasShaderPipeline {
        return cmd.withUpdated(shaderPipeline: shader)
      }
      return $0
    }
  }
}

// MARK: - Node Extension

public protocol AcceptsShader { }

extension Node where Self: AcceptsShader {
  public func shaded(_ shader: any MetalDrawable_Shader) -> ModifiedNodeContent<Self, ShaderModifier> {
    self.modifier(ShaderModifier(shader: shader))
  }
}
