//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/3/23.
//

import Foundation
import SwiftUI

extension Color {
  public init(hex: Int, opacity: Double = 1.0) {
    let red = Double((hex & 0xff0000) >> 16) / 255.0
    let green = Double((hex & 0xff00) >> 8) / 255.0
    let blue = Double((hex & 0xff) >> 0) / 255.0
    self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}
