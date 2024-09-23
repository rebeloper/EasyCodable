//
//  EasyCodable+Encoder.swift
//  EasyCodable
//
//  Created by Alex Nagy on 23.09.2024.
//

import Foundation

public extension Encoder {
    func encode<T: Encodable, K: CodingKey>(_ value: T, for key: K, logLevel: EasyCodableLogLevel = .none) {
        var container = self.container(keyedBy: K.self)
        log("-----------------------------------", logLevel: logLevel)
        log("Starting to encode key '\(key.stringValue)': \(value)", logLevel: logLevel)
        do {
            try container.encode(value, forKey: key)
            log("Encoded value for key '\(key.stringValue)': \(value)", logLevel: logLevel)
        } catch EncodingError.invalidValue(let type, let context) {
            log("Failed to encode type '\(type)' for key '\(key.stringValue)' due to invalid value – \(context.debugDescription)", logLevel: logLevel)
        } catch {
            log("Failed to encode key '\(key.stringValue)' - \(error.localizedDescription)", logLevel: logLevel)
        }
    }
    
    private func log(_ message: String, logLevel: EasyCodableLogLevel) {
        if logLevel == .debug {
            print(message)
        }
    }
}
