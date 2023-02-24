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

struct CowSample: View {
  let motion = Motion()
  let cameraController = TouchCameraController(minDistance: 2, maxDistance: 5)
  
  var body: some View {
    VStack {
      ZStack {
          Swift3DView(updateLoop: { delta in
            cameraController.update(delta: delta)
          }) {
            TouchCamera(controller: cameraController)
            StandardLighting(id: "light")
            ModelNode(id: "title",
                      url: .model("spot_triangulated.obj"))
              .transform(motion.curAttitude)
          }
          .withCameraControls(controller: cameraController)
        }
      }
    .ignoresSafeArea()
    .frame(maxHeight: .infinity)
    .padding()
    .onTapGesture {
      withAnimation {
      }
    }
    .onAppear {
      motion.start()
    }
    .onDisappear {
      motion.end()
    }
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      CowSample()
    }
  }
}
