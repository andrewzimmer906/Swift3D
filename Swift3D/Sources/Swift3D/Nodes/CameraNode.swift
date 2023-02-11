//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import SwiftUI
import simd

public struct CameraProjectionSettings {
  let isOrtho: Bool
  let fov: Float
  let zNear: Float
  let zFar: Float

  func matrix(aspect: Float) -> float4x4 {
    if isOrtho {
      return float4x4.makeOrthographic(left: -1, right: 1, bottom: -1, top: 1, nearZ: 0.1, farZ: 100)
    } else {
      return float4x4.makePerspective(fovyRadians: fov,
                               aspect,
                               zNear,
                               zFar)
    }
  }
}

public struct CameraNode: Node {
  public let id: String
  public init(id: String) {
    self.id = id
  }
  
  public var drawCommands: [any MetalDrawable] {
    [PlaceCamera(id: id, 
                 transform: float4x4.identity, 
                 cameraProjectionSettings: CameraProjectionSettings(isOrtho: false, fov:1.0472, zNear: 0.1, zFar: 100),
                 shaderPipeline: nil,
                 animations: nil,
                 storage: PlaceCamera.Storage())]
  }

  public func skybox(_ shader: any MetalDrawable_Shader) -> ModifiedNodeContent<Self, ShaderModifier> {
    return self.modifier(ShaderModifier(shader: shader))
  }
}

extension CameraProjectionSettings {
  static func projectionLerp(_ from: Self, _ to: Self, _ percent: Float, aspect: Float) -> float4x4 {
    let fromMat = from.matrix(aspect: aspect)
    let toMat = to.matrix(aspect: aspect)
    print("lerp perc: \(percent)")
    return float4x4.straightLerp(fromMat, toMat, percent)
  }
}
