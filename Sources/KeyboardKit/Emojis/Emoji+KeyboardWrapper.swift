//
//  Emoji+KeyboardWrapper.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2023-10-26.
//  Copyright © 2023-2025 Daniel Saidi. All rights reserved.
//

import SwiftUI
import ISEmojiView

public extension Emoji {

    struct KeyboardWrapper: View {
        
        let actionHandler: KeyboardActionHandler
        let keyboardContext: KeyboardContext
        let calloutContext: CalloutContext?
        let styleService: KeyboardStyleService
        
        init(
            actionHandler: KeyboardActionHandler,
            keyboardContext: KeyboardContext,
            calloutContext: CalloutContext?,
            styleService: KeyboardStyleService
        ) {
            self.actionHandler = actionHandler
            self.keyboardContext = keyboardContext
            self.calloutContext = calloutContext
            self.styleService = styleService
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
                    actionHandler.handle(.keyboardType(.alphabetic))
                },
                didPressDeleteBackward: {
                    actionHandler.handle(.backspace)
                },
                dDidPressDismissKeyboard: {
                    actionHandler.handle(.dismissKeyboard)
                }
            )
        }
        
        static var isEmptyPlaceholder: Bool { false }
    }
}
