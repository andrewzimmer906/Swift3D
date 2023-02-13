//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import SwiftUI
import simd

struct OrthographicSettings {
  let left: Float
  let right: Float
  let top: Float
  let bottom: Float

  let nearZ: Float
  let farZ: Float
}

struct PerspectiveSettings {
  let fov: Float
  let zNear: Float
  let zFar: Float

  static var standard: Self {
    .init(fov: 1.0472, zNear: 0.1, zFar: 100)
  }
}

enum CameraProjection {
  case orthographic(OrthographicSettings)
  case perspective(PerspectiveSettings)

  func matrix(aspect: Float) -> float4x4 {
    switch self {
    case .orthographic(let settings):
      return float4x4.makeOrthographic(left: settings.left,
                                       right:settings.right,
                                       bottom: settings.bottom,
                                       top: settings.top,
                                       nearZ: settings.nearZ,
                                       farZ: settings.farZ)
    case .perspective(let settings):
      return float4x4.makePerspective(fovYRadians: settings.fov,
                                      aspect: aspect,
                                      nearZ: settings.zNear,
                                      farZ: settings.zFar)
    }
  }
}
/*
extension CameraProjectionSettings {
  static func projectionLerp(_ from: Self, _ to: Self, _ percent: Float, aspect: Float) -> float4x4 {
    let fromMat = from.matrix(aspect: aspect)
    let toMat = to.matrix(aspect: aspect)
    print("lerp perc: \(percent)")
    return float4x4.straightLerp(fromMat, toMat, percent)
  }
}
*/

public struct CameraNode: Node {
  public let id: String
  public init(id: String) {
    self.id = id
  }
  
  public var drawCommands: [any MetalDrawable] {
    [PlaceCamera(id: id, 
                 transform: .identity,
                 projection: .perspective(.standard),
                 shaderPipeline: nil,
                 animations: nil,
                 storage: PlaceCamera.Storage())]
  }

  public func skybox(_ shader: any MetalDrawable_Shader) -> ModifiedNodeContent<Self, ShaderModifier> {
    return self.modifier(ShaderModifier(shader: shader))
  }
}
