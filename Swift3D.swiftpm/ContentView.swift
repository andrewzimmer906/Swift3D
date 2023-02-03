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
  
  var body: some View {
    ZStack {
      Swift3DView(updateLoop: { delta in
        rotation += 1.0 * Float(delta)

      }) {
        CameraController()
        
        camera
        lights

        OctaNode(id: "newid", divisions: 2)
          .shaded(.standard(albedo: UIImage(named: "purpleChecker")))
          .transform(.translated(.up * sin(rotation) * 3))
          .transform(.rotated(angle: rotation, axis: .up))


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
          .transform(.scaled(.one * 2))
      }
    }
    .onTapGesture {
      //rotation += Float.pi/2
      //tester.toggle()
      if let updatedPos = CameraPos(rawValue: camPos.rawValue + 1) {
       camPos = updatedPos 
      }
      else {
        camPos = .normal
      }
      isRotated.toggle()
    }
    .onAppear {
      withAnimation(.default.repeatForever(autoreverses: true)) {
        isRotated.toggle()
      }
    }
  }
  
  private var camera: some Node {
    GroupNode(id: "camera_container") {
      switch camPos {
      case .normal:
        CameraNode(id: "camera")
          .skybox(UIImage(named: "darkDiamond"), scaledBy: .one * 8)
          .transform(float4x4.translated(simd_float3(x: 0, y: 0, z: -10)))
      case .above:
        CameraNode(id: "camera")
          .skybox(UIImage(named: "darkDiamond"), scaledBy: .one * 8)
          .transform(.rotated(angle: -.pi/4, axis: .right))
          .transform(float4x4.translated(simd_float3(x: 0, y: 5, z: -5)))
      case .under:
        CameraNode(id: "camera")
          .skybox(UIImage(named: "darkDiamond"), scaledBy: .one * 8)
          .transform(.rotated(angle: .pi/4, axis: .right))
          .transform(float4x4.translated(simd_float3(x: 0, y: -5, z: -5)))
      }
    }
    .transition(.easeOut(1.5))
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
