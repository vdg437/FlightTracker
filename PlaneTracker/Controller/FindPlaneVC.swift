//
//  FindPlaneVC.swift
//  PlaneTracker
//
//  Created by van der Goot Dave on 25/11/2018.
//  Copyright © 2018 van der Goot Dave. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FindPlaneVC: UIViewController {
    
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let allPlanesUrl = "https://aviation-edge.com/v2/public/[ENDPOINT]?key=30feff-e974a7&limit=30000"
    let allAirportsUrl = "https://aviation-edge.com/v2/public/airportDatabase?key=30feff-e974a7"
    var airportList = [Airport]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getAirport(url: allAirportsUrl)
        
    }
    
    // MARK: - Functions
    
    // Requesting all available airports, returns json
    func getAirport(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let airportsJson = JSON(value)
                
                for (_,item):(String, JSON) in airportsJson {
                    let name        = item["nameAirport"].string
                    let iataCode    = item["codeIataAirport"].string
                    let country     = item["nameCountry"].string
                    
                    self.airportList.append(Airport(name: name!, iataCode: iataCode!, country: country!))
                }
                self.indicator.isHidden.toggle()
                self.lblData.isHidden.toggle()
                print(self.airportList[0].name!, self.airportList[0].iataCode!, self.airportList[0].country!)
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
            
            /*
             // MARK: - Navigation
             
             // In a storyboard-based application, you will often want to do a little preparation before navigation
             override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             // Get the new view controller using segue.destination.
             // Pass the selected object to the new view controller.
             }
             */
    }
}
