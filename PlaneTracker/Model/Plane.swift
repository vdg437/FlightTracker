//
//  Planes.swift
//  PlaneTracker
//
//  Created by van der Goot Dave on 25/11/2018.
//  Copyright © 2018 van der Goot Dave. All rights reserved.
//

import Foundation
import Alamofire

class Plane{
    //MARK: private properties
    var depair : String!
    var arrair: String!
    var flightNumber: String!
    var flightAirline: String!
    var status: String!
    var speed:  Int!
    var latitude: Float!
    var longitude: Float!
    var altitude: Float!
    
    init(depair : String, arrair : String, flightNumber : String, flightAirline : String, status : String, speed : Int, latitude : Float, longitude : Float, altitude : Float){
        self.depair         = depair
        self.arrair         = arrair
        self.flightNumber   = flightNumber
        self.flightAirline  = flightAirline
        self.status         = status
        self.speed          = speed
        self.latitude       = latitude
        self.longitude      = longitude
        self.altitude       = altitude
    }
}
