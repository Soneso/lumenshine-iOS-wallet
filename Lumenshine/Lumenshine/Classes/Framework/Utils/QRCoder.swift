//
//  QRCoder.swift
//  Lumenshine
//
//  Created by Soneso on 11.11.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

final class QRCoder {
    
    static func qrCodeImage(qrValueString: String, size: CGFloat) -> UIImage? {
        let ciImage = generateQRImage(qrValueString: qrValueString)
        guard let cipImage = ciImage?.transformed(by: CGAffineTransform(scaleX: size, y: size)) else { return nil }
        let image = UIImage(ciImage: cipImage, scale: UIScreen.main.scale, orientation: .up)
        return image.withRenderingMode(.alwaysTemplate)
    }
    
    private static func generateQRImage(qrValueString: String) -> CIImage? {
        let data = qrValueString.data(using: .isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let image = filter?.outputImage else { return nil }
        
        let invertFilter = CIFilter(name: "CIColorInvert")
        invertFilter?.setValue(image, forKey: kCIInputImageKey)
        
        let alphaFilter = CIFilter(name: "CIMaskToAlpha")
        alphaFilter?.setValue(invertFilter?.outputImage, forKey: kCIInputImageKey)
        
        return alphaFilter?.outputImage
    }
}
