import Foundation
import StoreKit
import Observation

// MARK: - Product IDs

enum StoreProducts {
    static let monthly = "com.reviewreply.monthly"
    static let annual  = "com.reviewreply.annual"
    static let allIDs: Set<String> = [monthly, annual]
}

// MARK: - Store Service (Pure StoreKit 2)

@MainActor
@Observable
final class StoreService {

    static let shared = StoreService()

    // MARK: - Published State

    var products: [Product]           = []
    var isPremium: Bool               = false
    var purchasedProductIDs: Set<String> = []
    var isLoading: Bool               = false

    // MARK: - Init

    private init() {
        listenForTransactions()
        Task { await refreshState() }
    }

    // MARK: - Transaction Listener (MUST run from app launch)

    private func listenForTransactions() {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(transactionResult: result)
            }
        }
    }

    // MARK: - Handle Verified / Unverified

    @discardableResult
    private func handle(transactionResult result: VerificationResult<Transaction>) async -> Transaction? {
        switch result {
        case .unverified(let tx, let error):
            print("[StoreService] Unverified tx \(tx.id): \(error)")
            return nil
        case .verified(let tx):
            await grantEntitlement(for: tx)
            await tx.finish()
            return tx
        }
    }

    // MARK: - Grant / Revoke

    private func grantEntitlement(for transaction: Transaction) async {
        if transaction.revocationDate == nil
            && (transaction.expirationDate.map { $0 > Date() } ?? true) {
            purchasedProductIDs.insert(transaction.productID)
        } else {
            purchasedProductIDs.remove(transaction.productID)
        }
        isPremium = !purchasedProductIDs.isEmpty
    }

    // MARK: - Refresh All State (call on foreground / launch)

    func refreshState() async {
        await loadProducts()
        await refreshEntitlements()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: StoreProducts.allIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("[StoreService] Failed to load products: \(error)")
        }
    }

    func refreshEntitlements() async {
        var ids: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.revocationDate == nil,
               tx.expirationDate.map({ $0 > Date() }) ?? true {
                ids.insert(tx.productID)
            }
        }
        purchasedProductIDs = ids
        isPremium = !ids.isEmpty
    }

    // MARK: - Purchase

    /// Returns true if purchase succeeded, false if cancelled/pending.
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let tx = await handle(transactionResult: verification)
            return tx != nil
        case .pending:
            // Ask to Buy / SCA — don't grant yet, will arrive via Transaction.updates
            return false
        case .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Helpers

    var monthlyProduct: Product? { products.first { $0.id == StoreProducts.monthly } }
    var annualProduct: Product?  { products.first { $0.id == StoreProducts.annual } }

    /// Computed annual savings string like "Save 50%"
    var annualSavingsLabel: String? {
        guard let monthly = monthlyProduct, let annual = annualProduct,
              monthly.price > 0 else { return nil }
        let monthlyPerYear = NSDecimalNumber(decimal: monthly.price).multiplying(by: 12)
        let annualPrice = NSDecimalNumber(decimal: annual.price)
        let diff = monthlyPerYear.subtracting(annualPrice)
        let ratio = diff.dividing(by: monthlyPerYear)
        let pct = ratio.doubleValue * 100
        guard pct > 0 else { return nil }
        return "Save \(Int(pct.rounded()))%"
    }
}
