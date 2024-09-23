//
//  EasyCodable+KeyedDecodingContainer.swift
//  EasyCodable
//
//  Created by Alex Nagy on 23.09.2024.
//

import Foundation

public extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ keys: [K], index: Int = 0, fallback: T? = nil, logLevel: EasyCodableLogLevel) -> T? {
        do {
            if index < keys.count - 1 {
                let value: T = try self.decode(T.self, forKey: keys[index])
                log("Decoded value for key `\(keys[index].stringValue)`: \(value)", logLevel: logLevel)
                return value
            } else {
                let value = try self.decodeIfPresent(T.self, forKey: keys[index])
                log("Decoded value for key `\(keys[index].stringValue)`: \(String(describing: value))", logLevel: logLevel)
                return value
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            log("Failed to decode due to missing key '\(key.stringValue)' not found – \(context.debugDescription)", logLevel: logLevel)
            return decode(keys, index: index + 1, fallback: fallback, logLevel: logLevel)
        } catch DecodingError.typeMismatch(let type, let context) {
            log("Failed to decode key '\(keys[index].stringValue)' due to type mismatch of type '\(type)' – \(context.debugDescription) Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return nil
        } catch DecodingError.valueNotFound(let type, let context) {
            log("Failed to decode key '\(keys[index].stringValue)' due to missing '\(type)' value – \(context.debugDescription) Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return nil
        } catch DecodingError.dataCorrupted(let context) {
            log("Failed to decode key '\(keys[index].stringValue)' because it appears to be invalid JSON – \(context.debugDescription) Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return nil
        } catch {
            log("Failed to decode key `\(keys[index].stringValue)`: \(error.localizedDescription) Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return nil
        }
    }
    
    func decode<T: Decodable>(_ keys: [K], index: Int = 0, fallback: [T]? = nil, logLevel: EasyCodableLogLevel) -> [T]? {
        do {
            if index <= keys.count - 1 {
                let value: [T] = try self.decodeArray(keys[index], logLevel: logLevel)
                log("Decoded value for key `\(keys[index].stringValue)`: \(value)", logLevel: logLevel)
                return value
            } else {
                log("Using fallback: \(String(describing: fallback))", logLevel: logLevel)
                return fallback
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            log("Failed to decode due to missing key '\(key.stringValue)' not found – \(context.debugDescription)", logLevel: logLevel)
            return decode<T>(keys, index: index + 1, fallback: fallback, logLevel: logLevel)
        } catch DecodingError.typeMismatch(let type, let context) {
            log("Failed to decode key '\(keys[index].stringValue)' due to type mismatch of type '\(type)' – \(context.debugDescription) Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return nil
        } catch DecodingError.valueNotFound(let type, let context) {
            log("Failed to decode key '\(keys[index].stringValue)' due to missing '\(type)' value – \(context.debugDescription) Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return nil
        } catch DecodingError.dataCorrupted(let context) {
            log("Failed to decode key '\(keys[index].stringValue)' because it appears to be invalid JSON – \(context.debugDescription) Using fallback: \(String(describing: fallback))", logLevel: logLevel)
            return nil
        } catch {
            log("Failed to decode key `\(keys[index].stringValue)`: \(error.localizedDescription) Using fallback: \(String(describing: keys))", logLevel: logLevel)
            return nil
        }
    }
    
    private func log(_ message: String, logLevel: EasyCodableLogLevel) {
        if logLevel == .debug {
            print(message)
        }
    }
}
