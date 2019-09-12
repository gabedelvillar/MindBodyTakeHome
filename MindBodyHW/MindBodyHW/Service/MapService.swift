//
//  MapService.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/12/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import UIKit
import MapKit

class MapService{
  
  static let shared = MapService()

  func setMapToLocation(mapView: MKMapView, querySearch: String, annotationTitle: String, zoomLatitudeMult: CLLocationDegrees, zoomLongitudeMult: CLLocationDegrees){
  
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = querySearch
  
    let activeSearch = MKLocalSearch(request: searchRequest)
  
    activeSearch.start { (response, err) in
      if let err = err {
        print("There was an error in searching for location: ", err)
        return
      }
    
      // remove previous annotations
      let annotations = mapView.annotations
      mapView.removeAnnotations(annotations)
    
      // get the data
      let latitude = response?.boundingRegion.center.latitude
      let longitude = response?.boundingRegion.center.longitude
    
      // create annotation
      let annotation  = MKPointAnnotation()
      annotation.title = annotationTitle
    
      if let latitude = latitude, let longitude = longitude {
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mapView.addAnnotation(annotation)
      
        // Zoom in on annotation
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpan(latitudeDelta: zoomLatitudeMult, longitudeDelta: zoomLongitudeMult)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
      }
    }
  }
}

