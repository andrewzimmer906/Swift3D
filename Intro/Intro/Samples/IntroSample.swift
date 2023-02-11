import SwiftUI
import Swift3D
import simd

class Intro3DData {
  var rotation: Float = 0
}

struct IntroSample: View {
  @State var is3D: Bool = true
  @State var cameraProj: Bool = true

  let data = Intro3DData()
  let cameraController = TouchCameraController(minDistance: 8, maxDistance: 16)

  var body: some View {
    VStack {
      Text("Growing tired of your everyday Swift UI? 🥱")
      Text("What if we went.. ✨**3D**✨ 🚀🚀🚀")

      ZStack {
        if is3D {
          VStack {
            Swift3DView(/*updateLoop: { delta in
              data.rotation += .pi * Float(delta)
              cameraController.update(delta: delta)
            }*/) {

              CameraNode(id: "cam")
                .testProjection(isOrtho: !cameraProj)
                .translated(.back * 10)
                .transition(.easeInOut(2))


              //TouchCamera(controller: cameraController,
//                          skybox: .skybox(low: .white, mid: .white, high: .white))
              StandardLighting(id: "lights")

//              TriangleNode(id: "tri")

              ModelNode(id: "title", url: .model("title.obj"))
                .shaded(.standard(albedo: Color.blue))
                .translated(.down * 0.25)

              CubeNode(id: "cube")
                .shaded(.uvColored())
                .transform(.rotated(angle: data.rotation, axis: .up))
                .transform(.rotated(angle: data.rotation/2, axis: .right))
                .transform(.translated(.down * 3))
            }
            .withCameraControls(controller: cameraController)
            .padding()
            Text("👉 Drag to Pan")
            Text("👆 Tap to Zoom")
          }
        } else {
          VStack {
            Text("SwiftUI")
              .font(Font.system(size: 60).weight(.black))
              .kerning(0)
              .foregroundColor(.blue)
            Rectangle().fill(.red).frame(width: 30, height: 30)
          }
        }
      }.frame(maxHeight: .infinity)

      Button {
        is3D.toggle()
      } label: {
        if is3D {
          Text("Back to 2D").foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)).fill(Color.gray))
        }
        else {
          Text("Enter the 3rd Dimension!")
            .font(.title3.bold())
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)).fill(Color.blue))
        }
      }

      Button {
        cameraProj.toggle()
      } label: {
        Text("Test").foregroundColor(.blue)
      }
      Text("Swipe for more ➡️").font(.callout).padding(.top)
    }
    .padding()
  }
}

private func axis(id: String) -> some Node {
  GroupNode(id: id) {
    CubeNode(id: "X")

      .transform(.translated(.right))
      .transform(.scaled(simd_float3(x: 2, y: 0.15, z: 0.15)))

    CubeNode(id: "Y")

      .transform(.translated(.up))
      .transform(.scaled(simd_float3(x: 0.15, y: 2, z: 0.15)))

    CubeNode(id: "Z")
      .transform(.translated(.forward))
      .transform(.scaled(simd_float3(x: 0.15, y: 0.15, z: 2)))
  }
}

struct preview: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
