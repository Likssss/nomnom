import Foundation

struct User: Codable {
    let uid: String
    let name: String
    var profileImageUrl: String?
    var bookmarkedRecipes: [String]?
}

