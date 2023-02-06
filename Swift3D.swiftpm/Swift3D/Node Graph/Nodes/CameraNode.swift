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

  func skybox(_ texture: any MetalDrawable_Texture, scaledBy: simd_float2 = .one) -> ModifiedNodeContent<Self, ShaderModifier> {
    if let cube = texture as? CubeMap {
      return self.modifier(ShaderModifier(shader: .skybox(cube, scaledBy: scaledBy)))
    } else if let color = texture as? Color {
      return self.modifier(ShaderModifier(shader: .unlit(color)))
    } else {
      fatalError("Please use a CubeMap for your camera skybox.")
    }
  }
}
