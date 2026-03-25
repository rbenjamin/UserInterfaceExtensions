//
//  AttributedString+Extended.swift
//  UserInterfaceExtensions
//
//  Created by Ben Davis on 1/26/26.
//

import Foundation

extension AttributedString {
    @inlinable
    func range(
        from range: Range<String.Index>
    ) -> Range<AttributedString.Index>? {
        guard let startIndex = AttributedString.Index(
            range.lowerBound,
            within: self
        ),
        let endIndex = AttributedString.Index(
            range.upperBound,
            within: self
        )
        else {
            return nil
        }
        
        return startIndex ..< endIndex
    }

}
