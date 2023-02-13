//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/27/23.
//

import Foundation
import simd

public struct CubeNode: Node, AcceptsShader {
  public let id: String
  public init(id: String) {
    self.id = id
  }
  
  public var drawCommands: [any MetalDrawable] {
    [RenderGeometry(id: id, 
                    transform: .identity, 
                    geometry: Cube(),
                    shaderPipeline: UnlitShader(.white),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: true)]
  }
}
