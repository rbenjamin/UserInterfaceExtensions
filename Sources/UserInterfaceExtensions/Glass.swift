//
//  Glass.swift
//  UserInterfaceExtensions
//
//  Created by Ben Davis on 12/17/25.
//

import SwiftUI


/// ViewModifier to group views with `GlassEffectContainer` if OS 26 is available on the target.
struct ContainedInGlassIfAvailable: ViewModifier {
    
    let spacing: CGFloat?
    
    init(spacing: CGFloat? = nil) {
        self.spacing = spacing
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }
}

extension View {
    
    /// Groups the modified view in the `GlassEffectContainer` if supported on the target device.
    /// - Parameter spacing: The spacing argument to be used for `GlassEffectContainer`. Defaults to nil.
    /// - Returns: Modified view.
    public func containedInGlassIfAvailable(spacing: CGFloat? = nil) -> some View {
        modifier(ContainedInGlassIfAvailable(spacing: spacing))
    }
}

/// ViewModifier to set `ButtonStyle` to `.glass` if OS 26 is available on the target.
///
/// Otherwise, if prominent is true, the button retains iOS 18 style while also emphasizing the button. with `Color.accentColor`
struct GlassButtonIfAvailable: ViewModifier {
    
    let prominent: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, visionOS 26, *) {
            if prominent {
                content
                    .buttonStyle(.glassProminent)
            } else {
                content
                    .buttonStyle(.glass)
            }
        } else if prominent {
            content
                .buttonStyle(.borderless)
                .foregroundStyle(Color.white)
                .tint(Color.white)
            #if os(iOS)
                .padding(
                    EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
                )
            #else
                .padding(8)
            #endif
                .background(alignment: .center) {
                    Color.accentColor.clipShape(.capsule)
                }
        } else {
            content
                .buttonStyle(.borderless)
        }
    }
}

/// Uses a glass effect (OS 26) if iOS 26 is installed on the target device. Supports a replacement shape for pre-26 views.
public struct GlassEffectIfAvailable<S: Shape>: ViewModifier {
    
    public indirect enum AvailableGlass {
        case clear
        case identity
        case regular
        case tint(base: AvailableGlass, color: Color)
        case interactive(base: AvailableGlass, isEnabled: Bool)
        
        
        /// Called on the enum when iOS 26 is available on the target.
        /// - Returns: The actual `Glass` to use.
        @available(iOS 26, macOS 26, watchOS 26, visionOS 26, *)
        fileprivate func realGlass() -> Glass {
            switch self {
            case .clear:
                return Glass.clear
            case .identity:
                return Glass.identity
            case .regular:
                return Glass.regular
            case .tint(let base, let color):
                switch base {
                    case .clear:
                    return Glass.clear.tint(color)
                    case .identity:
                    return Glass.identity.tint(color)
                    case .regular:
                    return Glass.regular.tint(color)
                    default:
                    return Glass.regular.tint(color)
                }
            case .interactive(let base, let isEnabled):
                switch base {
                    case .clear:
                    return Glass.clear.interactive(isEnabled)
                    case .identity:
                    return Glass.identity.interactive(isEnabled)
                    case .regular:
                    return Glass.regular.interactive(isEnabled)
                    default:
                    return Glass.regular.interactive(isEnabled)
                }
            }
        }
    }
    
    /// Hidden ViewModifier that is used when the target is on OS 26.
    @available(iOS 26, macOS 26, watchOS 26, visionOS 26, *)
    struct RealGlassModifier: ViewModifier {
        let glass: Glass
        let shape: S
        
        func body(content: Content) -> some View {
            content
                .glassEffect(glass, in: shape)
        }
    }
    
    let glass: AvailableGlass
    let shape: S
    let replacement: AnyShapeStyle?
    
    public init(glass: AvailableGlass, shape: S, replacement: AnyShapeStyle?) {
        self.glass = glass
        self.shape = shape
        self.replacement = replacement
    }
    
    public func body(content: Content) -> some View {
        content
            .modify { view in
                if #available(iOS 26, macOS 26, *) {
                    view
                        .glassEffect(glass.realGlass(), in: shape)
                } else {
                    view
                        .background {
                            if let replacement {
                                shape.fill(replacement)
                            }
                        }
                }
            }
    }
}

extension View {
    
    
    /// Modifies the view with the specified `glass` effect, if it is available on the target. If not, `replacement` is used to fill `shape`.
    /// - Parameters:
    ///   - glass: The `Glass` to use.  Can be chained.
    ///   - shape: The shape to be used. If glass effects are unavailable, `shape` is filled with the `replacement` specified.
    ///   - replacement: The replacement `Color` use if the target is on an earlier OS release. Can be nil.
    /// - Returns: Modified view.
    /// - Note: Only use chains for the `glass` argument that are accepted by the `glassEffect(_ glass: in shape:)` view function.
    public func glassEffectIfAvailable<S: Shape>(
        _ glass: GlassEffectIfAvailable<S>.AvailableGlass,
        shape: S,
        replacement: Color?
    ) -> some View {
        modifier(
            GlassEffectIfAvailable(
                glass: glass,
                shape: shape,
                replacement: replacement != nil ? AnyShapeStyle(replacement!) : nil)
        )
    }
    
    /// Modifies the view with the specified `glass` effect, if it is available on the target. If not, `replacement` `Material` is used to fill `shape`.
    /// - Parameters:
    ///   - glass: The `Glass` to use.  Can be chained.
    ///   - shape: The shape to be used. If glass effects are unavailable, `shape` is filled with the `replacement` material specified.
    ///   - replacement: The replacement `Material` use if the target is on an earlier OS release. Can be nil.
    /// - Returns: Modified view.
    /// - Note: Only use chains for the `glass` argument that are accepted by the `glassEffect(_ glass: in shape:)` view function.
    public func glassEffectIfAvailable<S: Shape>(
        _ glass: GlassEffectIfAvailable<S>.AvailableGlass,
        shape: S,
        replacement: Material?) -> some View {
        modifier(
            GlassEffectIfAvailable(
                glass: glass,
                shape: shape,
                replacement: replacement != nil ? AnyShapeStyle(replacement!) : nil)
        )
    }
    
    /// Modifies the view with the specified `glass` effect, if it is available on the target. If not, `replacement` is used to fill `shape`. Wrap `replacement` with `AnyShapeStyle` to use a custom fill.
    /// - Parameters:
    ///   - glass: The `Glass` to use.  Can be chained.
    ///   - shape: The shape to be used. If glass effects are unavailable, `shape` is filled with the `replacement` specified.
    ///   - replacement: The replacement `AnyShapeStyle` use if the target is on an earlier OS release. Can be nil.
    /// - Returns: Modified view.
    /// - Note: Only use chains for the `glass` argument that are accepted by the `glassEffect(_ glass: in shape:)` view function.
    public func glassEffectIfAvailable<S: Shape>(
        _ glass: GlassEffectIfAvailable<S>.AvailableGlass,
        shape: S,
        replacement: AnyShapeStyle?) -> some View {
        modifier(
            GlassEffectIfAvailable(
                glass: glass,
                shape: shape,
                replacement: replacement)
        )
    }
    
    
    /// Modifies a button to use `.glass` or `.glassProminent` if available.
    /// - Parameter prominent: Whether to mark the button as `.glassProminent`
    /// - Returns: Modified view.
    /// - Note: If `prominent` is true and the target device is pre-26, the button will be backed with Color.accentColor clipped to a Capsule.
    public func glassButtonIfAvailable(
        prominent: Bool = false
    ) -> some View {
        modifier(
            GlassButtonIfAvailable(prominent: prominent)
        )
    }
}

// MARK: - Glass Presets -

/// Adds a glass effect with padding to a label.
extension Label {
    
    
    /// Adds `Glass` effect behind specified label.
    /// - Parameter padding: Optional padding argument. Defaults to a preset padding argument.
    /// - Returns: Modified view.
    @available(iOS 26, macOS 26, watchOS 26, visionOS 26, *)
    public func glassLabel(
        padding: EdgeInsets = EdgeInsets(
            top: 4,
            leading: 6,
            bottom: 4,
            trailing: 6
        )
    ) -> some View {
        self
            .padding(padding)
            .glassEffect(.clear, in: .capsule)

    }
}

/// Adds a glass effect with padding to a text view.
extension Text {
    /// Adds `Glass` effect behind specified label.
    /// - Parameter padding: Optional padding argument. Defaults to a preset padding argument.
    /// - Returns: Modified view.
    @available(iOS 26, macOS 26, watchOS 26, visionOS 26, *)
    public func glassLabel(
        padding: EdgeInsets = EdgeInsets(
            top: 4,
            leading: 6,
            bottom: 4,
            trailing: 6
        )
    ) -> some View {
        self
            .padding(padding)
            .glassEffect(.clear, in: .capsule)

    }
}
