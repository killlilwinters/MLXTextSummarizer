//
//  HapticFeedbackGenerator.swift
//  MLXTextSummarizer
//
//  Created by Maks Winters on 21.03.2025.
//

#if canImport(UIKit)
import UIKit

typealias HapticFeedbackGenerator = UINotificationFeedbackGenerator
typealias HapticFeedbackMockCases = UINotificationFeedbackGenerator.FeedbackType

#else

enum HapticFeedbackMockCases {
    case success, warning, error
}

final class HapticFeedbackGenerator {
    init() {}
    func notificationOccurred(_ notification: HapticFeedbackMockCases) { }
}
#endif
