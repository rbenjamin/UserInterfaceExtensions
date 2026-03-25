//
//  Basics.swift
//  UserInterfaceExtensions
//
//  Created by Ben Davis on 12/17/25.
//

import SwiftUI

// MARK: - Modify -
extension View {
    
    
    /// Wraps the view with a modifier which allows for additional calculation.
    /// - Parameter modifier: The custom modified content.
    /// - Returns: Specified view.
    /// - Example:
    ///
    ///             Button("Done") {
    ///                 dismiss()
    ///             }
    ///             .modify { view in
    ///                 if #available(iOS 26, macOS 26, *) {
    ///
    ///                     view
    ///                         .buttonStyle(.glass)
    ///                 } else {
    ///                     view
    ///                         .buttonStyle(.borderless)
    ///                 }
    ///             }
    ///
    public func modify<T: View>(
        @ViewBuilder _ modifier: (Self) -> T
    ) -> some View {
        return modifier(self)
    }
}

// MARK: - Geometry Reader Convenience -
@MainActor
struct SizePreferenceKey: @preconcurrency PreferenceKey {
    static var defaultValue: CGSize = .zero
    nonisolated static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

@MainActor
struct GreatestWidthKey: @preconcurrency PreferenceKey {
    static let defaultValue: CGFloat = 0.0
    nonisolated static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      value = nextValue()
    }
}


extension Text {
    
    /// Retrieves the size of a text label.
    /// - Parameter onChange: The new label size.
    /// - Returns: Modified view.
    /// - Warning: Uses `GeometryReader`. Use carefully in complex layouts.
    public func readSize(
        onChange: @escaping @Sendable (CGSize) -> Void
    ) -> some View {
      background(
        GeometryReader { geometryProxy in
          Color.clear
            .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            .onPreferenceChange(SizePreferenceKey.self, perform: { newValue in
                Task { @MainActor in
                    onChange(newValue)
                }
            })
        }
        .hidden()

      )
     
    }
}

extension View {

    /// Retrieves the size of a view.
    /// - Parameter onChange: The new label size.
    /// - Returns: Modified view.
    /// - Warning: Uses `GeometryReader`. Use carefully in complex layouts.
    public func readSize(
        onChange: @escaping (CGSize) -> Void
    ) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size)
                    .onPreferenceChange(
                        SizePreferenceKey.self
                    ) { newValue in
                        Task { @MainActor in
                            onChange(newValue)
                        }
                    }
            }
            .hidden()
      )
  }
}



// MARK: - On Appear (Once) -
/// ViewModifier to run a .task modifier only once per application lifecycle.
public struct OnFirstAppearModifier: ViewModifier {

    private let onFirstAppearAction: () -> ()
    @State private var hasAppeared = false
    
    public init(_ onFirstAppearAction: @escaping () -> ()) {
        self.onFirstAppearAction = onFirstAppearAction
    }
    
    public func body(content: Content) -> some View {
        content
            .task {
                guard !hasAppeared else { return }
                hasAppeared = true
                onFirstAppearAction()
            }
    }
}

extension View {
    
    /// Runs the closure `onFirstAppearAction` one time  when the view is loaded.  Anything that causes a View's @State properties to be reset will also cause the modifier to run again.
    /// - Parameter onFirstAppearAction: Closure to run once, on appear.
    /// - Returns: Modified view.
    public func onFirstAppear(
        _ onFirstAppearAction: @escaping () -> ()
    ) -> some View {
        return modifier(OnFirstAppearModifier(onFirstAppearAction))
    }
}


// MARK: - Platform Modifiers -

/// Modifiers to only run specific code on a chosen platform.
extension View {
    
    public func iOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    public func macOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    // MARK: - View Frame sizes -
    @inlinable
    public func infiniteMaxFrame() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    @inlinable
    public func infiniteMaxWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }
    @inlinable
    public func infiniteMaxHeight() -> some View {
        self.frame(maxHeight: .infinity)
    }
    
    // MARK: - Animation Presets -
    @inlinable
    public func withFastEaseInAnimation<Result>(
        _ animation: Animation? = .easeIn(duration: 0.20),
        _ body: () throws -> Result
    ) rethrows -> Result {
        return try withAnimation(animation, body)
    }
    
    public func withInterpolatingSpringAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
        return try withAnimation(Animation.interpolatingSpring(mass: 0.960, stiffness: 91, damping: 36, initialVelocity: 16), body)
    }
    
    @inlinable
    public func withFastEaseInAnimation<Result>(
        _ animation: Animation? = .easeIn(duration: 0.20),
        completionCriteria: AnimationCompletionCriteria = .logicallyComplete,
        _ body: () throws -> Result,
        completion: @escaping () -> Void
    ) rethrows -> Result {
        return try withAnimation(animation,
                                 completionCriteria: completionCriteria,
                                 body,
                                 completion: completion)
    }
    
    /// Ensures animation only runs on iOS platforms.
    @inlinable
    @discardableResult
    public func withAnimationDisabledOnMacOS<Result>(
            _ animation: Animation? = .easeIn,
            _ body: () throws -> Result
    ) rethrows -> Result {
                
                #if os(macOS)
                return try body()
                #else
                return try withAnimation(animation, body)
                #endif
    }
    
    /// Ensures animation only runs on iOS platforms.
    @inlinable
    @discardableResult
    public func withAnimationDisabledOnMacOS<Result>(
            _ animation: Animation? = .easeIn,
            completionCriteria: AnimationCompletionCriteria = .logicallyComplete,
            _ body: () throws -> Result,
            completion: @escaping () -> Void
    ) rethrows -> Result {
                
                #if os(macOS)
                return try body()
                #else
                return try withAnimation(animation,
                                         completionCriteria: completionCriteria,
                                         body,
                                         completion: completion)
                #endif
    }
}
