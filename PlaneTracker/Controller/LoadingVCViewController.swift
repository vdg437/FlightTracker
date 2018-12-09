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


class LoadingVCViewController: UIViewController {
    
    let allPlanesUrl = "https://aviation-edge.com/v2/public/flights?key=30feff-e974a7"
    let allAirportsUrl = "https://aviation-edge.com/v2/public/airportDatabase?key=30feff-e974a7"
    
    var airportList = [Airport]()
    var planesList = [Plane]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //getAirport(url: allAirportsUrl)
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PageVC{
            let vc = segue.destination as? PageVC
            vc?.planes = planesList
            vc?.airports = airportList
        }
    }
    
    // MARK: - Functions
    // Requesting all available airports, returns json
    func getAirport(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let airportsJson = JSON(value)
                for (_,item):(String, JSON) in airportsJson {
                    let name        = item["nameAirport"].string!
                    let iataCode    = item["codeIataAirport"].string!
                    let country     = item["nameCountry"].string!
                    
                    self.airportList.append(Airport(name: name, iataCode: iataCode, country: country))
                }
                
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
}
