// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MGArchitecture",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "MGArchitecture",
            targets: ["MGArchitecture"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "MGArchitecture",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "MGArchitecture/Sources"
        ),    
    ],
    swiftLanguageVersions: [.v5]
)
