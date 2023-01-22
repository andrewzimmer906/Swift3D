//
//  MetalSwiftView.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import UIKit
import SwiftUI

struct Swift3DView: UIViewRepresentable {
  let content: () -> any Node
  
  init(@SceneBuilder _ content: @escaping () -> any Node) {
    self.content = content
  }

  func makeUIView(context: Context) -> UIView {
    // Needs initial frame to not be zero to create MTLDevice
    let view = MetalView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    view.setContent(content())
    
    return view
  }

  func updateUIView(
    _ uiView: UIView,
    context: Context
  ) {
    if let view = uiView as? MetalView {
      view.setContent(content())
    }
  }
}
