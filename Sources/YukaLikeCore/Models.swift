import Foundation

public struct ProductAnalysis: Sendable, Equatable {
    public let barcode: String
    public let name: String
    public let brand: String?
    public let nutritionGrade: String?
    public let additivesTags: [String]
    public let allergensTags: [String]
    public let ecoscoreGrade: String?
    public let recalled: Bool
    public let recalls: [RecallNotice]

    public init(
        barcode: String,
        name: String,
        brand: String? = nil,
        nutritionGrade: String? = nil,
        additivesTags: [String] = [],
        allergensTags: [String] = [],
        ecoscoreGrade: String? = nil,
        recalled: Bool,
        recalls: [RecallNotice] = []
    ) {
        self.barcode = barcode
        self.name = name
        self.brand = brand
        self.nutritionGrade = nutritionGrade
        self.additivesTags = additivesTags
        self.allergensTags = allergensTags
        self.ecoscoreGrade = ecoscoreGrade
        self.recalled = recalled
        self.recalls = recalls
    }
}

public struct RecallNotice: Sendable, Equatable, Codable {
    public let title: String
    public let category: String?
    public let publicationDate: Date?
    public let riskLevel: String?
    public let detailsURL: URL?

    public init(
        title: String,
        category: String? = nil,
        publicationDate: Date? = nil,
        riskLevel: String? = nil,
        detailsURL: URL? = nil
    ) {
        self.title = title
        self.category = category
        self.publicationDate = publicationDate
        self.riskLevel = riskLevel
        self.detailsURL = detailsURL
    }
}

public struct ProductNotFoundError: Error, LocalizedError {
    public let barcode: String

    public var errorDescription: String? {
        "Aucun produit trouvé pour le code-barres \(barcode)."
    }

    public init(barcode: String) {
        self.barcode = barcode
    }
}
