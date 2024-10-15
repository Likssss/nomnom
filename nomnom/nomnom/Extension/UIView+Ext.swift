import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
    
    func setUp(to superView: UIView, and to: UISearchBar) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: to.bottomAnchor, constant: 20).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
    }
}
