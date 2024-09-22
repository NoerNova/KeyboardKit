//
//  Emoji+KeyboardWrapper.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-10-26.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI
import ISEmojiView

public extension Emoji {
    
    /// This view is used as a keyboard emoji view eraser to
    /// ensure that the view is only used for valid licenses.
    struct KeyboardWrapper: View {
        
        let actionHandler: KeyboardActionHandler
        let keyboardContext: KeyboardContext
        let calloutContext: CalloutContext?
        let styleProvider: KeyboardStyleProvider
        
        init(
            actionHandler: KeyboardActionHandler,
            keyboardContext: KeyboardContext,
            calloutContext: CalloutContext?,
            styleProvider: KeyboardStyleProvider
        ) {
            self.actionHandler = actionHandler
            self.keyboardContext = keyboardContext
            self.calloutContext = calloutContext
            self.styleProvider = styleProvider
        }
        
        public var body: some View {
            EmojiView_SwiftUI(
                needToShowAbcButton: true,
                needToShowDeleteButton: true,
                updateRecentEmojiImmediately: true,
                didSelect: { emoji in
                    let action = KeyboardAction.emoji(emoji)
                    actionHandler.handle(action)
                },
                didPressChangeKeyboard: {
                    actionHandler.handle(.keyboardType(.alphabetic(.lowercased)))
                },
                didPressDeleteBackward: {
                    actionHandler.handle(.backspace)
                },
                dDidPressDismissKeyboard: {
                    actionHandler.handle(.dismissKeyboard)
                }
            )
        }
        
        static let isEmojiKeyboardAvailable = true
    }
}
