import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import CoreML
import Vision


class HomeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var user: User?
    let titleLabel                      = SPTitleLabel(textAlignment: .left, fontSize: 20)
    let userImage                       = SPImageView(cornerRadius: 40)
    let querySearchBar                  = SPSearchBar()
    let tableView                       = UITableView()
    let cameraButton                    = UIButton(type: .system)
    var onCameraButtonTapped: (() -> Void)?
    var queryRecipesVC: QueryRecipesVC!
    let cancelButton                    = SPButton(backgroundColor: .clear, title: "Cancel")
    var recipes: [(tag: String, recipe: [Recipe])]      = []
    var similarRecipesArray: [GetSimilarRecipes] = []
    let categoryHeaderView              = CategoriesHeaderView()
    let recommendationHeaderTitle       = SPTitleLabel(text: "Recommendation", textAlignment: .left, fontSize: 20)
    
    let recommendationSeeAllButton      = SPButton(backgroundColor: .clear, title: "See All")
    let tags = [Tags.breakfast, Tags.lunch, Tags.dinner, Tags.soup, Tags.dessert]
    let group = DispatchGroup()
    
    private var searchDebounceTimer: Timer?
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoriesCollectionViewCell.self, forCellWithReuseIdentifier: CategoriesCollectionViewCell.reuseID)
        collectionView.register(RecommendationCollectionViewCell.self, forCellWithReuseIdentifier: RecommendationCollectionViewCell.reuseID)
        collectionView.register(CategoriesHeaderView.self, forSupplementaryViewOfKind: "CategoriesHeader", withReuseIdentifier: CategoriesHeaderView.headerIdentifier)
        collectionView.register(RecommendationHeaderView.self, forSupplementaryViewOfKind: "RecommendationHeader", withReuseIdentifier: RecommendationHeaderView.headerIdentifier)
        collectionView.backgroundColor = .systemBackground
       
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let cameraButton = UIButton()
        if let image = UIImage(named: "cameraicon") {
            cameraButton.setImage(image, for: .normal)
        }
        
        configureCompositionalLayout()
        setupQueryRecipesVC()
        layoutUI()
        configure()
        getCategoriesFromCache()
        createDismissKeyboardTapGesture()
        retrieveUserInfo()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        onCameraButtonTapped = { [weak self] in
            self?.presentActionSheet()
        }
        
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        
        view.addSubview(cameraButton)
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.centerYAnchor.constraint(equalTo: querySearchBar.centerYAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10), 
            cameraButton.widthAnchor.constraint(equalToConstant: 30),
            cameraButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func cameraButtonTapped() {
        onCameraButtonTapped?()
        print("camera is being tapped")
    }
    
    func presentActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentImagePicker(sourceType: UIImagePickerController.SourceType.camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] _ in
            self?.presentImagePicker(sourceType: UIImagePickerController.SourceType.photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }

    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            present(imagePickerController, animated: true, completion: nil)
        }
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("Could not get image from info dictionary.")
            return
        }
        
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("Could not convert image to pixel buffer.")
            return
        }
        
        guard let modelURL = Bundle.main.url(forResource: "ImageRecognitionMLlite", withExtension: "mlmodelc") else {
            print("Failed to find the model file.")
            return
        }
        
        do {
            let configuration = MLModelConfiguration()
            let mlModel = try MLModel(contentsOf: modelURL, configuration: configuration)
            guard let vnModel = try? VNCoreMLModel(for: mlModel) else {
                print("Failed to create VNCoreMLModel from MLModel.")
                return
            }
            
            let request = VNCoreMLRequest(model: vnModel) { [weak self] (request, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let results = request.results as? [VNClassificationObservation] {
                    let topResult = results.first
                    print("The model's prediction is: \(topResult?.identifier ?? "Unknown")")
                    
                    // Create an instance of QueryRecipesVC and perform a search with the prediction result
                    let prediction = topResult?.identifier ?? "Unknown"
                    let queryRecipesVC = QueryRecipesVC()
                    queryRecipesVC.searchText = prediction
                    queryRecipesVC.updateUI()
                    
                    // Push the QueryRecipesVC instance onto the navigation stack
                    DispatchQueue.main.async {
                        self?.navigationController?.pushViewController(queryRecipesVC, animated: true)
                    }
                }
            }

            #if targetEnvironment(simulator)
            request.usesCPUOnly = true
            #endif

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
        } catch {
            print("Error: \(error)")
        }
    }




    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    private func setupQueryRecipesVC() {
        queryRecipesVC = QueryRecipesVC()
        addChild(queryRecipesVC)
        view.addSubview(queryRecipesVC.view)
        queryRecipesVC.didMove(toParent: self)
        queryRecipesVC.view.isHidden = true
        queryRecipesVC.view.translatesAutoresizingMaskIntoConstraints = false
        querySearchBar.delegate = self
    }
    
    
    @objc func cancelButtonTapped() {
        queryRecipesVC.view.isHidden = true
        collectionView.isHidden = false
        cancelButton.isHidden = true
        querySearchBar.text = ""
    }

    
    func retrieveUserInfo() {
        PersistenceManager.retrieveUserProfile { [weak self] result in
                        switch result {
                        case .success(let user):
                            print("USER IS: \(user)")
                            if let profileImageUrl = user?.profileImageUrl,
                               let name = user?.name {
                                DispatchQueue.main.async {
                                    self?.userImage.downloadImage(fromURL: profileImageUrl)
                                    self?.titleLabel.text = "What would you like to cook today, \(name)?"
                                        print("PROFILE IMAGE URL IS: \(profileImageUrl)")
                                }
                                
                            }
        
                        case .failure(let error):
                            print("Error retrieving user profile: \(error.localizedDescription)")
                        }
                    }
                }
    
    func makeAPICallForRecipes(query: String, atIndex index: Int, group: DispatchGroup) {
        NetworkManager.shared.getRecipesInfo(for: .searhRecipes(query)) { [weak self] result in

            guard let self = self else { return }

            switch result {
            case .success(let recipes):

                for recipe in recipes {
                    PersistenceManager.updateWith(category: recipe, actionType: .add) { error in
                        if let error = error {
                            print("Error saving recipe: \(error)")
                        }
                    }
                }
                self.updateUI(with: recipes, atIndex: index)
            case .failure(_): break

            }
            group.leave()
        }
    }

    
    func makeAPICallForCategories(tag: String, atIndex index: Int, group: DispatchGroup) {
        NetworkManager.shared.getRecipesInfo(for: .searchCategory(tag)) { [weak self] category in
            
            guard let self = self else { return }
           
            
            switch category {
            case .success(let categories):
                
                for category in categories {
                    PersistenceManager.updateWith(category: category, actionType: .add) { error in
                        if let error = error {
                            print("Error saving category: \(error)")
                        }
                    }
                }
            self.updateUI(with: categories, atIndex: index)
            case .failure(_): break
                
            }
            group.leave()
        }
    }
    
    func updateUI(with categories: [Recipe], atIndex index: Int) {
           
           DispatchQueue.main.async {
               self.recipes[index].recipe = categories
           }
       }
    
    
    func getCategoriesFromCache() {
        // First, try to retrieve categories from cache
        recipes = tags.map { (tag: $0, recipe: [])}
        for (index, tag) in tags.enumerated() {
            group.enter()
            
            PersistenceManager.retrievedCategories { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let cachedCategories):
                    if !cachedCategories.isEmpty {
                        // If cached categories are available, update UI
                        print("Data is coming from cache: \(cachedCategories)")
                        self.updateUI(with: cachedCategories, atIndex: index)
                    } else {
                        // If not available in cache, make API call
                        print("Data is not available in cache, making API call...")
                        self.makeAPICallForCategories(tag: tag, atIndex: index, group: group)
                    }
                    // If there's an error retrieving from cache, make API call
                case .failure(let error):
                    print("Error retrieving categories from cache: \(error)")
                    
                    }
                
                }
            self.group.notify(queue: .main) {
            self.collectionView.reloadData()
            }
            
        }
    }
    
    
    
    func fetchSimilarRecipes(recipeID: String, completion: @escaping (Result<[GetSimilarRecipes], SPError>) -> Void) {
        print("Fetching similar recipes for recipeID: \(recipeID)")
        NetworkManager.shared.getSimilarRecipes(recipeID: recipeID) { [weak self] result in
            
            guard let self = self else {return}
            
            switch result {
            case .success(let similarRecipes):
                print("Fetched similar recipes")
                DispatchQueue.main.async {
                    print("Reloading collection view...")
                    completion(.success(similarRecipes))
                    self.similarRecipesArray.append(contentsOf: similarRecipes)
                    self.collectionView.reloadData()
                    print("Collection view reloaded.")
                }
                
            case .failure(let error):
                print("Error fetching similar recipes: \(error)")
                DispatchQueue.main.async {
                completion(.failure(error))
                }
                self.view.bringSubviewToFront(self.tableView)
              }
            }
        }
    
    
    
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    func configure() {
            collectionView.setUp(to: view, and: querySearchBar)
            cancelButton.isHidden = true
        }
    
    
    func layoutUI() {
        view.addSubviews(querySearchBar, titleLabel, userImage, collectionView, cancelButton)
        
        NSLayoutConstraint.activate([
            querySearchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            querySearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            querySearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),
            querySearchBar.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.leadingAnchor.constraint(equalTo: querySearchBar.trailingAnchor, constant: 5),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            cancelButton.centerYAnchor.constraint(equalTo: querySearchBar.centerYAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
            titleLabel.heightAnchor.constraint(equalToConstant: 48),
            
            userImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            userImage.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            userImage.heightAnchor.constraint(equalToConstant: 60),
            userImage.widthAnchor.constraint(equalToConstant: 60),
            
            queryRecipesVC.view.topAnchor.constraint(equalTo: querySearchBar.bottomAnchor),
            queryRecipesVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            queryRecipesVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            queryRecipesVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension HomeVC: UISearchBarDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        querySearchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        queryRecipesVC.reloadTableView()
        queryRecipesVC.view.isHidden = false
        collectionView.isHidden      = true
        cancelButton.isHidden        = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Invalidate the previous debounce timer
        searchDebounceTimer?.invalidate()
        
        // Start a new debounce timer
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.queryRecipesVC.searchText = searchText
            self?.queryRecipesVC.updateUI()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
}

extension HomeVC {
    func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout {sectionIndex,enviroment in
            switch sectionIndex {
            case 0 :
                return UIHelper.categoriesSection()
                
            case 1 :
                return UIHelper.recommendationSection()
                
            default:
                return UIHelper.categoriesSection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
}

extension UIImage {
    func resize(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func toCVPixelBuffer() -> CVPixelBuffer? {
        guard let resizedImage = self.resize(to: CGSize(width: 299, height: 299)) else {
            return nil
        }

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(resizedImage.size.width), Int(resizedImage.size.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData, width: Int(resizedImage.size.width), height: Int(resizedImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            return nil
        }

        context.translateBy(x: 0, y: resizedImage.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context)
        resizedImage.draw(in: CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
