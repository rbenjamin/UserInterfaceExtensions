//
//  ComposeMailData.swift
//  Cookery
//
//  Created by Ben Davis on 6/5/25.
//

import Foundation

public struct ComposeMailData: Sendable, Identifiable, CustomStringConvertible, Equatable, Hashable {
    
    public var id: String {
        return subject
    }
    
    public var description: String {
        """
        TO: \(recipients ?? [])
        SUBJECT: \(subject)
        MESSAGE: \(message)
        """
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subject)
        hasher.combine(message)
        hasher.combine(attachments)
    }
    
    public static func ==(
        lhs: ComposeMailData,
        rhs: ComposeMailData
    ) -> Bool {
        
        lhs.subject == rhs.subject
        && lhs.message == rhs.message
        && lhs.attachments == rhs.attachments
    }
    
    public let subject: String
    public let recipients: [String]?
    public let message: String
    public let attachments: [AttachmentData]?
    
    public init(subject: String, recipients: [String]?, message: String, attachments: [AttachmentData]? = nil) {
        self.subject = subject
        self.recipients = recipients
        self.message = message
        self.attachments = attachments
    }
}
