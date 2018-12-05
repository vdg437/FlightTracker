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
import MapKit

class FlightNumberVCViewController: UIViewController {
    
    var flightNumber : String! = nil
    var specificPlanesUrl = "https://aviation-edge.com/v2/public/flights?key=30feff-e974a7&flightIata="
    var airportUrl = "https://aviation-edge.com/v2/public/airportDatabase?key=30feff-e974a7&codeIataAirport="
    
    
    // MARK: - Outlet
    @IBOutlet weak var lblFlightNumber: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDeparture: UILabel!
    @IBOutlet weak var lblArrival: UILabel!
    @IBOutlet weak var lblETA: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblPlane: UILabel!
    @IBOutlet weak var lblAirline: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var myMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblFlightNumber.text = flightNumber
        specificPlanesUrl += flightNumber
        
        getFlights(url: specificPlanesUrl)
        
        
        let images: [UIImage] = [#imageLiteral(resourceName: "arrow-1"), #imageLiteral(resourceName: "arrow-2"), #imageLiteral(resourceName: "arrow-3")]
        imgArrow.image = UIImage.animatedImage(with: images, duration: 1)
    }
    
    // MARK: - Function
    func getFlights(url: String) {
        var arrivalCode : String = ""
        var departureCode : String = ""
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let flightJson = JSON(value)
                
                for (index,item):(String, JSON) in flightJson {
                    print(" Group: \(index) & Item: \(item)")
                    self.lblStatus.text       = item["status"].string
                    self.lblSpeed.text        = String(round(item["speed"]["horizontal"].doubleValue*100)/100)+" km/h"
                    self.lblPlane.text        = item["aircraft"]["icaoCode"].stringValue
                    self.lblETA.text          = "Not Available"
                    self.lblAirline.text      = item["airline"]["iataCode"].stringValue
                    arrivalCode               = item["arrival"]["iataCode"].string!
                    departureCode             = item["departure"]["iataCode"].string!
                }
                self.getFlightAirportInfo(url1: arrivalCode, url2: departureCode)
                
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
    
    func getFlightAirportInfo(url1: String, url2: String){
        getArrivalAirport(url: (airportUrl+url1))
        getDestinationAirport(url: (airportUrl+url2))
    }
    
    func getArrivalAirport(url: String){
        print("+++++++++++++ Departure : \(url)")
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let airportJson = JSON(value)
                
                for (index,item):(String, JSON) in airportJson {
                    self.lblArrival.text = item["nameAirport"].string
                    
                    print("+++++++++++++ ARRIVAL : \(item["nameAirport"].string)")
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
    
    func getDestinationAirport(url: String){
        print("+++++++++++++ Departure : \(url)")
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let airportJson = JSON(value)
                
                for (index,item):(String, JSON) in airportJson {
                    self.lblDeparture.text = item["nameAirport"].string
                    print("+++++++++++++ Departure : \(item["nameAirport"].string)")
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
