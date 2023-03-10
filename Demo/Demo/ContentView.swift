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
            if page == Content.allCases.last {
              Text("✨Done!✨").font(.callout).padding(.top)
            } else {
              Text("Swipe for more ➡️").font(.callout).padding(.top)
            }
          }
        }), currentPage: $curPage)
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
    case cow
    case pbr
    case seats

    @ViewBuilder
    var body: some View {
      switch(self) {
      case .cow:
        CowSample()
      case .introAnimation:
        IntroAnimationSample()
      case .seats:
        SeatsSample()
      case .pbr:
        PBRSample()
      }
    }
  }
}
