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


fileprivate class Data {
  var rotation: Float = 0
}

struct CowSample: View {
  private let data = Data()
  private let motion = Motion()
  
  var body: some View {
    ScrollView {
      preamble
      cowScene
      midAmble
      cubeScene
      exitAmble
    }
    .background(.white, ignoresSafeAreaEdges: .all)
    .onAppear {
      motion.start()
    }
    .onDisappear {
      motion.end()
    }
  }

  @ViewBuilder
  var preamble: some View {
    Spacer(minLength: 50)
    Text("Hey, I'm Cow 🐮..")
      .font(.title2)
    Text("Well yes, technically I'm **spot.obj** 🌍")
  }

  var cowScene: some View {
    Swift3DView {
      CameraNode(id: "mainCam")
        .perspective(fov: 1.5)
        .translated(.up * 0.5 + .back * 1)
      StandardLighting(id: "light")
      ModelNode(id: "cow", url: .model("spot_triangulated.obj"))
        .transform(motion.curAttitude)
    }
    .aspectRatio(1, contentMode: .fit)
  }

  var cubeScene: some View {
    Swift3DView(updateLoop: { delta in
      data.rotation += Float(delta) * .pi/4
    }) {
      CameraNode(id: "mainCam")
        .translated(.up * 0.5 + .back * 3)
      FunLights(id: "funLights")
      CubeNode(id: "cube")
        .shaded(.uvColored())
        .transform(.rotated(angle: data.rotation, axis: .up))
        .transform(.rotated(angle: data.rotation/2, axis: .right))
    }
    .frame(height: 150)
    .aspectRatio(1, contentMode: .fit)
  }

  @ViewBuilder
  var midAmble: some View {
    Text("What's cool is I'm rendered in **FULL 🔶 3D** using **Metal!** 🤘🔥🎸")
      .font(.title2).padding(4)
    Text("Right from SwiftUI like this:")
      .font(.title2)
      .frame(maxWidth:.infinity, alignment: .leading)
      .padding()


    Text("""
Swift3DView {
  ModelNode(id: "cow",
            url: .model("spot.obj"))
}
""")
    .asCode()

    Text("I mean it's a tiny bit more code, I have **dynamic lights 💡** and a **camera** too! 📹🐮")
      .font(.title2)
      .padding()

    Text("You need another example? Sure.")
    Text("Oh Hey, look down there it's a cube! 🎲 😮")
      .font(.title2)
      .padding()
    Text("Oh yeah, I meant to say ✨**dynamically generated mesh**✨")
      .multilineTextAlignment(.center)
  }

  @ViewBuilder
  var exitAmble: some View {
    Text("""
Swift3DView(updateLoop: { delta in
  data.rotation += Float(delta) * .pi/4
}) {
  // Lights!
  // FunLights is a ✨user defined Node✨
  // Just like you define Views in SwiftUI
  FunLights(id: "funLights")


  // Camera!
  CameraNode(id: "mainCam")
    .translated(.up * 0.5 + .back * 3)

  // Action!
  CubeNode(id: "cube")
   .shaded(.uvColored())
    .transform(.rotated(
                angle: data.rotation,
                axis: .up))
    .transform(.rotated(
                angle: data.rotation/2,
                axis: .right))
    }
""")
    .asCode()
    Text("Okay, I showed you all the code that time. 😊❤️")
      .multilineTextAlignment(.center)

    Text("🐮 I'm not sure why **I'm** the one doing so much exposition here..")
      .font(.title2)
      .padding()
    Text("No offense, I'd just rather be eating grass.")
    Text("🐮 But, scroll around a bit, there are some other demos too. Really cool stuff, I hear.")
      .font(.title2)
      .padding()
    Text("🐮 Also")
      .font(.title2)
    Text("🐮 **MOOOO!** ❤️")
      .font(.title)
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      CowSample()
    }
  }
}
