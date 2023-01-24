import SwiftUI
import simd


struct ContentView: View {
  @State var tester: Bool = true
  @State var isRotated: Bool = true
  @State var rotation: Float = 0
  
  var body: some View {
    ZStack {
      Swift3DView(updateLoop: { delta in 
        rotation += 1.0 * Float(delta)
      }) {
        GroupNode(id: "camera_container") {
          CameraNode(id: "camera")
            .transform(float4x4.translated(simd_float3(x: 0, y: 0, z: -5)))
        }
        .transform(float4x4.rotated(angle: isRotated ? Float.pi : 0, axis: simd_float3.up))        
        .transition(.easeOut(1.5))
                
        TriangleNode(id: "sup")
          .transform(float4x4.rotated(angle: rotation, axis: simd_float3.up))
          .transform(.scaled(simd_float3.one * 0.5))
        
        TriangleNode(id: "sup2")
          .transform(.translated(simd_float3.down))
          .transform(float4x4.rotated(angle: rotation, axis: simd_float3.right))          
          .transform(.scaled(simd_float3.one * 0.5))
        
        TriangleNode(id: "sup4")
          .transform(.translated(simd_float3.up))
          .transform(float4x4.rotated(angle: rotation, axis: simd_float3.forward))          
          .transform(.scaled(simd_float3.one * 0.5))
      }
      
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text(tester ? "Hello, world!" : "Goodbye, world!")
      }
    }
    .onTapGesture {
      //rotation += Float.pi/2
      //tester.toggle()
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
}
