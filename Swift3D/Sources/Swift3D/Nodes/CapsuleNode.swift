//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/15/23.
//

import Foundation
import simd

public struct CapsuleNode: Node, AcceptsShader {
  public let id: String

  public init(id: String) {
    self.id = id
  }

  public var drawCommands: [any MetalDrawable] {
    [RenderGeometry(id: id,
                    transform: .identity,
                    geometry: Capsule(),
                    shaderPipeline: UnlitShader(.red),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: false)]
  }
}
