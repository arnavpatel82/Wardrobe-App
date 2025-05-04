import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageProcessor {
    static func removeBackground(from image: UIImage, threshold: Double) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext(options: nil)
        
        // Create a color controls filter to adjust contrast
        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = ciImage
        colorControls.contrast = Float(threshold * 2) // Scale threshold to contrast range
        
        // Create a color matrix filter to create a mask
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = colorControls.outputImage
        colorMatrix.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(threshold))
        
        // Create a blend filter to apply the mask
        let blend = CIFilter.blendWithMask()
        blend.inputImage = ciImage
        blend.backgroundImage = CIImage.empty()
        blend.maskImage = colorMatrix.outputImage
        
        guard let outputImage = blend.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: outputCGImage)
    }
}

enum ImageProcessingError: Error {
    case invalidImage
    case segmentationFailed
    case processingFailed
} 
