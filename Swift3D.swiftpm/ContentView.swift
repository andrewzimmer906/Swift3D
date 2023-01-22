import SwiftUI
import simd


struct ContentView: View {
  @State var tester: Bool = true
  @State var isRotated: Bool = true
  @State var rotation: Float = 0
  
  var body: some View {
    ZStack {
      Swift3DView {
        CameraNode(id: "camera").transform(float4x4.makeTranslation(x: 0, 0, -10))        
        TriangleNode(id: "sup")
           .transform(float4x4.makeTranslation(x: 1, 0, 0))
          .transform(float4x4.makeRotate(radians: rotation, 0, 1, 0))        
      }
      
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text(tester ? "Hello, world!" : "Goodbye, world!")
      }
      
    }
    .onTapGesture {
      rotation += 0.1
      //tester.toggle()
    }
    .onAppear {
      withAnimation(.default.repeatForever(autoreverses: true)) {
        isRotated.toggle()
      }
      // testTree()      
      // print(self.body)
    }
  }
}
