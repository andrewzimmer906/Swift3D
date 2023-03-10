//
//  URL+IO.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/10/23.
//

import Foundation

extension URL {
  static func model(_ path: String) -> URL {
    let components = path.components(separatedBy: ".")
    guard components.count == 2,
          let url = Bundle.main.url(forResource: components[0], withExtension: components[1]) else {
      fatalError()
    }
    return url
  }
}
