//
//  QRCodeImageView.swift
//  PayCodeVC
//
//  Created by Tiago Oliveira on 01/07/20.
//  Copyright © 2020 Conductor Solucoes. All rights reserved.
//

import UIKit

class QRCodeImageView: UIImageView {
    
    @IBInspectable
    var color: UIColor = .black
    
    @IBInspectable
    var code: String = "" {
        didSet {
            self.image = barcode(code, color: color)
        }
    }
    
    func barcode(_ code: String, color: UIColor = .black) -> UIImage? {
        
        var context: CIContext!
        
        if let device: MTLDevice =  MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: device, options: nil)
        } else {
            context = CIContext()
        }
        
        guard
            let data = code.data(using: .isoLatin1),
            let filter = CIFilter(name: "CIQRCodeGenerator")
        else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        guard
            let ciFilterImage = filter.outputImage?.transformed(by: transform),
            let ciTintImage = ciFilterImage.tint(using: color)
        else {
            return nil
        }
        
        guard let cgImage = context.createCGImage(ciTintImage, from: ciTintImage.extent, format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB()) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
