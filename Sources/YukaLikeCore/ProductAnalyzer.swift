import Foundation

public struct ProductAnalyzer: Sendable {
    private let openFoodFactsClient: OpenFoodFactsClientProtocol
    private let rappelConsoClient: RappelConsoClientProtocol

    public init(
        openFoodFactsClient: OpenFoodFactsClientProtocol = OpenFoodFactsClient(),
        rappelConsoClient: RappelConsoClientProtocol = RappelConsoClient()
    ) {
        self.openFoodFactsClient = openFoodFactsClient
        self.rappelConsoClient = rappelConsoClient
    }

    public func analyze(barcode: String) async throws -> ProductAnalysis {
        async let productTask = openFoodFactsClient.fetchProduct(barcode: barcode)
        async let recallTask = rappelConsoClient.fetchRecalls(barcode: barcode)

        let product = try await productTask
        let recalls = (try? await recallTask) ?? []

        return ProductAnalysis(
            barcode: product.code,
            name: product.productName ?? "Produit non nommé",
            brand: product.brands,
            nutritionGrade: product.nutritionGrades,
            additivesTags: product.additivesTags ?? [],
            allergensTags: product.allergensTags ?? [],
            ecoscoreGrade: product.ecoscoreGrade,
            recalled: !recalls.isEmpty,
            recalls: recalls
        )
    }
}
