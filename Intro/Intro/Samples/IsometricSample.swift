import SwiftUI
import Swift3D
import simd

struct Point: Identifiable {
  let id: String
  let position: simd_float3
}

class PointCloud {
  let points: [Point]

  init(radius: Float = 2, numPoints: Int = 120) {
    var pointsMut: [Point] = []

    while pointsMut.count < numPoints {
      let x = Float.random(in: -radius..<radius)
      let y = Float.random(in: -radius..<radius)
      let z = Float.random(in: -radius..<radius)
      pointsMut.append(
        Point(id: "\(pointsMut.count)",
              position: simd_float3(x: x, y: y, z: z)))
    }

    self.points = pointsMut
  }
}

struct IsometricSample: View {
  @State var is3D: Bool = false
  @State var perspectivePos = CameraPosition.center(0)
  @State var pointCloud = PointCloud()

  var body: some View {
    VStack(spacing: 12) {
      Text("🕺 Add Automatic Transitions, just like SwiftUI 💃")
      Text("📸 Let's switch from Orthographic to a Perspective Projection. 🔥")
      ZStack {
        VStack {
          Swift3DView(preferredFps: 10, updateLoop: { deltaTime in
            if is3D {
              perspectivePos = perspectivePos.next
            } else {
              perspectivePos = .center(0)
            }
          }) {
            if is3D {
              CameraNode(id: "zoomCamera")
                .perspective()
                .transform(perspectivePos.transform)
                .transition(.easeOut(0.8))
            } else {
              CameraNode(id: "zoomCamera")
                .orthographic(viewSpace: CGRect(x: -3, y: -3, width: 6, height: 6))
                .translated(.back * 4)
                .transition(.easeOut(0.3))
            }

            StandardLighting(id: "lights")

            ForEach3D(pointCloud.points) { point in
              CubeNode(id: point.id)
                .shaded(.standard(albedo: Color.red))
                .scaled(.one * 0.075)
                .translated(point.position)
            }
          }
        }
      }
      .aspectRatio(1, contentMode: .fit)
      .frame(maxHeight: .infinity)

      Button {
        is3D.toggle()
      } label: {
        if is3D {
          Text("Back to Ortho").foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)).fill(Color.gray))
        }
        else {
          Text("Perspective!")
            .font(.title3.bold())
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)).fill(Color.blue))
        }
      }
    }
    .padding()
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      IsometricSample()
    }
  }

  private func axis(id: String) -> some Node {
    GroupNode(id: id) {
      CubeNode(id: "X")

        .transform(.translated(.right))
        .transform(.scaled(simd_float3(x: 2, y: 0.15, z: 0.15)))

      CubeNode(id: "Y")

        .transform(.translated(.up))
        .transform(.scaled(simd_float3(x: 0.15, y: 2, z: 0.15)))

      CubeNode(id: "Z")
        .transform(.translated(.forward))
        .transform(.scaled(simd_float3(x: 0.15, y: 0.15, z: 2)))
    }
  }
}

// TODO: Add repeat and delay into my transitions so we can remove the
// need for this.
extension IsometricSample {
  enum CameraPosition {
    case center(Double)
    case left(Double)
    case right(Double)

    var transform: float4x4 {
      switch self {
      case .center:
        return .translated(.back * 4)
      case .left:
        return
          .rotated(angle: -.pi / 8, axis: .up) *
          .translated(.back * 4)
      case .right:
        return
          .rotated(angle: .pi / 8, axis: .up) *
          .translated(.back * 4)
      }
    }

    var next: Self {
      let frameTime = CACurrentMediaTime()
      switch self {
      case .center(let target):
        if target == 0 {
          return .center(frameTime + 0.3)
        }

        if frameTime > target {
          return .left(frameTime + 1)
        } else {
          return .center(target)
        }

      case .left(let target):
        if frameTime > target {
          return .right(frameTime + 1)
        } else {
          return .left(target)
        }
      case .right(let target):
        if frameTime > target {
          return .center(frameTime + 2)
        } else {
          return .right(target)
        }
      }
    }
  }
}
