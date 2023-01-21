import SwiftUI

struct ContentView: View {
  @State var tester: Bool = false
  
  var body: some View {
    ZStack {
      Swift3DView {
        if tester {
          TriangleNode(id: "sup")
        }
      }
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text(tester ? "Hello, world!" : "Goodbye, world!")
      }
    }
    .onTapGesture {
      tester.toggle()
    }
    .onAppear {
      // testTree()
      // print(self.body)
    }
  }
}
