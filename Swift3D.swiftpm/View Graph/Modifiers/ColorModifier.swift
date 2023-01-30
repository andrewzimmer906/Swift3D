//
//  Color.swift
//  
//
//  Created by Andrew Zimmer on 1/30/23.
//

import Foundation
import simd
import SwiftUI

struct ColorModifier: NodeModifier {
  let color: Color
  
  func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  func drawCommands(content: any Node) -> [any MetalDrawable] {
    let data = data    
    return content.drawCommands.map {
      if let cmd = $0 as? WithPipeline {
        return cmd.withUpdated(pipelineData: data) as! any MetalDrawable
      }
      return $0
    }
  }
  
  private var data: ColorUniform {
    let converted = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    converted.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let col = simd_float4(x: Float(red), y: Float(green), z: Float(blue), w: Float(alpha))
    return ColorUniform(color: col)
  }
}

// MARK: - Node Extension

protocol AcceptsColored { }

extension Node where Self: AcceptsColored {
  func colored(color: Color) -> ModifiedNodeContent<Self, ColorModifier> {
    self.modifier(ColorModifier(color: color))
  }
  
  func modified(id: String) -> ModifiedNodeContent<Self, IdentityModifier> {
    self.modifier(IdentityModifier(id: id))
  }
}
