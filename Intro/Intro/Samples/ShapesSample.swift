//
//  ShapesSample.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/15/23.
//

import Foundation
import SwiftUI
import UIKit

import Swift3D
import simd

fileprivate class Data {
  var rotation: Float = 0
}

struct ShapesSample: View {
  private let data = Data()
  private let cameraController = TouchCameraController(
    minDistance: 8, maxDistance: 14)

  var body: some View {
    VStack {
      Text("🎁 Plenty of shapes to toy around with. ♦️")
      ZStack {
          Swift3DView(updateLoop: { delta in
            data.rotation += Float(delta)
            cameraController.update(delta: delta)
          }) {
            TouchCamera(controller: cameraController,
                        skybox: .skybox())
            funLights

            SphereNode(id: "sphere")
              .shaded(.uvColored())
              .rotated(angle: data.rotation, axis: normalize(.up + .right))
              .translated(3 * .up + 2 * .left)

            CylinderNode(id: "cylinder")
              .shaded(.uvColored())
              .rotated(angle: data.rotation, axis: normalize(.up + .right))
              .translated(2 * .left)

            ConeNode(id: "cone")
              .shaded(.uvColored())
              .rotated(angle: data.rotation, axis: normalize(.up + .right))
              .translated(3 * .down + 2 * .left)

            CapsuleNode(id: "capsule")
              .shaded(.uvColored())
              .rotated(angle: data.rotation, axis: normalize(.up + .right))
              .translated(3 * .up + 2 * .right)

            CubeNode(id: "cube")
              .shaded(.uvColored())
              .scaled(.one * 1.5)
              .rotated(angle: data.rotation, axis: normalize(.up + .right))
              .translated(2 * (.right))

            OctaNode(id: "octahed", divisions: 0)
              .shaded(.uvColored())
              .scaled(.one * 2.5)
              .rotated(angle: data.rotation, axis: normalize(.up + .right))
              .translated(3 * .down + 2 * .right)
          }
          .withCameraControls(controller: cameraController)
          .frame(maxHeight: .infinity)
      }
    }
  }

  private var funLights: some Node {
    GroupNode(id: "lights") {
      AmbientLightNode(id: "Ambient")
        .colored(color: .white.opacity(0.15))
      DirectionalLightNode(id: "Directional")
        .colored(color: .orange.opacity(0.4))
        .transform(.lookAt(eye: .zero, look: simd_float3(x: 0.5, y: 0.5, z: 0.5), up: .up))
      DirectionalLightNode(id: "Directional2")
        .colored(color: .blue.opacity(0.5))
        .transform(.lookAt(eye: .zero, look: simd_float3(x: -0.5, y: -0.5, z: 0.5), up: .up))
    }
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      ShapesSample()
    }
  }
}

