//
//  Command.swift
//  
//
//  Created by Andrew Zimmer on 1/24/23.
//

import Foundation

extension DrawCommand {
  enum Command {
    case draw(String)
    case placeCamera(String)
    
    var isCamera: Bool {
      switch self {
      case .placeCamera:
        return true
      default:
        return false
      }
    }
  }
}

// MARK: - Equatable

extension DrawCommand.Command: Equatable {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch(lhs, rhs) {
    case (.draw(let lhsId), .draw(let rhsId)):
      return lhsId == rhsId
    case (.placeCamera(let lhsId), .placeCamera(let rhsId)):
      return lhsId == rhsId  
    default:
      return false
    }
  }
}
