//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import SwiftUI
import simd

struct CameraProjectionSettings {
  let fov: Float
  let zNear: Float
  let zFar: Float

  func matrix(aspect: Float) -> float4x4 {
    float4x4.makePerspective(fovyRadians: fov,
                             aspect,
                             zNear,
                             zFar)
  }
}

struct CameraNode: Node {
  let id: String
  
  var drawCommands: [any MetalDrawable] {
    [PlaceCamera(id: id, 
                 transform: float4x4.identity, 
                 cameraProjectionSettings: CameraProjectionSettings(fov:1.0472, zNear: 0.1, zFar: 100),
                 shaderPipeline: nil,
                 animations: nil,
                 storage: PlaceCamera.Storage())]
  }

  func skybox(_ shader: any MetalDrawable_Shader) -> ModifiedNodeContent<Self, ShaderModifier> {
    return self.modifier(ShaderModifier(shader: shader))
  }
}
