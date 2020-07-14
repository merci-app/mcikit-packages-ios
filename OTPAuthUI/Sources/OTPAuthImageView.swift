//
//  OTPAuthImageView.swift
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
    
    private var otpAuth: OTPAuth?
    private var vat: String?
    private var value: String?
    
    private func generateQRCode() {
        guard let currentToken = otpAuth?.currentToken,
            let vat = vat,
            let amount = value?.normalize()
        else {
            return
        }
        
        let code = "\(vat)\(currentToken)\(amount)"
        
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
    
    func generateToken(vat: String, otpAuth: OTPAuth, value: String = "", color: UIColor = .black) {
        
        self.vat = vat
        self.otpAuth = otpAuth
        self.value = value
        
        generateQRCode()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tokenTick(_:)),
            name: Notification.Name.OTPAuthNotification.tokenTick,
            object: otpAuth
        )
        
        otpAuth.startNotificattion()
    }
    
    deinit {
        otpAuth?.stopNotification()
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name.OTPAuthNotification.tokenTick,
            object: otpAuth
        )
    }
}

// MARK: - Notification Center

extension OTPAuthImageView {
    @objc public func tokenTick(_ notification: Notification) {
        DispatchQueue.main.async {
            self.generateQRCode()
        }
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
