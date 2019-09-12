//
//  CountryDetailsViewController.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/10/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit
import MapKit

class CountryDetailsViewController: UIViewController{
  
  fileprivate let cellId = "CellId"
  fileprivate let countryName: String
  fileprivate let countryFlagURL: String
  
  
  fileprivate let countryId: Int
  fileprivate var provinces = [Province]()
  
  var activityIndicator: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView(style: .whiteLarge)
    aiv.color = .darkGray
    aiv.hidesWhenStopped = true
    aiv.backgroundColor = .white
    return aiv
  }()
  
  let dataFetchErrorMsg = UILabel(text: "Oops. Could not fetch data from API", font: .systemFont(ofSize: 18, weight: .bold), numberOfLines: 2)
  
  
  let noProvincesMsg = UILabel(text: "No Provinces for this Country to Display", font: .systemFont(ofSize: 18, weight: .bold), numberOfLines: 2)
  
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
  
  let mapView: MKMapView =  {
    let map = MKMapView()
    return map
  }()
  
  
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.delegate = self
    cv.dataSource = self
    return cv
  }()
  
  
  init(countryName: String, countryId: Int, countryFlagURL: String){
    self.countryName = countryName
    self.countryId = countryId
    self.countryFlagURL = countryFlagURL
    super.init(nibName: nil, bundle: nil)
  }
  
  
  // Remove clustered annotaions from the map view to prevent memory leaks.
  deinit {
    mapView.removeAnnotations(mapView.annotations)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    fetchData()
  }
  
  fileprivate func setupViews() {
    view.backgroundColor = .white
    
    setupMapView()
    setupCollectionView()
    setupSupplementaryViews()
  }
  
  fileprivate func setupMapView() {
    view.addSubview(mapView)
    
    mapView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .zero, size: .init(width: view.frame.width, height: 180))
    
    MapService.shared.setMapToLocation(mapView: mapView, querySearch: countryName, annotationTitle: countryName, zoomLatitudeMult: 10, zoomLongitudeMult: 10)
  }
  
  fileprivate func setupCollectionView() {
    collectionView.register(LocationCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.backgroundColor = .white
    
    view.addSubview(collectionView)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
      ])
  }

  fileprivate func setupSupplementaryViews(){
    view.addSubview(activityIndicator)
    activityIndicator.fillSuperview()
    
    view.addSubview(errorVerticalStackView)
    errorVerticalStackView.centerInSuperview()
    
    view.addSubview(noProvincesMsg)
    noProvincesMsg.centerInSuperview()
    noProvincesMsg.isHidden = true
  }
  
  @objc fileprivate func retryBtnPressed() {
    MapService.shared.setMapToLocation(mapView: mapView, querySearch: countryName, annotationTitle: countryName, zoomLatitudeMult: 10, zoomLongitudeMult: 10)
    errorVerticalStackView.isHidden = true
    fetchData()
  }
  
  fileprivate func fetchData() {
    
    activityIndicator.startAnimating()
    
    NetworkService.shared.fetchCountryDetails(countryId: countryId) { [unowned self] (provinces, err) in
      self.provinces = provinces ?? []
      
      // Used to demonstarte that the laoding spinner is present and functional
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
  
  fileprivate func updateUIWithNetworkResults(){
    activityIndicator.stopAnimating()
    if provinces.count == 0 {
      // No Provinces to display
      noProvincesMsg.isHidden = false
    } else{
      noProvincesMsg.isHidden = true
      collectionView.isHidden = false
      collectionView.reloadData()
    }
  }
  
  fileprivate func updateUIWithNetworkError(){
    collectionView.isHidden = true
    errorVerticalStackView.isHidden = false
    activityIndicator.stopAnimating()
  }
  
}

extension CountryDetailsViewController: UICollectionViewDelegate{
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let province = provinces[indexPath.item]
    
    let querySearch = "\(province.Name), \(countryName)"
    MapService.shared.setMapToLocation(mapView: mapView, querySearch: querySearch, annotationTitle: province.Name, zoomLatitudeMult: 2, zoomLongitudeMult: 2)
  }
}

extension CountryDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return provinces.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LocationCell
    let province = provinces[indexPath.item]
    cell.nameLbl.text = province.Name
    cell.flagImageView.sd_setImage(with:URL(string: countryFlagURL) )
    return cell
  }
}

extension CountryDetailsViewController: UICollectionViewDelegateFlowLayout{
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
}

