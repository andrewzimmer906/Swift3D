//
//  ModelNode.swift
//  
//
//  Created by Andrew Zimmer on 2/7/23.
//

import Foundation
import simd

public struct ModelNode: Node, AcceptsShader {
  let url: URL
  public let id: String

  public init(id: String = "", url: URL?) {
    guard let url = url else {
      fatalError()
    }

    self.id = "\(id).\(url.absoluteString)"
    self.url = url
  }

  public var drawCommands: [any MetalDrawable] {
    [RenderGeometry(id: id,
                    transform: float4x4.identity,
                    geometry: Sphere(), //Octahedron.get(divisions: 1) as StandardGeometry,
                    shaderPipeline: UnlitShader(.red),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: false)]
  }
}
