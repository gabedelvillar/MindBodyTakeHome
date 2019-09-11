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
    aiv.backgroundColor = .white
    return aiv
  }()
  
  let dataFetchErrorMsg = UILabel(text: "Oops. Could not fetch data from API", font: .systemFont(ofSize: 18, weight: .bold), numberOfLines: 2)
  
  let retryBtn: UIButton = {
    let btn = UIButton(type: .system)
    btn.setTitle("RETRY", for: .normal)
    btn.addTarget(self, action: #selector(retryBtnPressed), for: .touchUpInside)
    return btn
  }()
  
  lazy var errorVerticalStackView: VerticalStackView = {
    let stackView = VerticalStackView(arrangedSubviews: [
      dataFetchErrorMsg,
      retryBtn
      ], spacing: 12)
    stackView.alignment = .center
    stackView.isHidden = true
    return stackView
    
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
    view.backgroundColor = .white
    
    setupCollectionView()
    
    view.addSubview(activityIndicator)
    activityIndicator.fillSuperview()
    
    view.addSubview(errorVerticalStackView)
    errorVerticalStackView.centerInSuperview()
    
    view.addSubview(noProvincesMsg)
    noProvincesMsg.centerInSuperview()
    noProvincesMsg.isHidden = true
    
    fetchData()
    
  }
  
  @objc fileprivate func retryBtnPressed() {
    errorVerticalStackView.isHidden = true
    fetchData()
  }
  
//  override func viewDidAppear(_ animated: Bool) {
//    if provinces.count == 0 {
//      activityIndicator.stopAnimating()
//      view.addSubview(noProvincesMsg)
//      noProvincesMsg.centerInSuperview()
//    }
//  }
  
  fileprivate func fetchData() {
    
    activityIndicator.startAnimating()
    
    Service.shared.fetchCountryDetails(countryId: countryId) { (provinces, err) in
      self.provinces = provinces ?? []
      
      // Used to demonstarte that the laoding spinner is present and functional
      sleep(1)
      
      if let err = err {
        print("there was an error fetchig data from the API: ", err)
        
        DispatchQueue.main.async {
          
          self.collectionView.isHidden = true
          self.errorVerticalStackView.isHidden = false
          
          
          self.activityIndicator.stopAnimating()
          
        }
        
        return
      }
      
      
      
      DispatchQueue.main.async {
        
         self.activityIndicator.stopAnimating()
        
        if self.provinces.count == 0 {
          
          
          self.noProvincesMsg.isHidden = false
        } else{
        
          self.noProvincesMsg.isHidden = true
          self.collectionView.isHidden = false
          self.collectionView.reloadData()
          
        }
        
       
        
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
