//
//  PBRSample.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/27/23.
//

import Foundation
import SwiftUI
import Swift3D
import simd

struct PBRSample: View {
  let state = SceneState()
  let cameraController = TouchCameraController(minDistance: 2, maxDistance: 5)
  private let motion = Motion()

  var body: some View {
    ZStack {
      Swift3DView(updateLoop: { deltaTime in
        cameraController.update(delta: deltaTime)
        state.rotation += Float(deltaTime) * .pi / 5
      }) {
        TouchCamera(controller: cameraController)
        lights

        ModelNode(id: "BlueTile", url: .model("BlueTile.usdz"))
          .shaded(.pbr)
      }
      .withCameraControls(controller: cameraController)

      VStack {
        Text("⚡️ Dynamic Lighting + Physically Based Materials ⚡️")
          .font(.title2)
        Spacer()
        Text("This sample was a lot of fun to make! 💜")
          .font(.caption)
        Text("🔢 Check out _Shaders/Lighting.metal_ for maths!")
          .font(.caption)
      }.multilineTextAlignment(.center)
       .padding()
    }
  }

  private var lights: some Node {
    GroupNode(id: "Lights") {
      AmbientLightNode(id: "ambient")
        .colored(color: .white, intensity: 0.1)

      GroupNode(id: "White Light") {
        PointLightNode(id: "light")
          .colored(color: .white, intensity: 8)

        SphereNode(id: "sphere")
          .shaded(.unlit(.white))
          .scaled(.one * 0.1)
      }
      .translated(.up * 1.5)
      .rotated(angle: state.rotation, axis: .right)

      GroupNode(id: "Green Light") {
        PointLightNode(id: "light")
          .colored(color: .green, intensity: 8)

        SphereNode(id: "sphere")
          .shaded(.unlit(.green))
          .scaled(.one * 0.1)
      }
      .translated(.back * 1.5)
      .rotated(angle: state.rotation, axis: .up + .left)

      GroupNode(id: "Red Light") {
        PointLightNode(id: "light")
          .colored(color: .purple, intensity: 8)

        SphereNode(id: "sphere")
          .shaded(.unlit(.purple))
          .scaled(.one * 0.1)
      }
      .translated(.forward * 1.5)
      .rotated(angle: -state.rotation, axis: .up + .right)
    }
  }
}

extension PBRSample {
  class SceneState {
    var rotation: Float = 0
  }
}
