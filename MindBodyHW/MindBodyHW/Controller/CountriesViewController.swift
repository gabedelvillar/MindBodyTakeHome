//
//  ViewController.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/9/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit
import SDWebImage

class CountriesViewController: UIViewController{
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
   
    setupViews()
    fetchData()
  }
  
  fileprivate func setupViews(){
    view.backgroundColor = .white
    
    setupNavigationController()
    setupCollectionView()
    setupSupplementaryViews()
  }
  
  fileprivate func setupNavigationController() {
    if let navigationController = navigationController {
      navigationController.navigationBar.prefersLargeTitles = true
      navigationController.navigationBar.topItem?.title = "Countries"
    }
  }
  
  fileprivate func setupSupplementaryViews(){
    view.addSubview(activityIndicator)
    activityIndicator.fillSuperview()
    view.addSubview(errorVerticalStackView)
    errorVerticalStackView.centerInSuperview()
  }
  
  @objc fileprivate func startRefreshing() {
    // clear data from collectoinView, and begin refresh
    countries.removeAll()
    collectionView.reloadData()
    refreshController.endRefreshing()
    countries.removeAll()
    fetchData()
  }
  
  @objc fileprivate func retryBtnPressed() {
    errorVerticalStackView.isHidden = true
    fetchData()
  }
  
  
  fileprivate func setupCollectionView() {
    view.addSubview(collectionView)
    collectionView.fillSuperview()
    collectionView.backgroundColor = .white
    collectionView.register(LocationCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.refreshControl = refreshController
  }
  
  
  fileprivate func fetchData() {
    
    activityIndicator.startAnimating()
    
    NetworkService.shared.fetchCountries { [unowned self] (countries, err) in
      self.countries = countries ?? []
      
      // Demonstarte that the laoding spinner is functional
      sleep(1)
      
       // Check for Errors, and let the user rety the API reqeust
      if let err = err {
        print("there was an error fetchig data from the API: ", err)
        
        DispatchQueue.main.async {
          self.updateUIWithNetworkError()
        }
        return
      }
      // Else: Success, display the results of the data fetch to the user
      DispatchQueue.main.async {
        self.updateUIWithNetworkResults()
      }
    }
  }
  
  fileprivate func updateUIWithNetworkError(){
    collectionView.isHidden = true
    errorVerticalStackView.isHidden = false
    activityIndicator.stopAnimating()
  }
  
  fileprivate func updateUIWithNetworkResults() {
    collectionView.isHidden = false
    collectionView.reloadData()
    activityIndicator.stopAnimating()
  }
}

extension CountriesViewController: UICollectionViewDelegate{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let country = countries[indexPath.item]
    
    let countryFlagURL = "https://www.countryflags.io/\(country.Code)/flat/64.png"
    
    let countryDetailsViewController = CountryDetailsViewController(countryName: country.Name, countryId: country.ID, countryFlagURL: countryFlagURL)
    
    countryDetailsViewController.navigationItem.title = country.Name
    navigationController?.pushViewController(countryDetailsViewController, animated: true)
  }
  
}

extension CountriesViewController: UICollectionViewDataSource{
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return countries.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LocationCell
    let country = countries[indexPath.item]
    cell.flagImageView.sd_setImage(with:URL(string: "https://www.countryflags.io/\(country.Code)/flat/64.png") )
    cell.nameLbl.text = country.Name
    return cell
  }
  
}

extension CountriesViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
}





