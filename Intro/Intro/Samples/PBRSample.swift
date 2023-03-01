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
  private let motion = Motion()

  var body: some View {
    ScrollView {
      Spacer(minLength: 50)
      Text("⚡ PBR Materials! ⚡")
        .font(.title2)
        pbrModel(modelPath: "MetalTiles.usdz", secondModel: "BlueTile.usdz")
        pbrModel(modelPath: "RedPlastic.usdz", secondModel: "RoughMetal.usdz")
    }
    .background(.white, ignoresSafeAreaEdges: .all)
    .onAppear {
      motion.start()
    }
    .onDisappear {
      motion.end()
    }
  }

  private func pbrModel(modelPath: String, secondModel: String) -> some View {
    Swift3DView {
      CameraNode(id: "mainCam")
        .translated(.back * 1.7)
      lights

      ModelNode(id: "\(modelPath)", url: .model(modelPath))
        .shaded(.pbr)
        .transform(motion.curAttitude)
        .translated(.left * 0.75)

      ModelNode(id: "\(secondModel)", url: .model(secondModel))
        .shaded(.pbr)
        .transform(motion.curAttitude)
        .translated(.right * 0.75)
    }
    .frame(height: 150)
    //.padding()
  }

  private var test: some View {
    ZStack {
      Swift3DView(updateLoop: { delta in
        cameraController.update(delta: delta)
      }) {
        TouchCamera(controller: cameraController)
        lights
        ModelNode(id: "testModel", url: .model("MetalTiles.usdz"))
          .shaded(.pbr)
      }
      .withCameraControls(controller: cameraController)
      .padding()
    }
  }

  private let power: Float = 600
  private var lights: some Node {
    GroupNode(id: "Lights") {
      AmbientLightNode(id: "ambient")
        .colored(color: .white, intensity: 0.1)

      PointLightNode(id: "Back")
        .colored(color: .white, intensity: 4)
        .translated(.back * 1.5)
    }
  }
}
