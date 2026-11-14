//
//  FloatingCalloutBackground.swift
//  KeyboardKit
//
//  The iOS 27 callout surface: a detached, continuous rounded rectangle
//  with a soft top-to-bottom sheen, a hairline rim and a light shadow.
//

import SwiftUI

struct FloatingCalloutBackground: View {

    let style: Callouts.CalloutStyle
    let cornerRadius: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        shape
            .fill(style.backgroundColor)
            .overlay(
                shape.fill(
                    LinearGradient(
                        colors: [.white.opacity(0), .white.opacity(0.09)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .overlay(shape.strokeBorder(style.borderColor, lineWidth: 0.5))
            .shadow(color: style.shadowColor, radius: style.shadowRadius, y: 1)
    }
}
