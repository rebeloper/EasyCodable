//
//  EasyCodable+Decoder.swift
//  EasyCodable
//
//  Created by Alex Nagy on 23.09.2024.
//

import Foundation

public extension Decoder {
    func decode<T: Decodable, K: CodingKey>(_ keys: K..., fallback: T? = nil, logLevel: EasyCodableLogLevel = .none) -> T? {
        decode(keys, fallback: fallback, logLevel: logLevel)
    }
    
    func decode<T: Decodable, K: CodingKey>(_ keys: [K], fallback: T? = nil, logLevel: EasyCodableLogLevel = .none) -> T? {
        decoded(keys, fallback: fallback, logLevel: logLevel) ?? fallback
    }
    
    private func decoded<T: Decodable, K: CodingKey>(_ keys: [K], fallback: T? = nil, logLevel: EasyCodableLogLevel) -> T? {
        log("-----------------------------------", logLevel: logLevel)
        log("Starting to decode keys: \(keys.map { $0.stringValue })", logLevel: logLevel)
        do {
            let container = try self.container(keyedBy: K.self)
            return container.decode(keys, fallback: fallback, logLevel: logLevel)
        } catch {
            log("Failed to decode: \(error.localizedDescription). Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return fallback
        }
    }
    
    func decode<T: Decodable, K: CodingKey>(_ keys: K..., fallback: [T]? = nil, logLevel: EasyCodableLogLevel = .none) -> [T]? {
        decode(keys, fallback: fallback, logLevel: logLevel)
    }
    
    func decode<T: Decodable, K: CodingKey>(_ keys: [K], fallback: [T]? = nil, logLevel: EasyCodableLogLevel = .none) -> [T]? {
        decoded(keys, fallback: fallback, logLevel: logLevel) ?? fallback
    }
    
    private func decoded<T: Decodable, K: CodingKey>(_ keys: [K], fallback: [T]? = nil, logLevel: EasyCodableLogLevel) -> [T]? {
        log("-----------------------------------", logLevel: logLevel)
        log("Starting to decode keys: \(keys.map { $0.stringValue })", logLevel: logLevel)
        do {
            let container = try self.container(keyedBy: K.self)
            return container.decode(keys, fallback: fallback, logLevel: logLevel)
        } catch {
            log("Failed to decode: \(error.localizedDescription). Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return fallback
        }
    }
    
    private func log(_ message: String, logLevel: EasyCodableLogLevel) {
        if logLevel == .debug {
            print(message)
        }
    }
}
