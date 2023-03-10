import SwiftUI
import UIKit

// Pulled from Apple's Interfacing with UIKit example : https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit
struct PageView<Page: View>: UIViewControllerRepresentable {
  var pages: [Page]
  @Binding var currentPage: Int

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIViewController(context: Context) -> UIPageViewController {
    let pageViewController = UIPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal)
    pageViewController.dataSource = context.coordinator
    pageViewController.delegate = context.coordinator
    pageViewController.view.backgroundColor = UIColor.clear

    return pageViewController
  }

  func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
    pageViewController.setViewControllers(
      [context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
  }

  class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var parent: PageView
    var controllers = [UIViewController]()

    init(_ pageViewController: PageView) {
      parent = pageViewController
      controllers = parent.pages.map {
        let vc = UIHostingController(rootView: $0)
        vc.view.backgroundColor = UIColor.clear
        return vc
      }
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
      guard let index = controllers.firstIndex(of: viewController),
        index > 0
      else {
        return nil
      }

      return controllers[index - 1]
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
      guard let index = controllers.firstIndex(of: viewController),
        index < controllers.count - 1
      else {
        return nil
      }

      return controllers[index + 1]
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      didFinishAnimating finished: Bool,
      previousViewControllers: [UIViewController],
      transitionCompleted completed: Bool
    ) {
      if completed,
        let visibleViewController = pageViewController.viewControllers?.first,
        let index = controllers.firstIndex(of: visibleViewController)
      {
        parent.currentPage = index
      }
    }
  }
}
