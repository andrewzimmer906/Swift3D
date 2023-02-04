import SwiftUI
import simd


var rotation: Float = 0

struct ContentView: View {
  enum CameraPos: Int {
    case normal
    case under
    case above
  }
  
  @State var camPos: CameraPos = .normal  
  @State var tester: Bool = true
  @State var isRotated: Bool = true

  let cameraController = TouchCameraController()
  
  var body: some View {
    ZStack {
      Swift3DView(updateLoop: { delta in
        rotation += 1.0 * Float(delta)
        cameraController.update(delta: delta)
      }) {
        TouchCamera(controller: cameraController,
                    skybox: UIImage(named: "greyChecker"),
                    scaledBy: .one * 2)
        lights

        OctaNode(id: "newid", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "greyChecker"), specPow: 6))
          .transform(.translated(.right * 0.5))

        CubeNode(id: "cube1")
          .shaded(.standard(albedo: UIImage(named: "orangeChecker")))
          .transform(.translated(.left * 0.5))

/*
        CubeNode(id: "hello")
          .shaded(.standard(albedo: UIImage(named: "orangeChecker"),
                            albedoScaling: .one * 4,
                            rimPow: 1))
          .transform(.translated(.up))
          .transform(.rotated(angle: -rotation, axis: .up))
        
        OctaNode(id: "hello2", divisions: 0)
          .shaded(.standard(albedo: UIImage(named: "orangeChecker"), rimPow: 1))
          .transform(.translated(.down * 0.5))
          .transform(.rotated(angle: rotation, axis: .up))
          .transform(.scaled(.one * 2))*/
      }
    }

    .onTapGesture {
      cameraController.touchTapped()
      isRotated.toggle()
    }
    .gesture(DragGesture(minimumDistance: 0)
      .onChanged { gesture in
        cameraController.touchMoved(startLocation: gesture.startLocation,
                                    curLocation: gesture.location)
      }
      .onEnded({ gesture in
        cameraController.touchEnded(predictedEndLocation: gesture.predictedEndLocation)
      })
    )
  }
  
  private var lights: some Node {
    GroupNode(id: "lights_container") {
      AmbientLightNode(id: "Ambient")
        .colored(color: .init(hue: 0, saturation: 0, brightness: 0.45))
      
      DirectionalLightNode(id: "Directional")
        .colored(color: .init(hue: 0, saturation: 0, brightness: 0.55))
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
}
