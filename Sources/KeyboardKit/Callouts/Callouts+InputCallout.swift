//
//  Callouts+InputCallout.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2025 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension Callouts {

    /// This callout can show the currenly pressed key, when
    /// typing on an iPhone.
    ///
    /// This callout will adjust the button corner radius to
    /// fit the style's or the keyboard layout configuration.
    struct InputCallout: View {
        
        /// Create a custom input callout.
        ///
        /// - Parameters:
        ///   - calloutContext: The callout context to use.
        ///   - keyboardContext: The keyboard context to use.
        public init(
            calloutContext: CalloutContext,
            keyboardContext: KeyboardContext
        ) {
            self._calloutContext = .init(wrappedValue: calloutContext)
            self._keyboardContext = .init(wrappedValue: keyboardContext)
        }
        
        @ObservedObject
        private var calloutContext: CalloutContext

        @ObservedObject
        private var keyboardContext: KeyboardContext
        
        @Environment(\.keyboardCalloutStyle)
        private var style

        public var body: some View {
            if style.isFloating {
                floatingBody
            } else {
                balloonBody
            }
        }
    }
}

private extension Callouts.InputCallout {

    var balloonBody: some View {
        VStack(spacing: 0) {
            calloutBubble.offset(y: 1)
            calloutButton
        }
        .compositingGroup()
        .opacity(isActive ? 1 : 0)
        .keyboardCalloutShadow(style: style)
        .position(position)
        .allowsHitTesting(false)
    }

    /// The iOS 27 callout: a bubble that floats above the key, with no
    /// stem, so the pressed key itself stays visible.
    var floatingBody: some View {
        GeometryReader { geo in
            let frame = floatingFrame(in: geo.size)
            Text(calloutContext.inputAction?.inputCalloutText ?? "")
                .font(style.inputItemFont.font)
                .foregroundColor(style.foregroundColor)
                .frame(width: frame.width, height: frame.height)
                .background(
                    FloatingCalloutBackground(
                        style: style,
                        cornerRadius: style.floatingInputCornerRadius
                    )
                )
                .opacity(isActive ? 1 : 0)
                .position(x: frame.midX, y: frame.midY)
        }
        .allowsHitTesting(false)
    }

    var floatingPreferredSize: CGSize {
        let adjustment = style.floatingInputSizeAdjustment
        let width = max(style.inputItemMinSize.width, buttonSize.width + adjustment.width)
        let height = shouldEnforceSmallSize ? buttonSize.height : buttonSize.height + adjustment.height
        return CGSize(width: width, height: height)
    }

    /// Centered above the key, but kept inside the keyboard. Native iOS 27
    /// callouts may extend above the keyboard, but a keyboard extension is
    /// clipped to its own view, so the top row gets a shorter bubble.
    func floatingFrame(in container: CGSize) -> CGRect {
        let preferred = floatingPreferredSize
        let available = buttonFrame.minY - style.floatingGap
        let height = max(min(preferred.height, available), buttonSize.height)
        let midX = buttonFrame.midX.clampedForCallout(width: preferred.width, in: container.width)
        return CGRect(
            x: midX - preferred.width / 2,
            y: buttonFrame.minY - style.floatingGap - height,
            width: preferred.width,
            height: height
        )
    }
}

extension CGFloat {

    /// Clamp a callout's center x so that the callout stays within a
    /// container of the provided width. Like iOS 27, an edge callout is
    /// pinned flush to the keyboard edge.
    func clampedForCallout(width: CGFloat, in containerWidth: CGFloat, margin: CGFloat = 0) -> CGFloat {
        let minX = width / 2 + margin
        let maxX = containerWidth - width / 2 - margin
        guard containerWidth > 0, minX <= maxX else { return self }
        return Swift.min(Swift.max(self, minX), maxX)
    }
}

private extension Callouts.InputCallout {

    var calloutBubble: some View {
        Text(calloutContext.inputAction?.inputCalloutText ?? "")
            .font(style.inputItemFont.font)
            .frame(minWidth: calloutSize.width, minHeight: calloutSize.height)
            .foregroundColor(style.foregroundColor)
            .background(style.backgroundColor)
            .cornerRadius(style.cornerRadius)
    }
    
    var calloutButton: some View {
        ButtonArea(
            frame: buttonFrame,
            buttonCornerRadius: style.buttonCornerRadius(for: keyboardContext)
        )
    }
}

private extension Callouts.InputCallout {

    var isActive: Bool {
        isEnabled && calloutContext.inputAction != nil
    }

    var isEnabled: Bool {
        keyboardContext.deviceTypeForKeyboard == .phone
    }

    var shouldEnforceSmallSize: Bool {
        keyboardContext.deviceTypeForKeyboard == .phone && keyboardContext.interfaceOrientation.isLandscape
    }
}

private extension Callouts.InputCallout {

    var buttonFrame: CGRect {
        let inset = style.buttonOverlayInset
        let frame = calloutContext.buttonFrame
            .insetBy(dx: inset.width, dy: inset.height)
        // Before the first press the context frame is .zero, and insetting
        // it gives CGRect.null (origin +infinity). Placing the callout at
        // infinity breaks its layer on iOS 27, so use an empty rect instead.
        return frame.isNull || frame.isInfinite ? .zero : frame
    }
    
    var buttonSize: CGSize {
        buttonFrame.size
    }
    
    var calloutSize: CGSize {
        CGSize(
            width: calloutSizeWidth,
            height: calloutSizeHeight
        )
    }
    
    var calloutSizeHeight: CGFloat {
        let smallSize = buttonSize.height
        let calloutSize = style.inputItemMinSize
        return shouldEnforceSmallSize ? smallSize : calloutSize.height
    }
    
    var calloutSizeWidth: CGFloat {
        let totalCurveSize = 2 * style.curveSize.width
        let minSize = buttonSize.width + totalCurveSize + style.cornerRadius
        let calloutSize = style.inputItemMinSize
        return max(calloutSize.width, minSize)
    }

    var position: CGPoint {
        CGPoint(x: positionX, y: positionY)
    }

    var positionX: CGFloat {
        buttonFrame.origin.x + buttonSize.width/2
    }

    var positionY: CGFloat {
        let base = buttonFrame.origin.y + buttonSize.height/2 - calloutSize.height/2
        let isEmoji = calloutContext.inputAction?.isEmojiAction == true
        if isEmoji { return base + 5 }
        return base
    }
}


// MARK: - Previews

#if os(iOS) || os(macOS) || os(watchOS)
#Preview {

    struct Preview: View {

        @StateObject
        var context = CalloutContext()

        func button(for context: CalloutContext) -> some View {
            GeometryReader { geo in
                GestureButton(
                    pressAction: { showCallout(for: geo) },
                    endAction: context.resetInputActionWithDelay,
                    label: { _ in Color.red.cornerRadius(5) }
                )
                .onAppear { showCallout(for: geo) }
            }
            .frame(width: 40, height: 40)
            .padding()
            .background(Color.yellow.cornerRadius(6))
        }

        func showCallout(for geo: GeometryProxy) {
            context.updateInputAction(.character("a"), in: geo)
        }

        var buttonStack: some View {
            HStack {
                button(for: context)
                button(for: context)
                button(for: context)
            }
        }

        var body: some View {
            VStack {
                buttonStack
                buttonStack
                Button("Reset") {
                    context.resetInputAction()
                }
            }
            .keyboardInputCalloutContainer(
                calloutContext: context,
                keyboardContext: .preview
            )
        }
    }

    return Preview()
        .keyboardCalloutStyle(.init(
            backgroundColor: .blue,
            foregroundColor: .yellow,
            inputItemFont: KeyboardFont.largeTitle.weight(.bold)
        ))
}
#endif
