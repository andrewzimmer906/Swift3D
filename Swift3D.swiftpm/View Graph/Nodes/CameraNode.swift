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
  
  func desc() -> [String] {
    ["\(String(describing:type(of: self))).\(id)"]  
  }
  
  var drawCommands: [DrawCommand] {
    [DrawCommand(command: .placeCamera(id), 
                 geometry: .none, 
                 transform: .camera(CameraProjectionSettings(fov:1.0472, zNear: 0.1, zFar: 100),
                                    float4x4.identity),
                 renderType: .none,
                 animations: nil,
                 storage: DrawCommand.Storage())]
  }
}
