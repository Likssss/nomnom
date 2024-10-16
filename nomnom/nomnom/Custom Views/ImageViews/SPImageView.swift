import UIKit


class SPImageView: UIImageView {
    
    let cache = NetworkManager.shared.cache
    let placeholderImage = UIImage(systemName: "photo")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(cornerRadius: CGFloat) {
         self.init(frame: .zero)
         self.layer.cornerRadius = cornerRadius
         
         
     }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
//        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func downloadImage(fromURL url: String) {
        NetworkManager.shared.downloadImage(from: url) { [weak self] image, isFromCache in
            guard let self = self else { return }
            DispatchQueue.main.async { self.image = image
                if isFromCache {
                    print("Image loaded from cache")
                } else {
                    print("Image downloaded from URL")
                }
            }
        }
    }
}
