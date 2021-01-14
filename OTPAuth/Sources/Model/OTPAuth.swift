//
//  OTPAuth.swift
//

import Foundation
import CommonCrypto

public final class OTPAuth: Codable {
    
    private var url: String? = nil
    private var period: TimeInterval = 0
    private var algorithm: OTPAuthAlgorithm = .sha1
    private var factor: OTPAuthFactor = .timer(period: 0)
    private var digits: Int = 0
    private var secret: Data? = nil
    private var expirationDate: Date = Date()
    private var timer: Timer?
    
    private var lastToken: String? = nil {
        didSet {
            try? calculateExpirationDate(currentToken: lastToken)
        }
    }
    
    public var currentToken: String? {
        let currentTime = self.retriveDateNow()
        let expirationInterval = expirationDate.timeIntervalSince1970 - currentTime.timeIntervalSince1970
        
        if lastToken != nil && expirationInterval > 1 && expirationInterval <= period {
            return lastToken
        }
        
        let currentToken = try? Algorithm.hash(currentTime, factor, algorithm, digits, secret)
        lastToken = currentToken
        
        return currentToken
    }
    
    public var remainingSeconds: String {
        return String(format: "%0.0f", expirationDate.timeIntervalSince1970 - self.retriveDateNow().timeIntervalSince1970)
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case url
    }
    
    // MARK: - Initialization Methods
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        try generate()
        try calculateExpirationDate()
    }
    
    public init(from url: String) throws {
        self.url = url
        try generate()
        try calculateExpirationDate()
    }
    
    // MARK: - Private Methods
    
    private func retriveDateNow() -> Date {
        return Date().addingTimeInterval(0)
        // Date(timeIntervalSince1970: .init(1579019940)) //
    }
    
    private func calculateExpirationDate(currentToken: String? = nil) throws {
        
        let password = currentToken ?? self.currentToken
        let now = retriveDateNow()
        var futureDate: Date? = nil
        
        for i in 0...UInt(period) {
            let date = now.addingTimeInterval(TimeInterval(i))
            let futurePassword = try? Algorithm.hash(date, factor, algorithm, digits, secret)
            if futurePassword != nil && futurePassword != password {
                futureDate = date
                break
            }
        }
        
        if futureDate == nil {
            throw OTPAuthError.invalidExpirationDate
        }
        
        expirationDate = futureDate!
    }
    
    private func generate() throws {
        
        guard let urlString = self.url, let url = URL(string: urlString), url.scheme == "otpauth" else {
            throw OTPAuthError.invalidURLScheme
        }
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        if queryItems.isEmpty {
            throw OTPAuthError.invalidURLScheme
        }
        
        do {
            period = try queryItems.value(for: "period").map(parseTimerPeriod) ?? 30
            algorithm = try queryItems.value(for: "algorithm").map(OTPAuthAlgorithm.init) ?? OTPAuthAlgorithm.sha1
            digits = try queryItems.value(for: "digits").map(parseDigits) ?? 6
            secret = try queryItems.value(for: "secret").map(parseSecret)
        } catch {
            throw OTPAuthError.genericError("Url parser error: \(error)")
        }
        
        do {
            try validatePeriod(period)
            try validateDigits(digits)
        } catch {
            throw OTPAuthError.genericError("Validation error: \(error)")
        }
        
        factor = .timer(period: period)
    }
    
    deinit {
        debugPrint("\(OTPAuth.self) -> deinit")
     }
    
}

// MARK: - Equatable

extension OTPAuth: Equatable {
    
    public static func == (lhs: OTPAuth, rhs: OTPAuth) -> Bool {
        return lhs.url == rhs.url
    }
    
}

// MARK: - Parse Methods

private extension OTPAuth {
    
    func parseTimerPeriod(_ rawValue: String) throws -> TimeInterval {
        guard let period = TimeInterval(rawValue) else {
            throw OTPAuthError.invalidTimerPeriod(rawValue)
        }
        return period
    }
    
    func parseDigits(_ rawValue: String) throws -> Int {
        guard let digits = Int(rawValue) else {
            throw OTPAuthError.invalidDigits(rawValue)
        }
        return digits
    }
    
    func parseSecret(_ rawValue: String) throws -> Data {
        guard let secret = Base32.base32DecodeToData(rawValue) else {
            throw OTPAuthError.invalidSecret
        }
        return secret
    }
    
}

// MARK: - Validation Methods

private extension OTPAuth {
    
    func validatePeriod(_ period: TimeInterval) throws {
        guard period > 0 else {
            throw OTPAuthError.invalidTimerPeriod("period must be greater than 0")
        }
    }
    
    func validateDigits(_ digits: Int) throws {
        let acceptableDigits = 3...8
        guard acceptableDigits.contains(digits) else {
            throw OTPAuthError.invalidDigits("digit must be 4...8")
        }
    }
    
}

// MARK: - Notification Methods

extension OTPAuth {
    
    public func startNotificattion() {
        if timer != nil { return }
        
        let timer = Timer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(timerTick(_:)),
            userInfo: nil, repeats: true)
        
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        timer.fire()
        
        self.timer = timer
    }
    
    public func stopNotification() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func timerTick(_ timer: Timer) {
        let userInfo = [
            "CURRENT_PASSWORD": self.currentToken ?? "",
            "REMAINING_SECONDS": self.remainingSeconds
        ]
        
        NotificationCenter.default.post(
            name: Notification.Name.OTPAuthNotification.tokenTick,
            object: self,
            userInfo: userInfo
        )
    }
    
}
