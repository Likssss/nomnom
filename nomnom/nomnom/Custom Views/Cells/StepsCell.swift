import UIKit

class StepsCell: UITableViewCell {

    static let reuseID = "StepsCell"
    let stepsLabel     = SPTitleLabel(textAlignment: .left, fontSize: 20)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInstructionsCell(steps: [SimplifiedStep], categoryTitle: String? = nil) {
        let stackView = UIStackView()
        addSubviews(stepsLabel, stackView)
        stepsLabel.text = "STEPS"
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            stepsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stepsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            stepsLabel.heightAnchor.constraint(equalToConstant: 25),
            stepsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
        
            stackView.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 25),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
        for step in steps {
            let stepNumber = SPTitleLabel(text:String(step.number), textAlignment: .left, fontSize: 15)
            let steps = SPSecondaryTitleLabel(fontSize: 15, color: .black, weight: .bold)
            
            steps.text = step.step.uppercased()
            stepNumber.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stepNumber.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            
            let stepsStackView = UIStackView(arrangedSubviews: [stepNumber, steps])
            stepsStackView.axis = .horizontal
            stepsStackView.alignment = .leading
            stepsStackView.distribution = .equalSpacing
            stepsStackView.layer.cornerRadius = 10
            stepsStackView.backgroundColor = .systemMint.withAlphaComponent(0.5)
            
            stackView.addArrangedSubview(stepsStackView)
            
            stepNumber.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stepNumber.widthAnchor.constraint(equalToConstant: 40).isActive = true
            stepNumber.trailingAnchor.constraint(equalTo: steps.leadingAnchor, constant: -10).isActive = true
            steps.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        }
    }
}
