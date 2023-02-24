//
//  CodeModifier.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/24/23.
//

import Foundation
import SwiftUI

struct CodeModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.system(size: 14).monospaced().bold())
      .foregroundColor(Color(hex: 0x006400))
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(Color(hex: 0xf3f3f3))
  }
}

extension View {
  func asCode() -> some View {
    modifier(CodeModifier())
  }
}
