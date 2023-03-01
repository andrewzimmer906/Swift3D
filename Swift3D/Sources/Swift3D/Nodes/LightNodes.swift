//
//  AmbientLightNode.swift
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import simd

public struct AmbientLightNode: Node, AcceptsColored {
  public let id: String
  public init(id: String) {
    self.id = id
  }
  
  public var drawCommands: [any MetalDrawable] {
    [
      PlaceLight(id: id,
                 transform: .identity,
                 type: .ambient,
                 color: .one,
                 animations: nil,
                 storage: .init())
    ]
  }
}

public struct DirectionalLightNode: Node, AcceptsColored {
  public let id: String
  public init(id: String) {
    self.id = id
  }
  
  public var drawCommands: [any MetalDrawable] {
    [
      PlaceLight(id: id,
                 transform: .identity,
                 type: .directional,
                 color: .one,
                 animations: nil,
                 storage: .init())
    ]
  }
}

public struct PointLightNode: Node, AcceptsColored {
  public let id: String
  public init(id: String) {
    self.id = id
  }

  public var drawCommands: [any MetalDrawable] {
    [
      PlaceLight(id: id,
                 transform: .identity,
                 type: .point,
                 color: simd_float4(1,1,1,10),
                 animations: nil,
                 storage: .init())
    ]
  }
}
