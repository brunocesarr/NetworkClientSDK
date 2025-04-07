//
//  String+Extension.swift
//  NetworkClientSDK
//
//  Created by dtidigital on 4/7/25.
//

public extension String {
    func removeSlashesAtEnd() -> String {
        var modifiedString = self
        while modifiedString.hasSuffix("/") {
            modifiedString.removeLast()
        }
        return modifiedString
    }

    func removeSlashesAtStart() -> String {
        var modifiedString = self
        while modifiedString.hasPrefix("/") {
            modifiedString.removeFirst()
        }
        return modifiedString
    }
}
