//
//  ColorCellSelectable.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/8/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit

class ColorCellSelectable: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.frame.size.width / 2
    }

}
