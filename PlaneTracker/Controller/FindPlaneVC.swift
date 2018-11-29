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
import SearchTextField

class FindPlaneVC: UIViewController {
    
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var departingSearchTextField: SearchTextField!
    @IBOutlet weak var arrivingSearchTextField: SearchTextField!
    @IBOutlet weak var flightNumberTextField: UITextField!
    
    @IBAction func btnSearchFlights(_ sender: Any) {
        if((departingSearchTextField.text?.isEmpty)! || (arrivingSearchTextField.text?.isEmpty)!){
            if((flightNumberTextField.text?.isEmpty)!){
                // Nothing inserted
            }else{
                performSegue(withIdentifier: "segueToFlightNumberVC", sender: self)
            }
        }
    }
    let specificPlanesUrl = "http://aviation-edge.com/v2/public/flights?key=30feff-e974a7"
    
    let allAirportsUrl = "https://aviation-edge.com/v2/public/airportDatabase?key=30feff-e974a7"
    var airportList = [Airport]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Optimizing Search suggestions
        departingSearchTextField.maxNumberOfResults = 2
        arrivingSearchTextField.maxNumberOfResults = 2
        
        // Loading Airports
        getAirport(url: allAirportsUrl)
    }
    
    // MARK: - Functions
    
    // Unwind segue functions
    @IBAction func unwindToFindPlaneVC(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
    }
    
    // Requesting all available airports, returns json
    func getAirport(url: String) {
        var items = [SearchTextFieldItem]()
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
                
                // Initializing Search suggestions
                for(item):(Airport) in self.airportList{
                    items.append(SearchTextFieldItem(title: item.name, subtitle: "\(item.country) - \(item.iataCode)"))
                }
                self.departingSearchTextField.filterItems(items)
                self.arrivingSearchTextField.filterItems(items)
                
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FlightListTVC{
            
        }
        
        if segue.destination is FlightNumberVCViewController{
            let vc = segue.destination as? FlightNumberVCViewController
            vc?.flightNumber = flightNumberTextField.text
        }
    }
}
