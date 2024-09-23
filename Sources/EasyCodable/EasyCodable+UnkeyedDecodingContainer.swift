//
//  EasyCodable+UnkeyedDecodingContainer.swift
//  EasyCodable
//
//  Created by Alex Nagy on 23.09.2024.
//

import Foundation

fileprivate struct DummyCodable: Codable {}

public extension UnkeyedDecodingContainer {

    mutating func decodeArray<T>(logLevel: EasyCodableLogLevel) throws -> [T] where T : Decodable {
        
        var array = [T]()
        while !self.isAtEnd {
            do {
                let item = try self.decode(T.self)
                array.append(item)
            } catch DecodingError.keyNotFound(let key, let context) {
                log("Failed to decode key due to missing key '\(key.stringValue)' not found – \(context.debugDescription)", logLevel: logLevel)
                // hack to increment currentIndex
                _ = try self.decode(DummyCodable.self)
            } catch DecodingError.typeMismatch(let type, let context) {
                log("Failed to decode key due to type mismatch of type: '\(type)' – \(context.debugDescription) Skipping item.", logLevel: logLevel)
                // hack to increment currentIndex
                _ = try self.decode(DummyCodable.self)
            } catch DecodingError.valueNotFound(let type, let context) {
                log("Failed to decode due key to missing '\(type)' value – \(context.debugDescription) Skipping item.", logLevel: logLevel)
                // hack to increment currentIndex
                _ = try self.decode(DummyCodable.self)
            } catch DecodingError.dataCorrupted(let context) {
                log("Failed to decode key because it appears to be invalid JSON – \(context.debugDescription) Skipping item.", logLevel: logLevel)
                // hack to increment currentIndex
                _ = try self.decode(DummyCodable.self)
            } catch {
                log("Failed to decode key - \(error.localizedDescription) Skipping item.", logLevel: logLevel)
                // hack to increment currentIndex
                _ = try self.decode(DummyCodable.self)
            }
        }
        return array
    }
    
    private func log(_ message: String, logLevel: EasyCodableLogLevel) {
        if logLevel == .debug {
            print(message)
        }
    }
}
