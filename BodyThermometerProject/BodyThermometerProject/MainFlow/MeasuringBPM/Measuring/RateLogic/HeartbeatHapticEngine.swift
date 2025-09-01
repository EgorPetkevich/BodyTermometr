//
//  HeartbeatHapticEngine.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import CoreHaptics

class HeartbeatHapticEngine {
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine Creation Error: \(error)")
        }
    }

    func playHeartbeat() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 1.0),
                    .init(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            ),

            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.7),
                    .init(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.12
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play heartbeat haptic: \(error)")
        }
    }

    func stop() {
        engine?.stop(completionHandler: nil)
    }
}
