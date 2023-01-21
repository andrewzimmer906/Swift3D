import SwiftUI

struct ContentView: View {
  @State var tester: Bool = false
  
  var body: some View {
    ZStack {
      /*
      Swift3DView {
        if tester {
          Triangle(id: "sup")
        }
        
        EmptyDrawable(id: tester ? "one" : "two")
        Transform3DGroup(id: "hello") {
          EmptyDrawable2(id: "world")
          EmptyDrawable(id: "world2")
        }
        
        if tester {
          EmptyDrawable(id: "tester_is_true")
          EmptyDrawable(id: "tester_is_true")
        }
        else {
          EmptyDrawable(id: "tester_is_false")
        }
      }
      .frame(width: 400, height: 800)
      .background(.red)
      */
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
      testTree()
      // print(self.body)
    }
  }
}
