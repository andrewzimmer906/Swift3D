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
  let cameraController = TouchCameraController(minDistance: 2, maxDistance: 6)

  var body: some View {
    ZStack {
      Swift3DView(updateLoop: { delta in
        cameraController.update(delta: delta)
      }) {
        TouchCamera(controller: cameraController)

        lights

        /*ModelNode(id: "testModelStand", url: .model("MetalTiles.usdz"))
          .shaded(.standard)
          .overrideDefaultTextures()
          .translated(.up * 1.25)
         */
        OctaNode(id: "octa", divisions: 2)
          .shaded(.standard)
          .translated(.up * 1.25)

        ModelNode(id: "testModel", url: .model("MetalTiles.usdz"))
          .shaded(.pbr)

        ModelNode(id: "testModel2", url: .model("RedPlastic.usdz"))
          .shaded(.pbr)
          .translated(.down * 1.25)
      }
      .withCameraControls(controller: cameraController)
      .padding()
    }
  }

  private var lights: some Node {
    GroupNode(id: "Lights") {
      DirectionalLightNode(id: "Back")
        .colored(color: .blue.opacity(0.5))
        .transform(.lookAt(eye: .zero, look: .back, up: .up))


      DirectionalLightNode(id: "Forward")
        .colored(color: .yellow.opacity(0.5))
        .transform(.lookAt(eye: .zero, look: .forward, up: .up))
/*
      DirectionalLightNode(id: "Down")
        .colored(color: .mint.opacity(0.15))
        .transform(.lookAt(eye: .zero, look: .down, up: .up))

      DirectionalLightNode(id: "Up")
        .colored(color: .orange.opacity(0.15))
        .transform(.lookAt(eye: .zero, look: .up, up: .up))

      DirectionalLightNode(id: "Left")
        .colored(color: .yellow.opacity(0.15))
        .transform(.lookAt(eye: .zero, look: .left, up: .up))

      DirectionalLightNode(id: "Right")
        .colored(color: .blue.opacity(0.15))
        .transform(.lookAt(eye: .zero, look: .right, up: .up))
      */
    }
  }
}
