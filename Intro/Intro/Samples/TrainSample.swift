//
//  TrainSample.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/20/23.
//

import Foundation
import SwiftUI
import Swift3D
import simd

struct CarSample: View {
  let cameraController = TouchCameraController(minDistance: 3, maxDistance: 8)
  
  var body: some View {
    VStack {
      ZStack {
          Swift3DView(updateLoop: { delta in
            cameraController.update(delta: delta)
          }) {
            TouchCamera(controller: cameraController)

            StandardLighting(id: "light")
            
            //ModelNode(id: "title", url: .model("hatchbackSports.obj"))
            ModelNode(id: "title", url: .model("spot_triangulated.obj"))

              //.shaded(.standard(albedo: Color.blue))
              //.scaled(.one * 0.1)
              //.rotated(angle: .pi / 4, axis: .right)
              //.rotated(angle: slowSpring.value.x, axis: .up)
              //.translated(.up * fastSpring.value.y)
          }.withCameraControls(controller: cameraController)
        }
      }
    .ignoresSafeArea()
    .frame(maxHeight: .infinity)
    .padding()
    .onTapGesture {
      withAnimation {
      }
    }
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      CarSample()
    }
  }
}
