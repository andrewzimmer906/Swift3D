import SwiftUI
import Swift3D

struct ContentView: View {
  let pages = Content.allCases
  @State var curPage: Int = 0

  var body: some View {
    VStack {
      PageView(
        pages: pages.map({ page in
          VStack {
            page
            Text("Swipe for more ➡️").font(.callout).padding(.top)
          }
        }), currentPage: $curPage)
    }
    .onAppear {
      // SceneBuilderTest.testBuilder()
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
    case introAnimation
    case lighting
    case intro
    case isometric

    @ViewBuilder
    var body: some View {
      switch(self) {
      case .introAnimation:
        IntroAnimationSample()
      case .lighting:
        ShapesSample()
      case .intro:
        IntroSample()
      case .isometric:
        IsometricSample()
      }
    }
  }
}
