//
//  Country.swift
//  MindBodyHW
//
//  Created by Gabriel Del VIllar on 9/10/19.
//  Copyright © 2019 gdelvillar. All rights reserved.
//

import Foundation

struct Country: Decodable {
  let ID: Int
  let Name: String
  let Code: String
  var PhoneCode: String?
}
