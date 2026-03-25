//
//  Formatters.swift
//  UserInterfaceExtensions
//
//  Created by Ben Davis on 1/26/26.
//

import Foundation
import SwiftUI
/// Adds SwiftUI-Compatable-AttributedString to Formatters
///

public extension MeasurementFormatter {
    
    func attributedString(
        from measurement: Measurement<Dimension>,
        container: AttributeContainer) -> AttributedString? {
            let string = self.string(from: measurement)
            var result = AttributedString(string)
            if let stringRange = string.range(
                of: #"\d+"#,
                options: [.anchored, .regularExpression]
            ), let attrRange = result.range(from: stringRange) {
                result[attrRange].setAttributes(container)
            }
            
            return result
        }
}
