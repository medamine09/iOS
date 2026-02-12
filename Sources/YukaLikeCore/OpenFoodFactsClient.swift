import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol OpenFoodFactsClientProtocol: Sendable {
    func fetchProduct(barcode: String) async throws -> OpenFoodFactsProduct
}

public struct OpenFoodFactsClient: OpenFoodFactsClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    public func fetchProduct(barcode: String) async throws -> OpenFoodFactsProduct {
        let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode)")!
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let payload = try decoder.decode(OpenFoodFactsResponse.self, from: data)
        guard payload.status == 1, let product = payload.product else {
            throw ProductNotFoundError(barcode: barcode)
        }

        return product
    }
}

public struct OpenFoodFactsProduct: Sendable, Equatable, Codable {
    public let code: String
    public let productName: String?
    public let brands: String?
    public let nutritionGrades: String?
    public let additivesTags: [String]?
    public let allergensTags: [String]?
    public let ecoscoreGrade: String?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case brands
        case nutritionGrades = "nutrition_grades"
        case additivesTags = "additives_tags"
        case allergensTags = "allergens_tags"
        case ecoscoreGrade = "ecoscore_grade"
    }
}

private struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodFactsProduct?
}
