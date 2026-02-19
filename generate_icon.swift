import Cocoa

// Usage: swift generate_icon.swift <input_path> <output_path>

let args = CommandLine.arguments
guard args.count >= 3 else {
    print("Usage: swift generate_icon.swift <input> <output>")
    exit(1)
}

let inputPath = args[1]
let outputPath = args[2]

guard let image = NSImage(contentsOfFile: inputPath) else {
    print("❌ Failed to load image: \(inputPath)")
    exit(1)
}

// macOS Icon Standard Size
let size = NSSize(width: 1024, height: 1024)
let targetImage = NSImage(size: size)

targetImage.lockFocus()

let rect = NSRect(origin: .zero, size: size)

// Create Squircle-like Rounded Rect
// Apple's squircle is complex, but a rounded rect with ~22% radius is a good approximation.
let cornerRadius: CGFloat = 225
let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)

// Set clipping area to the rounded shape
path.addClip()

// Draw the source image, scaling to fill/fit
// We use 'scaleProportionallyUpOrDown' logic manually to cover the square
var srcRect: NSRect
let imgSize = image.size
let aspect = imgSize.width / imgSize.height
let targetAspect = size.width / size.height

if aspect > targetAspect {
    // Wider than target: crop width
    let newWidth = imgSize.height * targetAspect
    let xOffset = (imgSize.width - newWidth) / 2
    srcRect = NSRect(x: xOffset, y: 0, width: newWidth, height: imgSize.height)
} else {
    // Taller than target: crop height
    let newHeight = imgSize.width / targetAspect
    let yOffset = (imgSize.height - newHeight) / 2
    srcRect = NSRect(x: 0, y: yOffset, width: imgSize.width, height: newHeight)
}

image.draw(in: rect, from: srcRect, operation: .sourceOver, fraction: 1.0)

// Add "3D Effect" (Inner Shadown / Gloss)
// 1. Top-left gloss
let glossPath = NSBezierPath(roundedRect: rect.insetBy(dx: 20, dy: 20), xRadius: cornerRadius, yRadius: cornerRadius)
let glossGradient = NSGradient(colors: [
    NSColor.white.withAlphaComponent(0.4),
    NSColor.white.withAlphaComponent(0.0)
])
glossGradient?.draw(in: glossPath, angle: -45)

// 2. Bottom-right shadow
let shadowGradient = NSGradient(colors: [
    NSColor.black.withAlphaComponent(0.0),
    NSColor.black.withAlphaComponent(0.3)
])
shadowGradient?.draw(in: path, angle: -45)

// Draw border stroke
NSColor.black.withAlphaComponent(0.1).setStroke()
path.lineWidth = 4
path.stroke()

targetImage.unlockFocus()

// Save to PNG
if let tiff = targetImage.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
    if let pngData = bitmap.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Generated rounded icon at: \(outputPath)")
    }
} else {
    print("❌ Failed to generate bitmap representation")
    exit(1)
}
