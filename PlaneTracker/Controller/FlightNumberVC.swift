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
    var annotations = [MKPointAnnotation]()
    var planesUrl = "https://aviation-edge.com/v2/public/flights?key=30feff-e974a7&limit=10000"
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
                var i = 0
                for (index ,item):(String, JSON) in flightsJson {
                    if(index == String(i)){
                        let depair          = item["departure"]["iataCode"].string!
                        let arrair          = item["arrival"]["iataCode"].string!
                        let flightNumber    = item["flight"]["iataNumber"].string!
                        let flightAirline   = item["airline"]["iataCode"].string!
                        let status          = item["status"].string!
                        let speed           = item["speed"]["vertical"].intValue
                        let latitude        = item["geography"]["latitude"].floatValue
                        let longitude       = item["geography"]["longitude"].floatValue
                        let altitude        = item["geography"]["altitude"].floatValue
                        
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
        
        lblFlightNumber.text = selectedFlight.flightNumber!
        lblSpeed.text = String(selectedFlight.speed)
        lblAirline.text = selectedFlight.flightAirline
        
        
        lblStatus.text = selectedFlight.status
        if(selectedFlight.status == "en-route"){
            self.lblStatus.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            self.lblStatus.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else if(selectedFlight.status == "started"){
            self.lblStatus.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            self.lblStatus.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else if(selectedFlight.status == "landed"){
            self.lblStatus.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            self.lblStatus.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else if(selectedFlight.status == "unknown"){
            self.lblStatus.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            self.lblStatus.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else if(selectedFlight.status == "crashed"){
            self.lblStatus.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            self.lblStatus.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        getFlightAirportInfo(arrivalAirport: arrivalCode, departureAirport: departureCode)
    }
    
    
    func getFlightAirportInfo(arrivalAirport: String, departureAirport: String){
        getArrivalAirport(url: (airportUrl+arrivalAirport))
        getDepartureAirport(url: (airportUrl+departureAirport))
    }
    
    func getArrivalAirport(url: String){
        print("+++++++++++++ Departure : \(url)")
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let airportJson = JSON(value)
                
                for (_,item):(String, JSON) in airportJson {
                    let nameAirport = item["nameAirport"].string
                    let codeIata = item["codeIataAirport"].string
                    let latitude = item["latitudeAirport"].doubleValue
                    let longitude = item["longitudeAirport"].doubleValue
                    let country = item["nameCountry"].string
                    let isoCode = item["codeIso2Country"].string
                    
                    if(nameAirport != nil  && codeIata != nil && country != nil && isoCode != nil){
                        self.airports.append(Airport(name: nameAirport!, iataCode: codeIata!, country: country!, latitude: latitude, longitude: longitude, isoCode: isoCode!))
                    }
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
    
    func getDepartureAirport(url: String){
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
        annotations.append(annotation)
        myMap.addAnnotation(annotation)
    }
    
    func handleMenu(plane : Plane){
        //show menu
        buildInfoBox(selectedFlight: plane)
        UIView.animate(withDuration: 0.5) {
            self.flightInformationMenu.alpha = 1
        }
    }
    
    func unhandleMenu(){
        //show menu
        UIView.animate(withDuration: 0.5) {
            self.flightInformationMenu.alpha = 0
        }
    }
    
    // Hide keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
        //handleMenu()
        return true
    }
    
    func getSelectedPlane(flightNumber : String, longitude : Float, latitude : Float) -> Plane?{
        var fetchedPlane : Plane?
        planes.forEach {if($0.flightNumber == flightNumber){
            fetchedPlane = $0
            }}
        return fetchedPlane
    }
    
    func showRoute(plane : Plane){
        var locations = [CLLocationCoordinate2D]()
        
        for airport in airports{
            print(airports.count)
        }
        
//        airports.forEach {
//            print($0)
//            print("Plane iataCode: \($0.iataCode) - \(plane.arrair)")
//            if($0.iataCode == plane.arrair){
//            locations.append(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude))
//            print("COORDINATES ROUTE Arrival: \($0.longitude) - \($0.latitude)")
//            }
//        }
        
        airports.forEach {if($0.iataCode == plane.depair){
            locations.append(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude))
            print("COORDINATES ROUTE Departing: \($0.longitude) - \($0.latitude)")
            }}
        
        
        
        let polyline = MKPolyline(coordinates: locations, count: locations.count)
        myMap.addOverlay(polyline)
    }
    
    // MARK: - Map controlls
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let title = view.annotation!.title!
        let longitude = view.annotation!.coordinate.longitude
        let latitude = view.annotation!.coordinate.latitude
        
        let plane = getSelectedPlane(flightNumber: title!, longitude: Float(longitude), latitude: Float(latitude))
        handleMenu(plane: plane!)
        
        showRoute(plane: plane!)
        
        let annotationsToRemove = myMap.annotations.filter { $0 !== view.annotation }
        
        for annotation in annotationsToRemove{
            mapView.view(for: annotation)?.isHidden = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        unhandleMenu()
        let annotationsToShow = myMap.annotations.filter { $0 !== view.annotation }
        for annotation in annotationsToShow{
            mapView.view(for: annotation)?.isHidden = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000000, longitudinalMeters: 10000000)
        
        myMap.setRegion(coordinateRegion, animated: true)
        
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
            polylineRenderer.lineWidth = 5
            polylineRenderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            return polylineRenderer
        }
        return MKPolylineRenderer(overlay: overlay)
    }
    
//    func reloadAnnotations(){
//        let allAnnotations = self.myMap.annotations
//        self.myMap.removeAnnotations(allAnnotations)
//
//        for annotation in allAnnotations {
//            self.mapView.addAnnotation(annotation)
//        }
//    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

