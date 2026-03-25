//
//  Animations.swift
//  UserInterfaceExtensions
//
//  Created by Ben Davis on 12/17/25.
//
import SwiftUI
import Foundation

// MARK: - Scale Keyframe Animation -

/// Scales a view down when triggered, then back to its' original size. Set `scaleValues` to override default behavior and change the sizing during the animation.
/// - Parameters:
///   - trigger: The trigger for the animation. Equatable.
///   - scaleValues: The scale values to use. Optional. Default values will be used if omitted.
///   - startVelocity: The initial velocity.
public struct ScaleKeyframeAnimator<Trigger: Equatable & Sendable>: ViewModifier {
    
    private struct KeyframeScale {
        var scale: CGFloat = 1.0
    }
    
    public struct ScaleValue {
        let scale: CGFloat
        let duration: CGFloat
        
        public init(_ scale: CGFloat, duration: CGFloat) {
            self.scale = scale
            self.duration = duration
        }
    }
    
    let trigger: Trigger
    
    let scaleValues: [ScaleValue]
    let startVelocity: CGFloat?
    
    public init(trigger: Trigger, scaleValues: [ScaleValue], startVelocity: CGFloat? = nil) {
        self.trigger = trigger
        self.scaleValues = scaleValues
        self.startVelocity = startVelocity
       
    }
    
    public func body(content: Content) -> some View {
        content
            .keyframeAnimator(initialValue: KeyframeScale(),
                              trigger: trigger) { content, value in
                content
                    .scaleEffect(value.scale)
        
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    for value in scaleValues {
                        CubicKeyframe(value.scale,
                                       duration: value.duration, startVelocity: startVelocity)
                    }
                }
            }
    }
}

extension View {
    /// Scales a view down when triggered, then back to its' original size. Set `scaleValues` to override default behavior and change the sizing during the animation.
    /// - Parameters:
    ///   - trigger: The trigger for the animation. Equatable.
    ///   - scaleValues: The scale values to use. Optional. Default values will be used if omitted.
    ///   - startVelocity: The initial velocity.
    public func scaledKeyframeAnimator<Trigger: Equatable & Sendable>(
        trigger: Trigger,
        scaleValues: [
            ScaleKeyframeAnimator<Trigger>.ScaleValue
        ] = [
            .init(0.80, duration: 0.10),
                .init(1.0, duration: 0.10)
        ],
        startVelocity: CGFloat? = nil
    ) -> some View {
        modifier(
            ScaleKeyframeAnimator(
                trigger: trigger,
                scaleValues: scaleValues,
                startVelocity: startVelocity)
        )
    }
}

// MARK: - Bounce (Scale Up) Animation -


/// Does not use KeyframeAnimator (old style of animation before keyframeAnimator existed).
struct BounceAnimateViewModifier<Trigger: Equatable>: ViewModifier  {
    let trigger: Trigger
    @State private var scale = 1.0
    
    let animationCurve = Animation.interpolatingSpring(mass: 0.960, stiffness: 91, damping: 36, initialVelocity: 16)
    let speed: Double
    let scaleMaximumValue: CGFloat

    init(trigger: Trigger,
         scaleMax: CGFloat = 8.0,
         speed: Double = 2.5) {
        self.trigger = trigger
        
        self.scaleMaximumValue = scaleMax
        self.speed = speed
    }
    
    func body(content: Content) -> some View  {
        
        content
            .scaleEffect(scale)
            .animation(animationCurve.speed(speed), value: scale)
            .onChange(of: trigger) { _, newValue in
                scale = scaleMaximumValue
            }
            .onChange(of: scale) { _, newValue in
                scale = 1.0
            }
    }
}


extension View {
    
    /// Adds a scale animation to a view.
    /// - Parameters:
    ///   - trigger: The trigger for the animation. Must be Equatable.
    ///   - scaleMax: The maximum scale for the animation.
    /// - Returns: Modified view.
    public func bounce<Trigger: Equatable>(
        trigger: Trigger,
        scaleMax: CGFloat = 4
    ) -> some View {
        modifier(
            BounceAnimateViewModifier(
                trigger: trigger,
                scaleMax: scaleMax
            )
        )
    }
}
