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
            .transform(float4x4.translated(simd_float3(x: 0, y: 0, z: -7)))
        }
        .transform(float4x4.rotated(angle: isRotated ? Float.pi : 0, axis: simd_float3.up))        
        .transition(.easeOut(1.5))
        
        GroupNode(id: "tri_boss") {
          TriangleNode(id: "L1")
            .transform(.translated(simd_float3.left * 1))
          TriangleNode(id: "L75")
            .transform(.translated(simd_float3.left * 0.75))
          TriangleNode(id: "L5")
            .transform(.translated(simd_float3.left * 0.5))
          TriangleNode(id: "L25")
            .transform(.translated(simd_float3.left * 0.25))
          
          TriangleNode(id: "base")

          TriangleNode(id: "R25")
            .transform(.translated(simd_float3.right * 0.25))
          TriangleNode(id: "R5")
            .transform(.translated(simd_float3.right * 0.5))
          TriangleNode(id: "R75")
            .transform(.translated(simd_float3.right * 0.75))
          TriangleNode(id: "R1")
            .transform(.translated(simd_float3.right * 1))          
        }
        .transform(.translated(simd_float3.right * sin(rotation)))
        .transform(float4x4.rotated(angle: rotation, axis: simd_float3.up))
        
        /*TriangleNode(id: "tri")
          .transform(.translated(simd_float3.up))
          .transform(float4x4.rotated(angle: rotation, axis: simd_float3.forward))          
          .transform(.scaled(simd_float3.one * 0.5))
         */
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
