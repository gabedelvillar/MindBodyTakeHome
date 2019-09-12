//
//  CountryDetailsViewController.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/10/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit
import MapKit

class CountryDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  fileprivate let cellId = "CellId"
  fileprivate let countryName: String
  fileprivate let countryFlagURL: String
  fileprivate let countryId: Int
  fileprivate var provinces = [Province]()
  
  init(countryName: String, countryId: Int, countryFlagURL: String){
    self.countryName = countryName
    self.countryId = countryId
    self.countryFlagURL = countryFlagURL
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
  
  let mapView: MKMapView =  {
    let map = MKMapView()
    
    return map
  }()
  
  let noProvincesMsg = UILabel(text: "No Provinces for this Country to Display", font: .systemFont(ofSize: 18, weight: .bold), numberOfLines: 2)
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return provinces.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProvinceCell
    let province = provinces[indexPath.item]
    cell.nameLbl.text = province.Name
    cell.flagImageView.sd_setImage(with:URL(string: countryFlagURL) )
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let province = provinces[indexPath.item]
    
    
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = "\(province.Name), \(countryName)"
    
    let activeSearch = MKLocalSearch(request: searchRequest)
    
    activeSearch.start { (response, err) in
      if let err = err {
        print("There was an error in searching for location: ", err)
        return
      }
      
      // remove previous annotations
      let annotations = self.mapView.annotations
      self.mapView.removeAnnotations(annotations)
      
      
      // get the data
      let latitude = response?.boundingRegion.center.latitude
      let longitude = response?.boundingRegion.center.longitude
      
      // create annotation
      let annotation  = MKPointAnnotation()
      annotation.title = province.Name
      
      if let latitude = latitude, let longitude = longitude {
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.mapView.addAnnotation(annotation)
        
        
        // Zoom in on annotation
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.setRegion(region, animated: true)
      }
      
      
    }

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
    
    view.addSubview(mapView)
    mapView.translatesAutoresizingMaskIntoConstraints = false
    
    mapView.constrainHeight(constant: 180)
    mapView.constrainWidth(constant: view.frame.width)
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
      ])
    
    setMapToCountry()
    
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
  
  fileprivate func setMapToCountry(){
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = countryName
    
    let activeSearch = MKLocalSearch(request: searchRequest)
    
    activeSearch.start { (response, err) in
      if let err = err {
        print("There was an error in searching for location: ", err)
        return
      }
      
      // remove previous annotations
      let annotations = self.mapView.annotations
      self.mapView.removeAnnotations(annotations)
      
      
      // get the data
      let latitude = response?.boundingRegion.center.latitude
      let longitude = response?.boundingRegion.center.longitude
      
      // create annotation
      let annotation  = MKPointAnnotation()
      annotation.title = self.countryName
      
      if let latitude = latitude, let longitude = longitude {
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.mapView.addAnnotation(annotation)
        
        
        // Zoom in on annotation
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.setRegion(region, animated: true)
      }
      
      
    }
  }
  
  
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
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
      ])
    
    //collectionView.fillSuperview()
  }
}
