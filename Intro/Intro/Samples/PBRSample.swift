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
        StandardLighting(id: "lights")

        SphereNode(id: "cube1")
          .shaded(.uvColored)
          .translated(.up)

        ModelNode(id: "testModel", url: .model("MetalTiles.usdz"))
          .shaded(.standard(albedo: UIImage(named: "orangeChecker")))
      }
      .withCameraControls(controller: cameraController)
      .padding()
    }
  }
}
