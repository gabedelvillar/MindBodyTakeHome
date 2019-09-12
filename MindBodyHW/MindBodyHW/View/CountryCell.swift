//
//  CountryCell.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/9/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit

class CountryCell: UICollectionViewCell {
  
  let nameLbl = UILabel(text: "USA", font: .systemFont(ofSize: 18))
  
  let flagImageView = UIImageView(cornerRadius: 16)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    
    setupViews()
  }
  
  fileprivate func setupViews(){
    flagImageView.constrainWidth(constant: 50)
    flagImageView.constrainHeight(constant: 50)
    let stackView = UIStackView(arrangedSubViews: [
      flagImageView,
      nameLbl
      ], customSpacing: 12)
    
    stackView.alignment = .center
    addSubview(stackView)
    stackView.fillSuperview(padding: .init(top: 0, left: 16, bottom: 0, right: 16))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

