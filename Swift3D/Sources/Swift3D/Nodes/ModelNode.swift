//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/9/23.
//

import Foundation
import SwiftUI
import simd

public struct ModelNode: Node, AcceptsShaderWithDefaultTextures {
  public let id: String
  public let url: URL
  public init(id: String, url: URL) {
    self.id = id
    self.url = url
  }

  public var drawCommands: [any MetalDrawable] {
    [RenderModel(id: id,
                 transform: .identity,
                 model: Model(url: url),
                 shaderPipeline: .standard(albedo: Color.white),
                 overrideTextures: false,
                 animations: nil,
                 storage: RenderModel.Storage())]
  }
}
