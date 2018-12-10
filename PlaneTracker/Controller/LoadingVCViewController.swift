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
import UICircularProgressRing


class LoadingVCViewController: UIViewController {
    
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    let allAirportsUrl = "https://aviation-edge.com/v2/public/airportDatabase?key=30feff-e974a7"
    let airlinesUrl = "https://aviation-edge.com/v2/public/airlineDatabase?key=30feff-e974a7"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var planesList = [Plane]()
    var airports   = [Airport]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAirport(url: allAirportsUrl)
        progressBar.setProgress(0, animated: false)
        showProgress()
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
    
    func showProgress(){
        UIView.animate(withDuration: 23.0) {
            self.progressBar.setProgress(1.0, animated: true)
        }
    }
    
    // Get all available airlines
    // Requesting all available airports, returns json
    func getAirlines(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let airportsJson = JSON(value)
                var i = 0
                for (index,item):(String, JSON) in airportsJson {
                    if(String(i) == index){
                        let name        = item["nameAirline"].string!
                        let iataCode    = item["codeIataAirline"].string!
                        let country     = item["nameCountry"].string!
                        
                        let airline = Airline(context: self.context)
                        airline.nameCountry     = country
                        airline.codeIata    = iataCode
                        airline.name        = name
                        
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
