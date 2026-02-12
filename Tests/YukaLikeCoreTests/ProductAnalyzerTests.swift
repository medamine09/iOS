import XCTest
@testable import YukaLikeCore

final class ProductAnalyzerTests: XCTestCase {
    func testAnalyzeMergesProductAndRecalls() async throws {
        let product = OpenFoodFactsProduct(
            code: "1234567890123",
            productName: "Biscuits chocolat",
            brands: "DemoBrand",
            nutritionGrades: "d",
            additivesTags: ["en:e150d"],
            allergensTags: ["en:gluten"],
            ecoscoreGrade: "c"
        )

        let recall = RecallNotice(
            title: "Biscuits chocolat 200g",
            category: "Alimentation",
            publicationDate: nil,
            riskLevel: "Élevé",
            detailsURL: URL(string: "https://rappel.conso.gouv.fr/fiche-rappel/123")
        )

        let analyzer = ProductAnalyzer(
            openFoodFactsClient: OpenFoodFactsClientMock(product: product),
            rappelConsoClient: RappelConsoClientMock(recalls: [recall])
        )

        let result = try await analyzer.analyze(barcode: "1234567890123")

        XCTAssertEqual(result.barcode, "1234567890123")
        XCTAssertEqual(result.name, "Biscuits chocolat")
        XCTAssertEqual(result.nutritionGrade, "d")
        XCTAssertTrue(result.recalled)
        XCTAssertEqual(result.recalls.count, 1)
    }

    func testAnalyzeIgnoresRecallFailure() async throws {
        let product = OpenFoodFactsProduct(
            code: "321",
            productName: "Jus pomme",
            brands: "Demo",
            nutritionGrades: "b",
            additivesTags: nil,
            allergensTags: nil,
            ecoscoreGrade: "b"
        )

        let analyzer = ProductAnalyzer(
            openFoodFactsClient: OpenFoodFactsClientMock(product: product),
            rappelConsoClient: RappelConsoClientFailingMock()
        )

        let result = try await analyzer.analyze(barcode: "321")

        XCTAssertFalse(result.recalled)
        XCTAssertEqual(result.recalls, [])
    }
}

private struct OpenFoodFactsClientMock: OpenFoodFactsClientProtocol {
    let product: OpenFoodFactsProduct

    func fetchProduct(barcode: String) async throws -> OpenFoodFactsProduct {
        product
    }
}

private struct RappelConsoClientMock: RappelConsoClientProtocol {
    let recalls: [RecallNotice]

    func fetchRecalls(barcode: String) async throws -> [RecallNotice] {
        recalls
    }
}

private struct RappelConsoClientFailingMock: RappelConsoClientProtocol {
    func fetchRecalls(barcode: String) async throws -> [RecallNotice] {
        throw URLError(.cannotParseResponse)
    }
}
