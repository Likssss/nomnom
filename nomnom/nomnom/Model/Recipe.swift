import Foundation


// MARK: - Welcome
struct RecipeResults: Codable {
    let results: [Recipe]
    let offset, number, totalResults: Int
}

// MARK: - Result
struct Recipe: Codable, Hashable, Equatable {
    let vegetarian, vegan, glutenFree, dairyFree: Bool
    let veryHealthy, cheap, veryPopular, sustainable: Bool
    let lowFodmap: Bool
    let weightWatcherSmartPoints: Int
    let gaps: String
    let preparationMinutes, cookingMinutes, aggregateLikes, healthScore: Int
    let creditsText, sourceName: String
    let pricePerServing: Double
    let id: Int
    let title: String
    let readyInMinutes, servings: Int
    let sourceURL: String
    let image: String
    let imageType, summary: String
    let dishTypes, diets: [String]
    let analyzedInstructions: [AnalyzedInstruction]

    enum CodingKeys: String, CodingKey {
        case vegetarian, vegan, glutenFree, dairyFree, veryHealthy, cheap, veryPopular, sustainable, lowFodmap, weightWatcherSmartPoints, gaps, preparationMinutes, cookingMinutes, aggregateLikes, healthScore, creditsText, sourceName, pricePerServing, id, title, readyInMinutes, servings
        case sourceURL = "sourceUrl"
        case image, imageType, summary, dishTypes, diets, analyzedInstructions
    }
    
    init() {
        self.vegetarian = false
        self.preparationMinutes = 0
        self.sourceName = ""
        self.image = ""
        self.vegan = false
        self.glutenFree = false
        self.dairyFree = false
        self.veryHealthy = false
        self.cheap = false
        self.veryPopular = false
        self.sustainable = false
        self.lowFodmap = false
        self.weightWatcherSmartPoints = 0
        self.gaps = ""
        self.creditsText = ""
        self.pricePerServing = 0.0
        self.id = 0
        self.title = ""
        self.readyInMinutes = 0
        self.sourceURL = ""
        self.imageType = ""
        self.dishTypes = []
        self.analyzedInstructions = []
        self.summary = ""
        self.diets = []
        self.cookingMinutes = 0
        self.aggregateLikes = 0
        self.healthScore = 0
        self.servings = 0
    }
}

// MARK: - AnalyzedInstruction
struct AnalyzedInstruction: Codable, Hashable, Equatable {
    let name: String
    let steps: [Step]
}

// MARK: - Step
struct Step: Codable, Hashable, Equatable {
    let number: Int
    let step: String
    let ingredients, equipment: [Ent]
    let length: Length?
}

// MARK: - Ent
struct Ent: Codable, Hashable, Equatable {
    let id: Int
    let name, localizedName, image: String
    let temperature: Length?
}

// MARK: - Length
struct Length: Codable, Hashable, Equatable {
    let number: Int
    let unit: String
}
