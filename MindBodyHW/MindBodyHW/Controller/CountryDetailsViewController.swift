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
  fileprivate let countryId: Int
  fileprivate var provinces = [Province]()
  
  init(countryId: Int){
    self.countryId = countryId
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var activityIndicator: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView(style: .whiteLarge)
    aiv.color = .darkGray
    aiv.hidesWhenStopped = true
    aiv.startAnimating()
    aiv.backgroundColor = .white
    return aiv
  }()
  
  let noProvincesMsg = UILabel(text: "No Provinces for this Country to Display", font: .systemFont(ofSize: 18, weight: .bold), numberOfLines: 2)
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return provinces.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProvinceCell
    let province = provinces[indexPath.item]
    cell.nameLbl.text = province.Name
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
    
    view.addSubview(activityIndicator)
    activityIndicator.fillSuperview()
    
    fetchData()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if provinces.count == 0 {
      activityIndicator.stopAnimating()
      view.addSubview(noProvincesMsg)
      noProvincesMsg.centerInSuperview()
    }
  }
  
  fileprivate func fetchData() {
    
    Service.shared.fetchCountryDetails(countryId: countryId) { (provinces, err) in
      self.provinces = provinces ?? []
      
      
      // Used to demonstarte that the laoding spinner is present and functional
      sleep(1)
      
      DispatchQueue.main.async {
        self.collectionView.reloadData()
        self.activityIndicator.stopAnimating()
      }
    }
    
  }
  
  fileprivate func setupCollectionView() {
    collectionView.register(ProvinceCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.backgroundColor = .white
    view.addSubview(collectionView)
    collectionView.fillSuperview()
  }
}
