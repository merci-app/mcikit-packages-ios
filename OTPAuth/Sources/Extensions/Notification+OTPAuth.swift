//
//  NotificationName+OTPAuth.swift
//

import Foundation

public extension Notification.Name {
    
    enum OTPAuthNotification {
        public static let tokenTick = Notification.Name("mcikit-packages-ios.mci-otpauth.token-tick")
    }
    
}
