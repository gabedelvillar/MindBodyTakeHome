//
//  Service.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/9/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import Foundation

class Service{
  static let shared = Service() //Singleton
  
  func fetchCountries(completion: @escaping ([Country]?, Error?) -> ()){
    let jsonUrlString = "https://connect.mindbodyonline.com/rest/worldregions/country"
    
    guard let url = URL(string: jsonUrlString) else {return}
    
    URLSession.shared.dataTask(with: url) { (data, response, err) in
      // check for errors when fetching data
      if let err = err {
        print("Error fetching data: ", err)
        return
      }
      
      // else: success, now decode the data
      
      guard let data = data else {return}
      
      do {
        let countries = try JSONDecoder().decode([Country].self, from: data)
        completion(countries, nil)
      } catch let jsonErr {
        print("Failed to decode json: ", jsonErr)
        completion(nil, jsonErr)
      }
      
    }.resume()
  }
}