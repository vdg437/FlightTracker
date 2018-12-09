//
//  airports.swift
//  PlaneTracker
//
//  Created by van der Goot Dave on 26/11/2018.
//  Copyright © 2018 van der Goot Dave. All rights reserved.
//

import Foundation
import Alamofire

struct Airport{
    //MARK: properties
    let name : String!
    let iataCode : String!
    let country : String!
    let latitude : Double!
    let longitude : Double!
    let isoCode : String!
    
    
    init(name : String, iataCode : String, country : String, latitude : Double, longitude : Double, isoCode : String){
        self.name      = name
        self.iataCode  = iataCode
        self.country   = country
        self.latitude  = latitude
        self.longitude = longitude
        self.isoCode   = isoCode
    }
}
