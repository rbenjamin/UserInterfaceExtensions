//
//  Hardware.swift
//  UserInterfaceExtensions
//
//  Created by Ben Davis on 12/18/25.
//


import SwiftUI


/// Use as a protocol on an enum that contains your keyboard shortcuts.
/// Provide the respective equivalent and modifiers within these variables, then  `enumeratedKeyboardShortcut(_:)` will connect the modified action (button, etc) directy to the shortcut provided.
public protocol ShortcutModifierKeyType {
    var keyEquivalent: KeyEquivalent { get }
    var modifiers: EventModifiers { get }
}

public struct EnumeratedShortcutModifier<KeyType: ShortcutModifierKeyType>: ViewModifier {
    let shortcut: KeyType
    
    public func body(content: Content) -> some View {
        content
            .keyboardShortcut(shortcut.keyEquivalent,
                              modifiers: shortcut.modifiers)
    }
}

extension View {
    public func enumeratedKeyboardShortcut<KeyType: ShortcutModifierKeyType>(_ shortcut: KeyType) -> some View {
        
        modifier(
            EnumeratedShortcutModifier(shortcut: shortcut)
        )
    }
}
