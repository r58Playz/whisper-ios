// bomberfish
// fancyViewInputModifier.swift – Picasso
// created on 2023-12-08

import SwiftUI

// required for ios 14
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

public struct FancyInputViewModifier: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        Group {
            content
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? .white.opacity(0.2): Color.accentColor.opacity(0.4), lineWidth: 2)
                )
                .background(
                    Color.accentColor.opacity(colorScheme == .dark ?0.075:0.0)
                )

                .cornerRadius(12)
        }.background(colorScheme == .dark ? VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial)):VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))).cornerRadius(12)
    }
}
