import SwiftUI
import Swift3D
import simd

struct ContentView: View {
  @State var tester: Bool = true
  @State var isRotated: Bool = true

  let cameraController = TouchCameraController()
  
  var body: some View {
    ZStack {
      Swift3DView(updateLoop: { delta in
        cameraController.update(delta: delta)
      }) {
        TouchCamera(controller: cameraController, skybox: .skybox(.cube("environment")))
        lights

        OctaNode(id: "1", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "orangeChecker"), specPow: 2))
          .transform(.translated(.right * 1))
        OctaNode(id: "2", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "orangeChecker"), specPow: 2))
          .transform(.translated(.left * 1))
        OctaNode(id: "3", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "redChecker"), specPow: 2))
          .transform(.translated(.forward * 1))
        OctaNode(id: "4", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "redChecker"), specPow: 2))
          .transform(.translated(.back * 1))
        OctaNode(id: "5", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "purpleChecker"), specPow: 2))
          .transform(.translated(.down * 1))
        OctaNode(id: "6", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "purpleChecker"), specPow: 2))
          .transform(.translated(.up * 1))
        OctaNode(id: "newid", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "purpleChecker"), specPow: 2))
          .transform(.translated(.right * 2))

         TriangleNode(id: "tri")
          //.shaded(.standard(albedo: Color.yellow))
          //.transform(.translated(.left * 2))


        /*CubeNode(id: "cube1")
          .shaded(.standard(albedo: UIImage(named: "orangeChecker")))
          .transform(.translated(.left * 0.5))*/
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
    .onAppear {
      let url = Bundle.main.url(forResource: "castle", withExtension: "obj")
      print("url: \(url)")
    }
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
