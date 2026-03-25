//
//  AttachmentData.swift
//  Cookery
//
//  Created by Ben Davis on 6/5/25.
//


import Foundation

fileprivate extension Int {
    var byteSize: String {
        return ByteCountFormatter().string(fromByteCount: Int64(self))
    }
}


public struct AttachmentData: Sendable, CustomStringConvertible, Equatable, Hashable {
    public let data: Data
    public let mimeType: String
    public let fileName: String
    
    public static func ==(lhs: AttachmentData, rhs: AttachmentData) -> Bool {
        return lhs.data == rhs.data && lhs.fileName == rhs.fileName
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
        hasher.combine(fileName)
    }
    
    public var description: String {
        """
        AttachmentData:
        SIZE: \(data.count.byteSize)
        MIME-TYPE: \(mimeType)
        """
    }
    
    public init(data: Data, mimeType: String, fileName: String) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }
}

