//
//  Motion.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/24/23.
//

import Foundation
import simd
import CoreMotion

extension BinaryFloatingPoint {
  var radians : Self {
    return self * .pi / 180
  }
}

extension CMQuaternion {
  var quatd: simd_quatd {
    .init(ix: x, iy: y, iz: z, r: w)
  }

  var quatf: simd_quatf {
    .init(ix: Float(x), iy: Float(y), iz: Float(z), r: Float(w))
  }
}

class Motion {
  var XOffset: Double = 0.0
  var YOffset: Double = 0.0

  private let motionManager = CMMotionManager()
  private var initialPitch: Double?
  private var initialRoll: Double?

  private var startingAttitude: CMAttitude?

  var curAttitude: float4x4 {
    let curAttitude = motionManager.deviceMotion?.attitude
    if startingAttitude == nil {
      startingAttitude = curAttitude
    }

    guard let startingRot = startingAttitude?.quaternion.quatf,
          let curRot = curAttitude?.quaternion.quatf else {
      return .identity
    }

    return .init((curRot.inverse * startingRot).inverse)
  }

  /// Doesn't apply initial rot, instead uses set offset to make it feel like you
  /// are controlling the camera.
  var curCamAttidue: float4x4 {
    let curAttitude = motionManager.deviceMotion?.attitude
    guard let att = curAttitude else {
      return .identity
    }

    let a = att.quaternion.quatf
    let b = simd_quatf(ix: -a.vector.x, iy: a.vector.y, iz: a.vector.z, r: a.vector.w)
    let c = b * simd_quatf(angle: .pi/2, axis: .right)
    return .init(c)
  }

  // MARK: - Start / End

  func start() {
    motionManager.deviceMotionUpdateInterval = 0.033 // 30 fps.
    motionManager.startDeviceMotionUpdates()
    startingAttitude = nil
  }

  func end() {
    motionManager.stopDeviceMotionUpdates()
  }
}
