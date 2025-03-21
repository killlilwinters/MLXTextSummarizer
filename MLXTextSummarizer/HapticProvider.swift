//
//  HapticProvider.swift
//  MLXTextSummarizer
//
//  Created by Maks Winters on 21.03.2025.
//
import Foundation
import CoreHaptics

enum HapticError: Error {
    case deviceUnsupported
    case engineUnavailable
}

struct HapticProvider {
    private let engine: CHHapticEngine?
    private let eventGenerator = HapticFeedbackGenerator()
    
    init?() throws {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { throw HapticError.deviceUnsupported }
        
        guard let engine = try? CHHapticEngine() else { return nil }
        self.engine = engine
        do { try engine.start() } catch { throw error }
    }
    
    func performSuccess() {
        eventGenerator.notificationOccurred(.success)
    }
    
    func performLightTap() throws {
        guard let engine else { return }
        
        let parameters = [
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        ]
        
        var events = [CHHapticEvent]()
        for second in 1...3 {
            let timeInterval = Double(second / 5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: parameters, relativeTime: timeInterval)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            throw error
        }
        
    }
}
