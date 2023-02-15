//
//  TutorialView.swift
//  GyroMouse
//
//  Created by Matteo Riva on 10/09/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit

class TutorialView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explaination: UILabel!
    
    func setImage(_ image: UIImage, AndExplanation expl: String) {
        imageView.image = image
        explaination.text = expl
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
