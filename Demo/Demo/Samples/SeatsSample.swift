//
//  SeatsSample.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/20/23.
//

import Foundation
import SwiftUI
import Swift3D
import simd

fileprivate class Data {
  var rotation: Float = 0
}

struct SeatsSample: View {
  private let data = Data()
  private let motion = Motion()
  @State var motionActive = false

  var body: some View {
    VStack {
      header
      section
      Divider()
      seatView
      details
      Spacer()
    }
  }

  var header: some View {
    HStack(alignment: .bottom) {
      capLogo("phillies")
      Text("at")
        .foregroundColor(.gray)
      capLogo("la")


      VStack(alignment: .leading, spacing: 4) {
        Text("Fri Sep 23 • 7:10PM")
        Text("Dodger Stadium")
      }
      Spacer()
      Divider()
      Text("2 Tickets")
        .font(.body.bold())
        .frame(maxHeight: .infinity)
        .padding(.horizontal)
    }
    .padding()
    .font(.caption)
    .frame(maxWidth: .infinity)
    .frame(height: 80)
    .background(Color.white.shadow(color: .black.opacity(0.15),
                                  radius: 6, y: 12))
  }

  var section: some View {
    HStack(spacing: 18) {
      HStack(spacing: 4) {
        Text("2")
        Image(systemName: "ticket")
      }
      VStack(alignment: .leading, spacing: 4) {
        Text("Section 12, Row A, Seat 10")
          .font(.body.bold())
        Text("$68.50")
          .font(.body)
      }
      Spacer()
    }
    .padding()
  }

  func capLogo(_ name: String) -> some View {
    Image(name)
      .resizable()
      .aspectRatio(1, contentMode: .fit)
      .frame(width: 32)
  }

  var seatView: some View {
    VStack(alignment: .leading) {
      Text("Seat View")
        .font(.title2)
      Text("Tap to Explore")
        .font(.caption)
        .foregroundColor(.gray)

      ZStack {
        Swift3DView {
          CameraNode(id: "main")
            .skybox(.skybox(.cube("stadiumEnv")))
            .rotated(angle: .pi, axis: .up)
            .transform(motionActive ? motion.curCamAttidue : .identity)
        }
        .blur(radius: motionActive ? 0 : 2)
        .background(.white, ignoresSafeAreaEdges: .all)
        .onAppear {
          motion.start()
        }
        .onDisappear {
          motion.end()
        }
        if !motionActive {
          Color.black.opacity(0.25)
          HStack(spacing: 16) {
            Image(systemName: "viewfinder.circle")
              .resizable()
              .foregroundColor(.white)
              .frame(width: 40, height: 40)
              .aspectRatio(contentMode: .fit)
            Text("Tap and Look around")
              .font(.title2)
              .foregroundColor(.white)
          }
        }
      }
      .frame(height: 300)
      .cornerRadius(12)
    }
    .onTapGesture {
      motionActive.toggle()
    }
    .padding()
  }

  var details: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Tickets")
        Spacer()
        Text("$15.00").bold()
        Text("x2")
          .font(.caption.bold())
          .foregroundColor(.gray)
      }

      HStack {
        Text("Service Fee")
        Spacer()
        Text("$4.00").bold()
        Text("x2")
          .font(.caption.bold())
          .foregroundColor(.gray)
      }

      HStack {
        Text("Convenience Fee")
        Spacer()
        Text("$2.00").bold()
        Text("x2")
          .font(.caption.bold())
          .foregroundColor(.gray)
      }

      HStack {
        Text("Taxes")
        Spacer()
        Text("$5.00").bold()
        Text("   ")
      }
      Divider()
      HStack {
        Text("Total")
        Spacer()
        Text("$47.00").bold()
      }
      .font(.title2)
    }.padding()
  }

  struct preview: PreviewProvider {
    static var previews: some View {
      SeatsSample()
    }
  }
}
