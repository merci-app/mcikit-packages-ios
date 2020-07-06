//
//  QRCodeImageView.swift
//  PayCodeVC
//
//  Created by Tiago Oliveira on 01/07/20.
//  Copyright © 2020 Conductor Solucoes. All rights reserved.
//

import UIKit
import OTPAuth

class OTPAuthImageView: UIImageView {
    
    @IBInspectable
    var color: UIColor = .black
    
    func generateToken(vat: String, otpAuth: OTPAuth, value: String = "", color: UIColor = .black) {
        NotificationCenter.default.post(name: Notification.Name.OTPAuthNotification.tokenTick, object: otpAuth)
        guard let currentToken = otpAuth.currentToken else { return }
        let amount = value.normalize()
        let code = vat + currentToken + amount
        
        var context: CIContext!
        
        if let device: MTLDevice =  MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: device, options: nil)
        } else {
            context = CIContext()
        }
        
        guard
            let data = code.data(using: .isoLatin1),
            let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        guard
            let ciFilterImage = filter.outputImage?.transformed(by: transform),
            let ciTintImage = ciFilterImage.tint(using: color)
        else { return }
        
        guard let cgImage = context.createCGImage(ciTintImage, from: ciTintImage.extent, format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        else { return }
        
        self.image = UIImage(cgImage: cgImage)
    }
}

// MARK: - Numbers only

extension String {
     func normalize() -> String {
        if self != "" {
            let string = self.replacingOccurrences(of: "\\D*", with: "",  options: .regularExpression, range: nil)
            return string.padding(leftTo: 10, withPad: "0")
        } else {
            return ""
        }
    }
    
    func padding(leftTo paddedLength: Int, withPad pad: String, startingAt padStart: Int = 0) -> String {
       let rightPadded = self.padding(toLength: max(count, paddedLength), withPad: pad, startingAt: padStart)
       return "".padding(toLength: paddedLength, withPad: rightPadded, startingAt: count % paddedLength)
    }
}
