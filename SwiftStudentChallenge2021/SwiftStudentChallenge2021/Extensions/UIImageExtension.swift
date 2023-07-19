import UIKit
import CoreML

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image(actions: { (context) in
           self.draw(in: CGRect(origin: .zero, size: size))
        })
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_OneComponent8, nil, &pixelBuffer)
        
        guard let unwrappedPixelBuffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        let colorspace = CGColorSpaceCreateDeviceGray()
        guard let bitmapContext = CGContext(data: CVPixelBufferGetBaseAddress(unwrappedPixelBuffer),
                                            width: width, height: height,
                                            bitsPerComponent: 8,
                                            bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
                                            space: colorspace, bitmapInfo: 0) else { return nil }
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelBuffer
    }
    
    func invertedImage() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CoreImage.CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: outputImageCopy, scale: self.scale, orientation: .up)
    }
    
    public func mask(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        color.setFill()
        self.draw(in: rect)
        context?.setBlendMode(.sourceIn)
        context?.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage ?? UIImage()
    }
}
