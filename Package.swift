// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BenchmarkThreadSafeStrunctures",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "ImplWrapper",
            targets: ["ImplWrapper"]),
        .executable(
            name: "ImplWrapper2",
            targets: ["ImplWrapper2"]),
        .executable(
            name: "ThreadSafeDict",
            targets: ["ThreadSafeDict"]),
        .executable(
            name: "AtomicThreadSafety",
            targets: ["AtomicThreadSafety"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
//        .target(
//            name: "BenchmarkThreadSafeStrunctures",
//            dependencies: [])
        .executableTarget(
            name: "ImplWrapper",
            dependencies: [.product(name: "CollectionsBenchmark", package: "swift-collections-benchmark")]),
        
        .executableTarget(
            name: "ImplWrapper2",
            dependencies: [.product(name: "CollectionsBenchmark", package: "swift-collections-benchmark")]),
        
        .executableTarget(
            name: "ThreadSafeDict",
            dependencies: [.product(name: "CollectionsBenchmark", package: "swift-collections-benchmark")]),
        
        .executableTarget(
            name: "ThreadSafeAtomicProperty",
            dependencies: [.product(name: "CollectionsBenchmark", package: "swift-collections-benchmark")]),
        
        .executableTarget(
            name: "AtomicThreadSafety",
            dependencies: [.product(name: "CollectionsBenchmark", package: "swift-collections-benchmark")])

    ]
)
