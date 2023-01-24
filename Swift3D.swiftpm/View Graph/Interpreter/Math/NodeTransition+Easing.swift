//
//  NodeAnimation+Easing.swift
//  
//
//  Created by Andrew Zimmer on 1/23/23.
//

import Foundation

extension NodeTransition {  
  func interpolate(time: CFTimeInterval) -> Float {    
    switch self.curve {
    case .linear(let duration):
      let p = Self.progress(Double(duration), startTime: startTime, time: time)
      return Curve.linear(p)
    case .easeIn(let duration):
      let p = Self.progress(Double(duration), startTime: startTime, time: time)
      return Curve.easeInCubic(p)
    case .easeOut(let duration):
      let p = Self.progress(Double(duration), startTime: startTime, time: time)
      return Curve.easeOutCubic(p)
    case .easeInOut(let duration):
      let p = Self.progress(Double(duration), startTime: startTime, time: time)
      return Curve.easeOutCubic(p)
    }
  }
  
  private static func progress(_ duration: Double, startTime: Double, time: CFTimeInterval) -> Float {
    let endTime = startTime + duration
    let progress = 1 - ((endTime - time) / duration)
    return Float(progress).saturated
  }
}

fileprivate extension NodeTransition.Curve {
  static func linear(_ x: Float) -> Float {
    x
  }
  
  static func easeInCubic(_ x: Float) -> Float {
    x * x * x;
  }
  
  static func easeOutCubic(_ x: Float) -> Float {
    1 - pow(1 - x, 3);
  }
  
  static func easeInOutCubic(_ x: Float) -> Float {
    return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
  }
}
