//
//  MaterialTextField.swift
//  FGStudios Showcase
//
//  Created by Joshua Ide on 22/03/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = layer.bounds.width / 172
    }
    
    //For placeholder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 20, 0)
    }
    
    //For editing
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 20, 0)
    }

}
