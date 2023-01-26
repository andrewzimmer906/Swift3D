//
//  DrawCommand_Transform.swift
//  
//
//  Created by Andrew Zimmer on 1/24/23.
//

import Foundation
import simd

extension DrawCommand {
  enum Transform {
    case model(float4x4)
    case camera(CameraProjectionSettings, float4x4) // projection, view
  }
}

extension DrawCommand.Transform: Equatable {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch(lhs, rhs) {
    case (.model(_), .model(_)):
      return true
    case (.camera(_,_), .camera(_,_)):
      return true  
    default:
      return false
    }
  }
}

// MARK: - Transitions
extension MetalDrawable {
  
  
  
  /// Gets visible transform accounting for transitions
  func presentedTransform(time: CFTimeInterval) -> float4x4? {    
    return self.transform
    //TODO: Fix
    /*
    guard let animation = animations?.first(where: { $0.attribute == .all }),
          let prevTransform = storage.previousDrawCommand?.transform else {
      return nil
    }
        
    let percent = animation.interpolate(time: time)
    
    switch (transform, prevTransform) {
      case (.model(let mat), .model(let matOld)):
      return .model(float4x4.lerp(matOld, mat, percent))
    case (.camera(let projSettings, let view), .camera(let projSettingsOld, let viewOld)):      
      let interpolatedSettings = CameraProjectionSettings(
        fov: Float.lerp(projSettingsOld.fov, projSettings.fov, percent),
        zNear: Float.lerp(projSettingsOld.zNear, projSettings.zNear, percent),
        zFar: Float.lerp(projSettingsOld.zFar, projSettings.zFar, percent))
      let interpolatedView = float4x4.lerp(viewOld, view, percent)      
      return .camera(interpolatedSettings, interpolatedView)      
    default:
      return nil
    }*/
  }
}
