//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/23/23.
//

import Foundation

extension Float {
  var saturated: Float {
    max(0, min(1, self))
  }
  
  static func lerp(_ from: Float, _ to: Float, _ percent: Float) -> Float {
    return from + (to - from) * percent
  }
}
