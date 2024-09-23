//
//  EasyCodable+KeyedDecodingContainerProtocol.swift
//  EasyCodable
//
//  Created by Alex Nagy on 23.09.2024.
//

import Foundation

public extension KeyedDecodingContainerProtocol {
    func decodeArray<T>(_ key: Self.Key, logLevel: EasyCodableLogLevel) throws -> [T] where T : Decodable {
        var unkeyedContainer = try self.nestedUnkeyedContainer(forKey: key)
        return try unkeyedContainer.decodeArray(logLevel: logLevel)
    }
}
