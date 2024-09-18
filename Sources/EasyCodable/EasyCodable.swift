// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

private extension KeyedDecodingContainer {
    
    func decode<T: Decodable>(_ type: T.Type, forKeys: [K], index: Int = 0, showLogs: Bool) throws -> T? {
        do {
            if index < forKeys.count - 1 {
                let value = try self.decode(T.self, forKey: forKeys[index])
                log("Decoded value for key: `\(forKeys[index].stringValue)`: \(value)", showLogs: showLogs)
                return value
            } else {
                let value = try self.decodeIfPresent(T.self, forKey: forKeys[index])
                log("Decoded value for key: `\(forKeys[index].stringValue)`: \(String(describing: value))", showLogs: showLogs)
                return value
            }
        } catch {
            switch error._code {
            case 4864:
                log("Decoding error for key: `\(forKeys[index].stringValue)`. \(error.localizedDescription) Using default value.", showLogs: showLogs)
                return nil
            case 4865:
                log("Decoding error for key: `\(forKeys[index].stringValue)`. \(error.localizedDescription) Decoding for \(forKeys[index + 1].stringValue)` key instead.", showLogs: showLogs)
                return try decode(type, forKeys: forKeys, index: index + 1, showLogs: showLogs)
            default:
                log("Decoding error for key: `\(forKeys[index].stringValue)`. \(error.localizedDescription)", showLogs: showLogs)
                throw error
            }
        }
    }
    
    func log(_ message: String, showLogs: Bool) {
        if showLogs {
            print(message)
        }
    }
}

public struct ToBeEncoded {
    public let value: Encodable
    public let key: CodingKey
    
    public init(value: Encodable, key: CodingKey) {
        self.value = value
        self.key = key
    }
}

public extension Encoder {
    /// Encode a value for a given key, specified as a `CodingKey`.
    func encode<T: Encodable, K: CodingKey>(_ value: T, for key: K, showLogs: Bool = true) throws {
        var container = self.container(keyedBy: K.self)
        do {
            try container.encode(value, forKey: key)
            log("Encoded for key: `\(key.stringValue)`, value: \(value)", showLogs: showLogs)
        } catch {
            log("Encoding error for key: `\(key.stringValue)` with value: \(value). \(error.localizedDescription)", showLogs: showLogs)
            throw error
        }
    }
    
    func encode(_ toBeEncoded: ToBeEncoded..., showLogs: Bool = true) throws {
        try toBeEncoded.forEach { try encode($0.value, for: $0.key, showLogs: showLogs) }
    }
    
    private func log(_ message: String, showLogs: Bool) {
        if showLogs {
            print(message)
        }
    }
}

public extension Decoder {
    /// Decode an optional value for the given key or keys, specified as a `CodingKey`s. Keys will be used as first one as latest version.
    func decode<T: Decodable, K: CodingKey>(_ keys: K..., as type: T.Type = T.self, showLogs: Bool = false) throws -> T? {
        try decode(keys, as: type, showLogs: showLogs)
    }
    
    private func decode<T: Decodable, K: CodingKey>(_ keys: [K], as type: T.Type = T.self, showLogs: Bool) throws -> T? {
        let container = try self.container(keyedBy: K.self)
        return try container.decode(type, forKeys: keys, showLogs: showLogs)
    }
}

