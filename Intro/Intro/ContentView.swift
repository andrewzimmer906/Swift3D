import SwiftUI
import Swift3D
import simd

class Swift3DData {
  var rotation: Float = 0
}

struct ContentView: View {
  @State var tester: Bool = true
  @State var is3D: Bool = false

  let data = Swift3DData()
  let cameraController = TouchCameraController()
  
  var body: some View {
    ZStack {
      if is3D {
        Swift3DView(updateLoop: { delta in
          data.rotation += .pi * Float(delta)
          cameraController.update(delta: delta)
        }) {
          TouchCamera(controller: cameraController, skybox: .skybox(low: .white, mid: .white, high: .white))
          lights
          ModelNode(id: "title", url: .model("title.obj"))
            .shaded(.standard(albedo: Color.blue))
            .translated(.down * 0.25)

          OctaNode(id: "gem", divisions: 0)
            .shaded(.standard(albedo: Color.red))
            .transform(.rotated(angle: data.rotation, axis: .up))
            .transform(.translated(.down * 3))
        }
        .frame(height: 500)
        .padding()
      } else {
        Text("SwiftUI")
          .font(Font.system(size: 60).weight(.black))
          .kerning(0)
          .foregroundColor(.blue)
      }

      VStack {
        Text("Growing tired of your everyday Swift UI? 🥱")
        Text("Let's go further. 🚀🚀🚀")
        Spacer()
        Button {
          is3D.toggle()
        } label: {
          if is3D {
            Text("Back to 2D").foregroundColor(.white)
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
              .background(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)).fill(Color.gray))
          }
          else {
            Text("Enter the 3rd Dimension!")
              .font(.title3.bold())
              .foregroundColor(.white)
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
              .background(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)).fill(Color.blue))
          }
        }
      }
      .padding()
    }
    .onTapGesture {
      if is3D {
        cameraController.touchTapped()
      }
    }
    .gesture(DragGesture(minimumDistance: 0)
      .onChanged { gesture in
        if is3D {
          cameraController.touchMoved(startLocation: gesture.startLocation,
                                      curLocation: gesture.location)
        }
      }
      .onEnded({ gesture in
        if is3D {
          cameraController.touchEnded(predictedEndLocation: gesture.predictedEndLocation)
        }
      })
    )
  }
  
  private var lights: some Node {
    GroupNode(id: "lights_container") {
      AmbientLightNode(id: "Ambient")
        .colored(color: .init(hue: 0, saturation: 0, brightness: 0.6))
      
      DirectionalLightNode(id: "Directional")
        .colored(color: .init(hue: 0, saturation: 0, brightness: 0.45))
        .transform(.lookAt(eye: .zero, look: simd_float3(x: 0, y: 0.5, z: -0.5), up: .up))
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
}

extension URL {
  static func model(_ path: String) -> URL {
    let components = path.components(separatedBy: ".")
    guard components.count == 2,
          let url = Bundle.main.url(forResource: components[0], withExtension: components[1]) else {
      fatalError()
    }
    return url
  }
}
