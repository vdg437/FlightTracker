//
//  FlightNumberVCViewController.swift
//  PlaneTracker
//
//  Created by van der Goot Dave on 29/11/2018.
//  Copyright © 2018 van der Goot Dave. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FlightNumberVCViewController: UIViewController {
    
    var flightNumber : String! = nil
    var specificPlanesUrl = "https://aviation-edge.com/v2/public/flights?key=30feff-e974a7&flightIata="
    
    
    // MARK: - Outlet
    @IBOutlet weak var lblFlightNumber: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDeparture: UILabel!
    @IBOutlet weak var lblArrival: UILabel!
    @IBOutlet weak var lblETA: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblPlane: UILabel!
    @IBOutlet weak var lblAirline: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblFlightNumber.text = flightNumber
        specificPlanesUrl += flightNumber
        
        getFlights(url: specificPlanesUrl)
    }
    
    // MARK: - Function
    func getFlights(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let flightJson = JSON(value)
                
                for (index,item):(String, JSON) in flightJson {
                    print(" Group: \(index) & Item: \(item)")
                    
                    self.lblArrival.text      = item["arrival"]["icaoCode"].string
                    self.lblDeparture.text    = item["departure"]["icaoCode"].string
                    self.lblStatus.text       = item["status"].string
                    self.lblSpeed.text        = item["speed"]["horizontal"].stringValue
                    self.lblPlane.text        = item["aircraft"]["icaoCode"].stringValue
                    self.lblETA.text          = "Not Available" //item[""][""].stringValue
                    self.lblAirline.text      = item["airline"]["iataCode"].stringValue
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
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
