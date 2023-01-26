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
                renderType: nil, 
                animations: nil, 
                transform: float4x4.identity,
                cameraProjectionSettings: CameraProjectionSettings(fov:1.0472, zNear: 0.1, zFar: 100),
                storage: PlaceCamera.Storage())]
  }
}
