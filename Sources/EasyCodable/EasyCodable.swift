// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum EasyCodableLogLevel {
    case none
    case debug
}

private extension KeyedDecodingContainer {
    
    func decode<T: Decodable>(_ type: T.Type, forKeys: [K], index: Int = 0, logLevel: EasyCodableLogLevel) throws -> T? {
        do {
            if index < forKeys.count - 1 {
                let value = try self.decode(T.self, forKey: forKeys[index])
                log("Decoded value for key: `\(forKeys[index].stringValue)`: \(value)", logLevel: logLevel)
                return value
            } else {
                let value = try self.decodeIfPresent(T.self, forKey: forKeys[index])
                log("Decoded value for key: `\(forKeys[index].stringValue)`: \(String(describing: value))", logLevel: logLevel)
                return value
            }
        } catch {
            switch error._code {
            case 4864:
                log("Decoding error for key: `\(forKeys[index].stringValue)`. \(error.localizedDescription) Using default value.", logLevel: logLevel)
                return nil
            case 4865:
                log("Decoding error for key: `\(forKeys[index].stringValue)`. \(error.localizedDescription) Decoding for \(forKeys[index + 1].stringValue)` key instead.", logLevel: logLevel)
                return try decode(type, forKeys: forKeys, index: index + 1, logLevel: logLevel)
            default:
                log("Decoding error for key: `\(forKeys[index].stringValue)`. \(error.localizedDescription)", logLevel: logLevel)
                throw error
            }
        }
    }
    
    func log(_ message: String, logLevel: EasyCodableLogLevel) {
        if logLevel == .debug {
            print(message)
        }
    }
}

public extension Encoder {
    /// Encode a value for a given key, specified as a `CodingKey`.
    func encode<T: Encodable, K: CodingKey>(_ value: T, for key: K, logLevel: EasyCodableLogLevel = .none) {
        var container = self.container(keyedBy: K.self)
        do {
            try encodeThrowing(value, for: key, logLevel: logLevel)
        } catch {
            log("Encoding error for key: `\(key.stringValue)` with value: \(value). \(error.localizedDescription)", logLevel: logLevel)
        }
    }
    
    /// Encode a value for a given key, specified as a `CodingKey`.
    func encodeThrowing<T: Encodable, K: CodingKey>(_ value: T, for key: K, logLevel: EasyCodableLogLevel = .none) throws {
        var container = self.container(keyedBy: K.self)
        try container.encode(value, forKey: key)
        log("Encoded for key: `\(key.stringValue)`, value: \(value)", logLevel: logLevel)
    }
    
    private func log(_ message: String, logLevel: EasyCodableLogLevel) {
        if logLevel == .debug {
            print(message)
        }
    }
}

public extension Decoder {
    /// Decode an optional value for the given key or keys, specified as a `CodingKey`s. Keys will be used as first one as latest version.
    func decode<T: Decodable, K: CodingKey>(_ keys: K..., fallback: T, as type: T.Type = T.self, logLevel: EasyCodableLogLevel = .none) -> T {
        decode(keys, fallback: fallback, as: type, logLevel: logLevel)
    }
    
    /// Decode an optional value for the given key or keys, specified as a `CodingKey`s. Keys will be used as first one as latest version.
    func decode<T: Decodable, K: CodingKey>(_ keys: [K], fallback: T, as type: T.Type = T.self, logLevel: EasyCodableLogLevel = .none) -> T {
        (try? decodeThrowing(keys, fallback: fallback, as: type, logLevel: logLevel)) ?? fallback
    }
    
    /// Decode an optional value for the given key or keys, specified as a `CodingKey`s. Keys will be used as first one as latest version.
    func decodeThrowing<T: Decodable, K: CodingKey>(_ keys: K..., fallback: T, as type: T.Type = T.self, logLevel: EasyCodableLogLevel = .none) throws -> T {
        try decodeThrowing(keys, fallback: fallback, as: type, logLevel: logLevel)
    }
    
    /// Decode an optional value for the given key or keys, specified as a `CodingKey`s. Keys will be used as first one as latest version.
    func decodeThrowing<T: Decodable, K: CodingKey>(_ keys: [K], fallback: T, as type: T.Type = T.self, logLevel: EasyCodableLogLevel = .none) throws -> T {
        let container = try self.container(keyedBy: K.self)
        return try container.decode(type, forKeys: keys, logLevel: logLevel) ?? fallback
    }
}

