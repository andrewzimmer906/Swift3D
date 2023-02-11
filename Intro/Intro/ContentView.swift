import SwiftUI

struct ContentView: View {
  let pages = [IntroSample()]
  @State var curPage: Int = 0

  var body: some View {
    PageView(
      pages: pages.map({ page in
        page
      }), currentPage: $curPage)
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
  }
}
