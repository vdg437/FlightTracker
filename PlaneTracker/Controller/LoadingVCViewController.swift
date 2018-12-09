//
//  LoadingVCViewController.swift
//  PlaneTracker
//
//  Created by van der Goot Dave on 06/12/2018.
//  Copyright © 2018 van der Goot Dave. All rights reserved.
//

import UIKit
import Alamofire
import SearchTextField
import SwiftyJSON
import CoreData


class LoadingVCViewController: UIViewController {
    
    let allAirportsUrl = "https://aviation-edge.com/v2/public/airportDatabase?key=30feff-e974a7"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var planesList = [Plane]()
    var airports   = [Airport]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAirport(url: allAirportsUrl)
    }
    
    
    // MARK: - Navigation
    
    // MARK: - Functions
    
    // Requesting all available airports, returns json
    func getAirport(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let airportsJson = JSON(value)
                var i = 0
                for (index,item):(String, JSON) in airportsJson {
                    if(String(i) == index){
                        let name        = item["nameAirport"].string!
                        let iataCode    = item["codeIataAirport"].string!
                        let country     = item["nameCountry"].string!
                        let latitude    = item["latitudeAirport"].doubleValue
                        let longitude   = item["longitudeAirport"].doubleValue
                        let isoCode     = item["codeIso2Country"].string!
                        
                        let airport = Airport(context: self.context)
                        airport.country     = country
                        airport.iataCode    = iataCode
                        airport.isoCode     = isoCode
                        airport.latitude    = latitude
                        airport.longitude   = longitude
                        airport.name        = name
                        
                        self.airports.append(airport)
                        self.saveAirports()
                        print(i)
                        if(i == 10050){
                            self.performSegue(withIdentifier: "segueToApp", sender: nil)
                        }
                    }
                    i = i+1
                }
                
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
    
    
    func saveAirports(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}
