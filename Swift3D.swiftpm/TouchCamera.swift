//
//  CameraControlelr.swift
//  Swift3D
//
//  Created by Andrew Zimmer on 2/2/23.
//

import Foundation
import SwiftUI
import simd

class TouchCameraController {
  enum Zoom: Int {
    case max
    case mid
    case min
  }

  var transform: float4x4 {
    .TRS(trans: .forward * curZoom, rot: .identity, scale: .one) *
    .rotated(angle: xAngle, axis: .right) *
    .TRS(trans: .zero, rot: yQuat, scale: .one)
    // .rotated(angle: curEuler.y, axis: .up)
    // .TRS(trans: .zero, rot: rotation , scale: .one)
  }

  private var curZoom: Float {
    switch zoom {
    case .max:
      return maxDistance
    case .mid:
      return minDistance + (maxDistance - minDistance) / 2
    case .min:
      return minDistance
    }
  }

  private var angularVelocity = simd_float3.zero
  private var yQuat = simd_quatf.identity
  private var xAngle: Float = 0
  // private var curEuler = simd_float3.zero

  private var zoom: Zoom = .max

  private let minDistance: Float
  private let maxDistance: Float

  private let maxTilt = Float.pi / 4

  init(minDistance: Float = 5, maxDistance: Float = 15) {
    self.minDistance = minDistance
    self.maxDistance = maxDistance
  }

  private var lastDragLocation: CGPoint?

  func update(delta: CFTimeInterval) {
    let deltaF = Float(delta)
    if angularVelocity != .zero {
      let xAxisRot = simd_quatf(angle: min(angularVelocity.x * deltaF, .pi - 0.01), axis: .up)
      yQuat *= xAxisRot

      xAngle += angularVelocity.y * deltaF
      xAngle = min(max(xAngle, -maxTilt), maxTilt);

      let friction: Float = 5
      let frameFriction = 1 / (1 + deltaF * friction)

      angularVelocity *= frameFriction
      if length(angularVelocity) < 0.1 {
        angularVelocity = .zero
      }
    }
  }

  func touchMoved(startLocation: CGPoint, curLocation: CGPoint) {
    if lastDragLocation == nil {
      lastDragLocation = startLocation
    }

    guard let lastDragLocation = lastDragLocation else {
      return
    }
    angularVelocity = .zero

    let dragSpeed: Float = 0.5
    let offset = curLocation - lastDragLocation
    let xDrag = Float(offset.x / UIScreen.main.bounds.width) * dragSpeed
    let yDrag = Float(offset.y / UIScreen.main.bounds.height) * dragSpeed

    yQuat *= simd_quatf(angle: xDrag * .pi, axis: .up)
    xAngle += yDrag * .pi
    xAngle = min(max(xAngle, -maxTilt), maxTilt);

    self.lastDragLocation = curLocation
  }

  func touchEnded(predictedEndLocation: CGPoint) {
    guard let lastDragLocation = lastDragLocation else {
      return
    }

    self.lastDragLocation = nil
    let throwSpeed: Float = 1
    let offset = predictedEndLocation - lastDragLocation
    let xDrag = Float(offset.x / UIScreen.main.bounds.width) * throwSpeed
    let yDrag = Float(offset.y / UIScreen.main.bounds.height) * throwSpeed

    angularVelocity = simd_float3(.pi * xDrag, .pi * yDrag, 0)
  }

  func touchTapped() {
    if let updatedPos = Zoom(rawValue: zoom.rawValue + 1) {
      zoom = updatedPos
    }
    else {
      zoom = .max
    }
  }
}

// MARK: - Node

struct TouchCamera<Skybox: MetalDrawable_Texture>: Node {
  var id: String { "Camera Controller" }

  let controller: TouchCameraController
  let skybox: Skybox
  let scaledBy: simd_float2

  init(controller: TouchCameraController,
       skybox: Skybox = Color(hex: 0xefefef),
       scaledBy: simd_float2 = .one) {
    self.controller = controller
    self.skybox = skybox
    self.scaledBy = scaledBy
  }



  var body: some Node {
    CameraNode(id: "Main Camera")
      .skybox(skybox, scaledBy: scaledBy)
      .transform(controller.transform)
      .transition(.easeInOut(0.3))
  }
}
