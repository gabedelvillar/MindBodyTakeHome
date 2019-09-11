//
//  VerticalStackView.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/11/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit

class VerticalStackView: UIStackView {
  init(arrangedSubviews: [UIView], spacing: CGFloat = 0){
    super.init(frame: .zero)
    
    arrangedSubviews.forEach({addArrangedSubview($0)})
    
    self.spacing = spacing
    self.axis = .vertical
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
