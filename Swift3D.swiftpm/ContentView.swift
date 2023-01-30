import SwiftUI
import simd


struct ContentView: View {
  enum CameraPos: Int {
    case normal
    case under
    case above
  }
  
  @State var camPos: CameraPos = .normal  
  @State var tester: Bool = true
  @State var isRotated: Bool = true
  @State var rotation: Float = 0
  
  var body: some View {
    ZStack {
      Swift3DView(updateLoop: { delta in 
        rotation += 1.0 * Float(delta)
      }) {
        camera
        
        //axis(id: "axis")
        //CubeNode(id: "hello")
        OctaNode(id: "hello", divisions: 2)
          .colored(color: .mint)
          .transform(.translated(.up * 0.5))
          .transform(.rotated(angle: rotation, axis: .up))
        
        CubeNode(id: "hello2")
          .colored(color: .mint)
          //.transform(.translated(.down))
          .transform(.rotated(angle: -rotation, axis: .up))
        
        TriangleNode(id: "hello3")
          .colored(color: .mint)
          .transform(.translated(.down * 0.5))
          .transform(.rotated(angle: rotation, axis: .up))
        
        //TriangleNode(id: "1")
//          .transform(.rotated(angle: (isRotated ? -1 : 1) * .pi/6, axis: .up))
        
        //ColorTriangleNode(id: "1")
          //.transform(.translated(.forward * 5))
        
        /*CubeNode(id: "cube")
          .transform(.translated(.up))
          .transform(.rotated(angle: rotation, axis: .up))
         */
        /*
        GroupNode(id: "xx") {
          cubeConglomerate(id: "1")
            .transform(.translated(.right))
          cubeConglomerate(id: "2")
            .transform(.translated(.left))
          cubeConglomerate(id: "3")
            .transform(.translated(.up))
          cubeConglomerate(id: "4")
            .transform(.translated(.down))
          cubeConglomerate(id: "5")
            .transform(.translated(.forward))
          cubeConglomerate(id: "6")
            .transform(.translated(.back))
        }                  
        cubeConglomerate(id: "10")*/
        
        /*ColorTriangleNode(id: "2")
          .transform(float4x4.rotated(angle: rotation, axis: simd_float3.up))
        */
        
        /*
        GroupNode(id: "tri_boss") {
          ColorTriangleNode(id: "L5")
            .transform(.translated(simd_float3.left * 0.5))            
            .transform(.rotated(angle: .pi/2, axis: .up))
          
          ColorTriangleNode(id: "base")
            .transform(.rotated(angle: .pi/2, axis: .up))

          ColorTriangleNode(id: "R5")
            .transform(.translated(simd_float3.right * 0.5))
            
            .transform(.rotated(angle: .pi/2, axis: .up))
        }
        .transform(float4x4.rotated(angle: rotation, axis: simd_float3.up))
         */
      }
       
      /*VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text(tester ? "Hello, world!" : "Goodbye, world!")
      }*/
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
      
      //print("bod: \(self.body)")
      // testTree()      
      // print(self.body)
    }  
  }
  
  private var camera: some Node {
    GroupNode(id: "camera_container") {
      switch camPos {
      case .normal:
        CameraNode(id: "camera")
          .transform(float4x4.translated(simd_float3(x: 0, y: 0, z: -10)))
          //.transform(.rotated(angle: -.pi, axis: .up))
      case .above:
        CameraNode(id: "camera")            
          .transform(.rotated(angle: -.pi/4, axis: .right))
          .transform(float4x4.translated(simd_float3(x: 0, y: 5, z: -5)))
      case .under:
        CameraNode(id: "camera")            
          .transform(.rotated(angle: .pi/4, axis: .right))
          .transform(float4x4.translated(simd_float3(x: 0, y: -5, z: -5)))
      }          
    } 
    .transition(.easeOut(1.5))
  }
  
  private func axis(id: String) -> some Node {
    GroupNode(id: id) {
      CubeNode(id: "X")
        .colored(color: .red)
        .transform(.translated(.right))
        .transform(.scaled(simd_float3(x: 2, y: 0.15, z: 0.15)))
      
      CubeNode(id: "Y")
        .colored(color: .green)
        .transform(.translated(.up))
        .transform(.scaled(simd_float3(x: 0.15, y: 2, z: 0.15)))
      
      CubeNode(id: "Z")
        .colored(color: .blue)
        .transform(.translated(.forward))
        .transform(.scaled(simd_float3(x: 0.15, y: 0.15, z: 2)))
    }
  }
  
  private func cubeConglomerate(id: String) -> some Node {
    GroupNode(id: id) { 
      CubeNode(id: "0")
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "1")
        .transform(.translated(.right))
        .transform(.translated(.back))
        .transform(.translated(.down))
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "2")
        .transform(.translated(.left))
        .transform(.translated(.back))
        .transform(.translated(.down))
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "3")
        .transform(.translated(.left))
        .transform(.translated(.back))
        .transform(.translated(.up))
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "4")
        .transform(.translated(.right))
        .transform(.translated(.back))
        .transform(.translated(.up))
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "5")
        .transform(.translated(.right))
        .transform(.translated(.forward))
        .transform(.translated(.down))
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "6")
        .transform(.translated(.left))
        .transform(.translated(.forward))
        .transform(.translated(.down))
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "7")
        .transform(.translated(.left))
        .transform(.translated(.forward))
        .transform(.translated(.up))
        .transform(.scaled(.one * 0.5))
      
      CubeNode(id: "8")
        .transform(.translated(.right))
        .transform(.translated(.forward))
        .transform(.translated(.up))
        .transform(.scaled(.one * 0.5))
    }.transform(.rotated(angle: -rotation, axis: .up))
  }
}
