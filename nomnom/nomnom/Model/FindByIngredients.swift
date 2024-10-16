import Foundation

// MARK: - RecipeSearchElement
struct FindByIngredients: Codable, Hashable {
    let id: Int
    let title: String
    let image: String
    let imageType: String
    let usedIngredientCount, missedIngredientCount: Int
    let missedIngredients, usedIngredients: [SedIngredient]
    let likes: Int
    
    enum CodingKeys: String, CodingKey {
            case id, title, image, imageType, usedIngredientCount, missedIngredientCount, missedIngredients, usedIngredients, likes
        }
}

// MARK: - SedIngredient
struct SedIngredient: Codable, Hashable {
    let id: Int
    let amount: Double
    let unit, unitLong, unitShort, aisle: String
    let name, original, originalName: String
    let meta: [String]
    let image: String
    let extendedName: String?
}
