//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import simd

struct CameraProjectionSettings {
  let fov: Float
  let zNear: Float
  let zFar: Float
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

  func skybox(_ texture: some MetalDrawable_Texture, scaledBy: simd_float2 = .one) -> ModifiedNodeContent<Self, ShaderModifier> {
    self.modifier(ShaderModifier(shader: .skybox(texture, scaledBy: scaledBy)))
  }
}
