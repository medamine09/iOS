import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol RappelConsoClientProtocol: Sendable {
    func fetchRecalls(barcode: String) async throws -> [RecallNotice]
}

public struct RappelConsoClient: RappelConsoClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    /// Endpoint Solr public de recherche de rappel par code-barres.
    /// Le format peut évoluer : prévoir une stratégie de fallback côté app.
    private let baseURL = URL(string: "https://rappel.conso.gouv.fr/api/consumer-products")!

    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func fetchRecalls(barcode: String) async throws -> [RecallNotice] {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "barcode", value: barcode),
            .init(name: "page", value: "1"),
            .init(name: "size", value: "20")
        ]

        let url = components.url!
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let payload = try decoder.decode(RappelConsoResponse.self, from: data)

        return payload.items.map { item in
            RecallNotice(
                title: item.title,
                category: item.category,
                publicationDate: item.publicationDate,
                riskLevel: item.riskLevel,
                detailsURL: item.link
            )
        }
    }
}

private struct RappelConsoResponse: Codable {
    let items: [RappelConsoItem]

    enum CodingKeys: String, CodingKey {
        case items = "results"
    }
}

private struct RappelConsoItem: Codable {
    let title: String
    let category: String?
    let publicationDate: Date?
    let riskLevel: String?
    let link: URL?

    enum CodingKeys: String, CodingKey {
        case title = "product_name"
        case category = "subcategory"
        case publicationDate = "publication_date"
        case riskLevel = "risk_level"
        case link = "link"
    }
}
