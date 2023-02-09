//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/30/23.
//

import Foundation
import simd

public struct OctaNode: Node, AcceptsShader {
  public let id: String
  public let divisions: Int
  
  public init(id: String, divisions: Int = 1) {
    self.id = id
    self.divisions = divisions
  }
  
  public var drawCommands: [any MetalDrawable] {
    [RenderGeometry(id: id, 
                    transform: float4x4.identity, 
                    geometry: Octahedron(divisions: divisions),
                    shaderPipeline: UnlitShader(.red),
                    renderType: .triangles,
                    animations: nil,
                    storage: RenderGeometry.Storage(),
                    cullBackfaces: false)]
  }
}
