//
//  CountryDetailsViewController.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/10/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit

class CountryDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  fileprivate let cellId = "CellId"
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    cell.backgroundColor = .blue
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
  
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.delegate = self
    cv.dataSource = self
    return cv
  }()
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    
    setupCollectionView()
    
    
  }
  
  fileprivate func setupCollectionView() {
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.backgroundColor = .white
    view.addSubview(collectionView)
    collectionView.fillSuperview()
  }
}
