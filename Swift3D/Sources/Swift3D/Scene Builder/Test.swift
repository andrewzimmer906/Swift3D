//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/20/23.
//

import Foundation



func makeCode(@SceneBuilder _ content: () -> any Node) -> any Node {
  content()
}

public struct SceneBuilderTest {
  public static func testBuilder() {
    // let yes = true
    // let no = false

    let tree = makeCode {

      ForEach3D(data: ["one", "two", "three"]) { element in
        TriangleNode(id: element)
      }

      GroupNode(id: "one") {
        TriangleNode(id: "tri1")
      }
      TriangleNode(id: "tris")
    }

    print("\n")
    print(tree)
    print("\n")
    print(tree.printedTree.reduce("", { partialResult, str in
      partialResult + "\n" + str
    }))
  }
}


