//
//  ViewController.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/9/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit

class CountriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  fileprivate let cellId = "cellID"
  fileprivate var countries = [Country]()
  
  var activityIndicator: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView(style: .whiteLarge)
    aiv.color = .darkGray
    aiv.hidesWhenStopped = true
    aiv.backgroundColor = .white
    return aiv
  }()
  
  lazy var refreshController: UIRefreshControl = {
    let rc = UIRefreshControl()
    rc.addTarget(self, action: #selector(startRefreshing), for: .valueChanged)
    return rc
  }()
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.delegate = self
    cv.dataSource = self
    return cv
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

  override func viewDidLoad() {
    super.viewDidLoad()
   
    view.backgroundColor = .white
    
    if let navigationController = navigationController {
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.navigationBar.topItem?.title = "Countries"
    }
    setupCollectionView()
    
    view.addSubview(activityIndicator)
    activityIndicator.fillSuperview()
    
   
    
   
    view.addSubview(errorVerticalStackView)
    errorVerticalStackView.centerInSuperview()
    
    
    
    fetchData()
  }
  
  @objc fileprivate func startRefreshing() {
    refreshController.endRefreshing()
    fetchData()
  }
  
@objc fileprivate func retryBtnPressed() {
    errorVerticalStackView.isHidden = true
    fetchData()
  }
  
  
  fileprivate func fetchData() {
    
    activityIndicator.startAnimating()
    Service.shared.fetchCountries { (countries, err) in
      self.countries = countries ?? []
      
      // Demonstarte that the laoding spinner is functional
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
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        self.activityIndicator.stopAnimating()
        
      }
    }

  }
  
  fileprivate func setupCollectionView() {
    view.addSubview(collectionView)
    collectionView.fillSuperview()
    collectionView.backgroundColor = .white
    collectionView.register(CountryCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.refreshControl = refreshController
  }
  
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CountryCell
    let country = countries[indexPath.item]
    cell.nameLbl.text = country.Name
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return countries.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let country = countries[indexPath.item]
    
    let countryDetailsViewController = CountryDetailsViewController(countryId: country.ID)
    navigationController?.navigationBar.topItem?.title = country.Name
    navigationController?.pushViewController(countryDetailsViewController, animated: true)
  }


}



