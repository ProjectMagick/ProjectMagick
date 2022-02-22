// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectMagick",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ProjectMagick",
            targets: ["ProjectMagick"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.5.0"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0"),
        .package(url: "https://github.com/gordontucker/FittedSheets.git", from: "2.0.0"),
        .package(url: "https://github.com/GottaGetSwifty/CodableWrappers.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "ProjectMagick",
            dependencies: [
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "FittedSheets", package: "FittedSheets"),
                .product(name: "CodableWrappers", package: "CodableWrappers")
            ],
            resources: [
                .process("Resources/JSONFiles/ListOfCountries.json", localization: nil),
                .process("Resources/Custom Code Snippets/CodeSnippets.zip", localization: nil)
            ]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
