import UIKit

class QueryRecipesVC: UIViewController, UISheetPresentationControllerDelegate {
    
    var vc = UIViewController()
    var searchText: String?
    private let tableView = UITableView()
    var searchResults: [Recipe] = []
    var stepsResults: [SimplifiedStep] = []
    var ingredientsResults: [Ent] = []
    let recipeImage    = SPImageView(frame: .zero)
    var uniqueIngredientNames = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureUI()
        updateUI()
        view.backgroundColor = .systemPink
    }
    
    
    func updateUI() {
        guard let query = searchText else {return}
        
        NetworkManager.shared.getRecipesInfo(for: .searhRecipes(query)) { [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async {
                    self.searchResults = recipes
                    for recipe in recipes {
                        self.extractIngredients(from: recipe.analyzedInstructions)
                    }
                    self.tableView.reloadData()
                    self.view.bringSubviewToFront(self.tableView)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.register(RecipesCell.self, forCellReuseIdentifier: RecipesCell.reuseID)
    }
    
    
    private func configureUI() {
            view.addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    
    func reloadTableView() {
            tableView.reloadData()
        }
    
    func extractIngredients(from analyzedInstructions: [AnalyzedInstruction]) {
        for instruction in analyzedInstructions {
            for step in instruction.steps {
                let steps = SimplifiedStep(number: step.number, step: step.step)
                stepsResults.append(steps)
                
                for ingredient in step.ingredients {
                    let imageURL = "https://spoonacular.com/cdn/ingredients_100x100/\(ingredient.image)"
                    let newIngredient = Ent(id: ingredient.id, name: ingredient.name, localizedName: ingredient.localizedName, image: imageURL, temperature: ingredient.temperature)
                    ingredientsResults.append(newIngredient)
                }
            }
        }
    }
    }
    
extension QueryRecipesVC: UITableViewDataSource, UITableViewDelegate, UIAdaptivePresentationControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipesCell.reuseID) as! RecipesCell
        let recipe = searchResults[indexPath.row]
        cell.set(recipe: recipe)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let selectedRecipe = searchResults[indexPath.row]
        let ingredientsForSelectedRecipe = ingredientsResults.filter { ingredient in
            let allSteps = selectedRecipe.analyzedInstructions.flatMap { $0.steps }
            return allSteps.contains { step in
                step.ingredients.contains { ent in
                    if ent.id == ingredient.id {
                            // Check if the ingredient name is unique
                            if !uniqueIngredientNames.contains(ent.name) {
                                uniqueIngredientNames.insert(ent.name)
                                return true
                            }
                        }
                        return false
                    }
                }
            }
        
        let stepsForSelectedRecipe = stepsResults.filter { simplifiedStep in
            let allSteps = selectedRecipe.analyzedInstructions.flatMap { $0.steps }
            return allSteps.contains { step in
                step.number == simplifiedStep.number && step.step == simplifiedStep.step
            }
        }

            
        
        let destVC = InstructionsVC(recipe: selectedRecipe, ingredients: ingredientsForSelectedRecipe, steps: stepsForSelectedRecipe)
        vc = destVC
        let nav = UINavigationController(rootViewController: destVC)
        nav.modalPresentationStyle = .pageSheet
        
        // Create and configure the UISheetPresentationController
        if let sheet = nav.sheetPresentationController{
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 40
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.delegate = self
        }
        present(nav, animated: true)
    }
    
    func presentationControllerDidDismiss(_ presantationController: UIPresentationController) {
        UIView.animate(withDuration: 0.7, animations: {
                self.recipeImage.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            }, completion: { _ in
                self.recipeImage.removeFromSuperview()
            })
    }
}
