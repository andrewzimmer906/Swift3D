import SwiftUI
import simd


struct ContentView: View {
  @State var tester: Bool = true
  @State var isRotated: Bool = true
  @State var rotation: Float = 0
  
  var body: some View {
    ZStack {
      Swift3DView {
        CameraNode(id: "camera")
          .transform(float4x4.translated(simd_float3(x: 0, y: 0, z: isRotated ? -10 : -20)))
          .transition(.easeOut(2))
        
        TriangleNode(id: "sup")
          .transform(float4x4.rotated(angle: isRotated ? Float.pi : 0, axis: simd_float3.forward))
          .transform(float4x4.translated(simd_float3.left * (isRotated ? 2 : 0)))
          .transition(.easeInOut(1))
      }
      
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text(tester ? "Hello, world!" : "Goodbye, world!")
      }
    }
    .onTapGesture {
      rotation += Float.pi/2
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
