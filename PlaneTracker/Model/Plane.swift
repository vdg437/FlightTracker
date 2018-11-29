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
    
    private var depair : String!
    private var arrair: String!
    private var flightNumber: String!
    private var flightAirline: String!
    private var status: String!
    private var speed:  Int!
    private var latitude: Int!
    private var longitude: Int!
    private var altitude: Int!
    private var airline: String!
    
    
    func getPlaneInformation(url: String) {
        
        Alamofire.request(url).responseJSON { (response) in
            
            if response.result.isSuccess {
                let result = response.result.value!
                //print(result)
                
                // parsing the JSON ( = dictionary of dictionaries
                if let myDict = result as? Dictionary<String, Any> {
                    
                    // flightNumber
                    if let flight = myDict["flight"] as? [Dictionary<String,String>] {
                        if let flight_flightNumber = flight[2]["number"]{
                            self.flightNumber = flight_flightNumber
                            print(flight_flightNumber)
                        }
                    }
                    
                    // flightAirline
                    if let airline = myDict["airline"] as? [Dictionary<String,String>] {
                        if let airline_code = airline[1]["icaoCode"]{
                            self.flightAirline = airline_code
                            print(airline_code)
                        }
                    }
                } else {
                    print("Error with request \(String(describing: response.result.error))")
                }
            }
        }
    }
}
