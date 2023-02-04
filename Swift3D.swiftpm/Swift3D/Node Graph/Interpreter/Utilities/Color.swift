//
//  Color.swift
//  
//
//  Created by Andrew Zimmer on 1/31/23.
//

import Foundation
import simd
import SwiftUI

extension Color {
  var components: simd_float4 {
    let converted = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    converted.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return simd_float4(x: Float(red), y: Float(green), z: Float(blue), w: Float(alpha))
  }
}
