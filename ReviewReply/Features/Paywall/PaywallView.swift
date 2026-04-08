import SwiftUI
import StoreKit

/// Native StoreKit 2 paywall — no third-party SDK.
struct PaywallView: View {

    let onDismiss: () -> Void
    let isOnboarding: Bool

    @Environment(StoreService.self) private var store
    @State private var purchaseError: String?
    @State private var selectedProduct: Product?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                // Background glow
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.07))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: -80, y: -200)

                ScrollView {
                    VStack(spacing: 28) {
                        heroSection
                        featuresSection
                        productCards
                        if let error = purchaseError {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(Theme.Colors.error)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 140)
                }

                // Sticky CTA
                VStack {
                    Spacer()
                    stickyButtons
                }
            }
            .toolbar {
                if !isOnboarding {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { onDismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .accessibilityLabel("Close")
                    }
                }
            }
        }
        .task {
            if store.products.isEmpty {
                await store.loadProducts()
            }
            // Default to annual if available
            selectedProduct = store.annualProduct ?? store.monthlyProduct
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "star.bubble.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.Gradients.aiGlow)
                .padding(.top, 24)

            Text("ReviewReply Pro")
                .font(.system(size: 30, weight: .heavy, design: .rounded))

            Text("Unlimited professional replies.\nNo daily limits.")
                .font(.system(size: 16))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features

    private let features: [(String, String)] = [
        ("Unlimited replies per day",     "infinity"),
        ("All response tones",            "slider.horizontal.3"),
        ("Full history access",           "clock"),
        ("Keyboard & Share extensions",   "keyboard"),
        ("Priority on-device processing", "bolt.fill")
    ]

    private var featuresSection: some View {
        VStack(spacing: 12) {
            ForEach(features, id: \.0) { label, icon in
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.Colors.primary)
                        .frame(width: 24)
                    Text(label)
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.label))
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.Colors.success)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Product Cards

    private var productCards: some View {
        VStack(spacing: 12) {
            ForEach(store.products) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    savingsLabel: product.id == StoreProducts.annual ? store.annualSavingsLabel : nil
                ) {
                    withAnimation(.spring(response: 0.25)) { selectedProduct = product }
                }
            }
        }
    }

    // MARK: - Sticky CTA

    private var stickyButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task { await purchaseSelected() }
            } label: {
                HStack(spacing: 8) {
                    if store.isLoading {
                        ProgressView().tint(.white).scaleEffect(0.85)
                    }
                    Text(store.isLoading ? "Processing…" : "Subscribe Now")
                }
            }
            .buttonStyle(PrimaryButtonStyle(isLoading: store.isLoading))
            .disabled(selectedProduct == nil || store.isLoading)

            HStack(spacing: 16) {
                if isOnboarding {
                    Button("Start Free — 1 Reply/Day") { onDismiss() }
                        .font(.footnote)
                        .foregroundStyle(Color(.secondaryLabel))
                } else {
                    Button("Maybe Later") { onDismiss() }
                        .font(.footnote)
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Button("Restore") {
                    Task {
                        do {
                            try await store.restorePurchases()
                            if store.isPremium { onDismiss() }
                        } catch {
                            purchaseError = "Restore failed. Please try again."
                        }
                    }
                }
                .font(.footnote)
                .foregroundStyle(Color(.secondaryLabel))
            }

            Text("Payment will be charged to your Apple ID. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                .font(.system(size: 10))
                .foregroundStyle(Color(.quaternaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }

    // MARK: - Purchase Logic

    private func purchaseSelected() async {
        guard let product = selectedProduct else { return }
        purchaseError = nil
        do {
            let success = try await store.purchase(product)
            if success { onDismiss() }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Product Card

private struct ProductCard: View {

    let product: Product
    let isSelected: Bool
    let savingsLabel: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Radio
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Theme.Colors.primary : Color(.systemFill), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Theme.Colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }

                // Details
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.label))
                        if let badge = savingsLabel {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Theme.Colors.success))
                        }
                    }
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(Color(.secondaryLabel))
                        .lineLimit(1)
                }

                Spacer()

                // Price
                Text(product.displayPrice)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isSelected ? Theme.Colors.primary : Color(.label))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                            .strokeBorder(
                                isSelected ? Theme.Colors.primary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView(onDismiss: {}, isOnboarding: true)
        .environment(StoreService.shared)
}
