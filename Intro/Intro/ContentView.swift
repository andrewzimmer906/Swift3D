import SwiftUI
import Swift3D

struct ContentView: View {
  let pages = Content.allCases
  @State var curPage: Int = 0

  var body: some View {
    VStack {
      PageView(
        pages: pages.map({ page in
          page
        }), currentPage: $curPage)
      Text("Swipe for more ➡️").font(.callout).padding(.top)
    }
    .onAppear {
      SceneBuilderTest.testBuilder()
    }
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
  }
}

extension ContentView {
  enum Content: View, CaseIterable {
    case intro
    case isometric

    @ViewBuilder
    var body: some View {
      switch(self) {
      case .intro:
        IntroSample()
      case .isometric:
        IsometricSample()
      }
    }
  }
}
