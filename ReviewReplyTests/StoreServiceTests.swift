import Testing
@testable import ReviewReply

// MARK: - StoreProducts Tests

@Suite("StoreProducts")
struct StoreProductsTests {

    @Test("Product IDs are non-empty")
    func productIDsNonEmpty() {
        #expect(!StoreProducts.monthly.isEmpty)
        #expect(!StoreProducts.annual.isEmpty)
    }

    @Test("Product IDs use reverse-domain format")
    func productIDsFormat() {
        #expect(StoreProducts.monthly.hasPrefix("com.reviewreply."))
        #expect(StoreProducts.annual.hasPrefix("com.reviewreply."))
    }

    @Test("All IDs set contains both products")
    func allIDsContainsBoth() {
        #expect(StoreProducts.allIDs.count == 2)
        #expect(StoreProducts.allIDs.contains(StoreProducts.monthly))
        #expect(StoreProducts.allIDs.contains(StoreProducts.annual))
    }

    @Test("Monthly and annual IDs are distinct")
    func idsAreDistinct() {
        #expect(StoreProducts.monthly != StoreProducts.annual)
    }
}
