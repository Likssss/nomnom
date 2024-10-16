import Foundation

enum SPError: String, Error {
    case invalidQuery = "This query created an invalid request. Please try again"
    case unableToComplete = "Unable to complete your request. Please check your internet connection"
    case invalidResponse = "Invalid response from the server. Please try again!"
    case alreadyInCategories = "You have already add this item into categories. You must really like them!"
    case unableToCategory = "There was an error categorizing this item. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    case unableToSaveUserProfile = "Unable To Save the User Profile. Please try again."
    case unableToRetrieveUserProfile = "Unable To Retrieve User Profile"
}
