# Swift3D 🚀

🚀 **Swift3D** is a custom 3D engine used to define and render 3D scenes inside of existing 2D UI with declarative code.

Using a custom `DSL ` or `Domain Specific Language` that looks and feels like `SwiftUI`, you can define complex 3D scenes with custom lighting, transitions, and shaders.

💪 This engine uses the power of **Metal**, Apple's low-level graphics API, to drive your 3D experiences, making them fast and responsive. With the combination of `SwiftUI` + `Metal`, you can create really unique visual effects and animations.

Here are just a few examples of the types of things you can do.

https://user-images.githubusercontent.com/743883/224450940-29526ed6-ac6e-4426-87b1-485b26026dc4.mov

https://user-images.githubusercontent.com/743883/224450945-a781b5b8-1e8e-4345-a2c6-afcb6704e615.mov

<br>

### [![Stadium Seat View]([](https://user-images.githubusercontent.com/743883/224451700-dac955bf-2c86-4b8a-b51b-78ba7c820e6a.png))](http://www.youtube.com/shorts/rL8xp2Taz04 "Stadium Seat View")

<a href="http://www.youtube.com/shorts/rL8xp2Taz04"><img width="253" alt="Screenshot 2023-03-10 at 5 07 35 PM" src="https://user-images.githubusercontent.com/743883/224451700-dac955bf-2c86-4b8a-b51b-78ba7c820e6a.png"></a>


## Installation

Swift 3D uses **Swift Package Manager** for installation.  Please follow [Apple's Tutorial](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for this repository.

1. In Xcode, select “File” → “Add Packages...”

2. Enter `https://github.com/andrewzimmer906/Swift3D.git`.


> Or you can add the following dependency to your Package.swift:
>
> `.package(url: "https://github.com/andrewzimmer906/Swift3D.git", from: "1.0.0")`


# 🚀 Usage

### 📖 Check out the Demo project for usage examples and code.

**Swift3D** is a 3D engine that seamlessly integrates with **SwiftUI**, allowing you to create immersive 3D experiences using its custom `DSL`. 

The system supports:
 
 * `*.usdz`/`*.obj` Model Loading 
 * Primitive Shapes
 * Custom Lighting and Shaders
 * Custom Transitions and animations
 * Integration with `CMMotion` for IMU driven experiences

To get started, add a `Swift3DView` to your SwiftUI `View`, and start building your 3D scene. 

Here's a basic example that renders a cube:

```swift
struct aView: View {
var body: some View {
	Swift3DView {
	      CameraNode(id: "mainCam")
	        .translated(.back * 3)
	        
	      CubeNode(id: "cube")
	        .shaded(.unlit(.red))
	    }
    }
}
```

For more advanced usage, the `Demo.xcodeproj` includes additional examples covering custom lighting, model loading, update loops, camera controls, and transitions. 🌟


# 🤝 Contributing

Contributions to **Swift3D** are welcome and appreciated! If you encounter issues or have ideas for new features, please open a Github issue. If you're interested in contributing code, Pull Requests are also welcome.

However, please keep in mind that this is a side project and as such, it might take some time for me to review and respond to your requests. Nonetheless, I will do my best to provide feedback and collaborate as possible. 🎉


# 📝 License

**Swift3D** is licensed under the MIT License. See the [LICENSE](https://github.com/andrewzimmer906/Swift3D/blob/main/LICENSE) file for more information.

# 📬 Contact

If you want to say hi, I'm on Twitter at [@andrewzimmer906](https://twitter.com/andrewzimmer906) and of course Github as [andrewzimmer906](https://github.com/andrewzimmer906).

<br>

> ❤️ made with love in Colorado 🏔️🌄
