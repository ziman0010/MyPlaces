//
//  RatingControl.swift
//  testTableViewAppMyPlaces
//
//  Created by Алексей Черанёв on 18.07.2021.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {

    //MARK: Properties
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44, height: 44)
    {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button action
    
    @objc func ratingButtonTapped(_ sender: UIButton) {
        guard let index = ratingButtons.firstIndex(of: sender) else { return }
        
        //Calculate the rating of the selected button
        let selectedRating = index + 1
        if selectedRating == rating
        {
            rating = 0
        }
        else
        {
            rating = selectedRating
        }
        
        
    }

    //MARK: Private Methods
    private func setupButtons() {
        
        for button in ratingButtons
        {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        //Load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle,
                                      compatibleWith: self.traitCollection)
        
        
        for _ in 0..<starCount
        {
            //Create the button
            let button = UIButton()
            
            //Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            //Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false //turn off automatically created constraints
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true // set the constrait and turn it on
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            
            //Add the button to the stack
            addArrangedSubview(button)
            
            //Add the new button to the rating button array
            ratingButtons.append(button)
            
            updateButtonSelectionState()
        }
        
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated()
        {
            button.isSelected = index < rating
        }
    }
}
