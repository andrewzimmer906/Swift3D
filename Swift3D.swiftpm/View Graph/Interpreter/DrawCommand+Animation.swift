//
//  DrawCommand+Animation.swift
//  
//
//  Created by Andrew Zimmer on 1/23/23.
//

import Foundation
import simd

extension DrawCommand {
  /// Gets most up to date transform based on animation state.
  func updatedTransform(time: CFTimeInterval) -> Transform? {
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
    }
  }
}
