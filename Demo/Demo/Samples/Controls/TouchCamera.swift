//
//  CameraControlelr.swift
//  Swift3D
//
//  Created by Andrew Zimmer on 2/2/23.
//

import Foundation
import SwiftUI
import Swift3D
import simd

class TouchCameraController {
  enum Zoom: Int {
    case max
    case mid
    case min
  }

  var transform: float4x4 {
    .TRS(trans: .zero, rot: yQuat, scale: .one) *
    .rotated(angle: xAngle, axis: .right) *
    .TRS(trans: .back * curZoom, rot: .identity, scale: .one)
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

    let dragSpeed: Float = 1
    let offset = curLocation - lastDragLocation
    let xDrag = Float(offset.x / UIScreen.main.bounds.width) * dragSpeed
    let yDrag = Float(offset.y / UIScreen.main.bounds.height) * dragSpeed

    yQuat *= simd_quatf(angle: -xDrag * .pi, axis: .up)
    xAngle += -yDrag * .pi
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

    angularVelocity = simd_float3(-.pi * xDrag, -.pi * yDrag, 0)
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

struct TouchCamera<Skybox: MetalDrawable_Shader>: Node {
  var id: String { "Camera Controller" }

  let controller: TouchCameraController
  let skybox: Skybox

  init(controller: TouchCameraController,
       skybox: Skybox = .skybox()) {
    self.controller = controller
    self.skybox = skybox
  }

  var body: some Node {
    CameraNode(id: "Main Camera")
      .skybox(skybox)
      .transform(controller.transform)
      .transition(.easeInOut(0.3))
  }
}

// MARK: View Extensions for touch controls

extension View {
  func withCameraControls(controller: TouchCameraController) -> some View {
    return self.modifier(TouchCameraGestureModifier(controller: controller))
  }
}

struct TouchCameraGestureModifier: ViewModifier {
  let controller: TouchCameraController
  func body(content: Content) -> some View {
    content
    .highPriorityGesture(DragGesture(minimumDistance: 0)
      .onChanged { gesture in
        controller.touchMoved(startLocation: gesture.startLocation,
                                    curLocation: gesture.location)

      }
      .onEnded({ gesture in
        if (abs(gesture.predictedEndTranslation.width) + abs(gesture.predictedEndTranslation.height)) < 0.25 {
          controller.touchTapped()
        }

        controller.touchEnded(predictedEndLocation: gesture.predictedEndLocation)
      })
    )
  }
}
