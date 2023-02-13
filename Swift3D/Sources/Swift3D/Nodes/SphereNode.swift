//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/9/23.
//

import Foundation
import simd

public struct SphereNode: Node, AcceptsShader {
  public let id: String

  public init(id: String) {
    self.id = id
  }

  public var drawCommands: [any MetalDrawable] {
    [RenderGeometry(id: id,
                    transform: .identity,
                    geometry: Sphere(),
                    shaderPipeline: UnlitShader(.red),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: false)]
  }
}
