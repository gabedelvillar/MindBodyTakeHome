//
//  ConvineanceExtensions.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/12/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit

extension UIStackView {
  convenience init(arrangedSubViews: [UIView], customSpacing: CGFloat = 0){
    self.init(arrangedSubviews: arrangedSubViews)
    self.spacing = customSpacing
  }
}

extension UILabel {
  convenience init(text: String, font: UIFont, numberOfLines: Int = 1) {
    self.init(frame: .zero)
    self.text = text
    self.font = font
    self.numberOfLines = numberOfLines
  }
}

extension UIImageView {
  convenience init(cornerRadius: CGFloat) {
    self.init(image: nil)
    self.layer.cornerRadius = cornerRadius
    self.clipsToBounds = true
    self.contentMode = .scaleAspectFill
    
  }
}
