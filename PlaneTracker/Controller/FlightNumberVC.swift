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
import SkyFloatingLabelTextField

class FlightNumberVCViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var planes = [Plane]()
    var airports = [Airport]()
    var planesUrl = "https://aviation-edge.com/v2/public/flights?key=30feff-e974a7&limit=100"
    var airportUrl = "https://aviation-edge.com/v2/public/airportDatabase?key=30feff-e974a7&codeIataAirport="
    var locationManager = CLLocationManager()
    
    
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
    @IBOutlet weak var flightInformationMenu: UIView!
    @IBOutlet weak var searchBar: SkyFloatingLabelTextFieldWithIcon!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.flightInformationMenu.alpha = 0
        searchBar.delegate = self
        myMap.delegate = self
        locationManager.delegate = self
        
        
        //lblFlightNumber.text = flightNumber
        //specificPlanesUrl += flightNumber
        getFlights(url: planesUrl)
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        //        updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (Timer) in
        //self.getFlights(url: self.specificPlanesUrl)
        //})
        
        let images: [UIImage] = [#imageLiteral(resourceName: "arrow-1"), #imageLiteral(resourceName: "arrow-2"), #imageLiteral(resourceName: "arrow-3")]
        imgArrow.image = UIImage.animatedImage(with: images, duration: 1)
    }
    
    // MARK: - Function
    
    // Requesting all available airports, returns json
    func getFlights(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let flightsJson = JSON(value)
                print(flightsJson)
                var i = 0
                for (index ,item):(String, JSON) in flightsJson {
                    if(index == String(i)){
                        let depair          = item["departure"]["iataCode"].string!
                        let arrair          = item["arrival"]["iataCode"].string!
                        let flightNumber    = item["flight"]["iataNumber"].string!
                        let flightAirline   = item["airline"]["iataCode"].string!
                        let status          = item["status"].string!
                        let speed           = item["speed"]["vertical"].intValue
                        let latitude        = item["geography"]["latitude"].intValue
                        let longitude       = item["geography"]["longitude"].intValue
                        let altitude        = item["geography"]["altitude"].intValue
                        
                        print(flightNumber)
                        let plane = Plane(depair: depair, arrair: arrair, flightNumber: flightNumber, flightAirline: flightAirline, status: status, speed: speed, latitude: latitude, longitude: longitude, altitude: altitude)
                        
                        self.planes.append(plane)
                        
                        self.setPlanePosition(plane: plane)
                        
                        i = i+1
                    }
                }
                
            case .failure(_):
                print("Could not fetch flights")
            }
        }
    }
    
    func buildInfoBox(selectedFlight : Plane) {
        let arrivalCode = selectedFlight.arrair!
        let departureCode = selectedFlight.depair!
        
        if(self.lblStatus.text == "en-route"){
            self.lblStatus.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            self.lblStatus.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        getFlightAirportInfo(url1: arrivalCode, url2: departureCode)
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
                
                for (_,item):(String, JSON) in airportJson {
                    self.lblArrival.text = item["nameAirport"].string
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
                
                for (_,item):(String, JSON) in airportJson {
                    self.lblDeparture.text = item["nameAirport"].string
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Internet connection failed", message: "We could not establish a connection to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
    
    func setPlanePosition(plane : Plane){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(plane.latitude), longitude: CLLocationDegrees(plane.longitude))
        annotation.title = plane.flightNumber
        annotation.subtitle = ("\(plane.flightAirline!) - \(plane.status!)")
        myMap.addAnnotation(annotation)
    }
    
    func handleMenu(){
        //show menu
        buildInfoBox(selectedFlight: planes[1])
        UIView.animate(withDuration: 0.5) {
            self.flightInformationMenu.alpha = 1
        }
    }
    
    func unhandleMenu(){
        //show menu
        buildInfoBox(selectedFlight: planes[1])
        UIView.animate(withDuration: 0.5) {
            self.flightInformationMenu.alpha = 0
        }
    }
    
    // Hide keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
        handleMenu()
        return true
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        handleMenu()
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        unhandleMenu()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000000, longitudinalMeters: 10000000)
        
        myMap.setRegion(coordinateRegion, animated: true)
        
        locationManager.stopUpdatingLocation()
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

