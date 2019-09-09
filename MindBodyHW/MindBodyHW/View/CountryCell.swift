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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .red
    
    setupViews()
  }
  
  fileprivate func setupViews(){
    addSubview(nameLbl)
    nameLbl.centerInSuperview()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
