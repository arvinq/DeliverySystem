//
//  StatusButton.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/25/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import UIKit

class StatusButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // autolayout solution
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true       
    
    }
}
