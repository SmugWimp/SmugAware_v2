//
//  ViewController.swift
//  SmugAware
//
//  Created by SmugWimp on 4/10/19.
//  Copyright © 2019 SmugWimp All rights reserved.
//
import Foundation
import UIKit
import MapKit
// -----------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
class Flights: Codable {
    var flight: String? // flight name (Air Force One, UA183, etc...)
    var lat: Double? // we use this
    var lon: Double? // we use this
    var track: Double? // we use this (heading in degrees)
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.flight = try container.decodeIfPresent(String.self, forKey: .flight) ?? "SW 001"
        self.lat = try container.decodeIfPresent(Double.self, forKey: .lat) ?? 0
        self.lon = try container.decodeIfPresent(Double.self, forKey: .lon) ?? 0
        self.track = try container.decodeIfPresent(Double.self, forKey: .track) ?? 0
    }
}
// -----------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
class ViewController: UIViewController, MKMapViewDelegate  {
    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var myMapView: MKMapView!
    let initialLocation = CLLocation(latitude: 13.4, longitude: 144.8)
    let regionRadius: CLLocationDistance = 150000
    // If your URL is not SSL Enabled, be sure 'Transport Security' is set to allow for that.
    let activityURL = "https://www.yourserver.com/flightaware/data.json";
    let reachability = Reachability()
    var flightlist = [Flights]()
    var flightTimer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    override func viewWillAppear(_ animated: Bool) {
        //
        // To be honest, this code should probably go into the 'viewDidLoad' method. But
        // I use this code in a tabbed app, and when the users selects another tab and
        // this one goes 'dormant' it doesn't wake up with the code in 'viewDidLoad',
        // but it DOES in viewWillAppear, so it works better 'for me'.
        //
        //
        
        if reachability.isConnectedToNetwork() {
            // --------------------------------------------------------------------
            myMapView.delegate = self
            let coordinateRegion = MKCoordinateRegion.init(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            myMapView.setRegion(coordinateRegion, animated: true)
            myMapView.showsUserLocation = false
            myMapView.mapType = MKMapType.standard
            // --------------------------------------------------------------------
            flightTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(placeAnnotationOnMap), userInfo: nil, repeats: true)
            // --------------------------------------------------------------------
        } else {
            // --------------------------------------------------------------------
            let alertBox = UIAlertController(title: "No Network Found", message: "We don't seem to detect a network. This application requires a network connection to operate.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in print("you have pressed the ok button")})
            alertBox.addAction(okAction)
            self.present(alertBox,animated: true, completion: nil)
            // --------------------------------------------------------------------
        }
        // ---------------------------------------------------------------------
    }

    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    @objc func placeAnnotationOnMap() {
        myMapView.removeAnnotations(myMapView.annotations)
        getFlightData()
        for Flights in flightlist{
            let myLat = CLLocationDegrees(Flights.lat!)
            let myLon = CLLocationDegrees(Flights.lon!)
            // here is where you test for location, and if it's not valid, throw it out (typically 0,0 coordinates, near africa)
            if (myLat <= 0)||(myLon <= 0) {
            } else {
                let planeLoc = CLLocationCoordinate2D(latitude: myLat, longitude: myLon)
                let planePin = planeObject(title: Flights.flight!, track: Flights.track!, coordinate: planeLoc)
                myMapView.addAnnotation(planePin)
            }
        }
    }

    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
   func getFlightData() {
        guard let url = URL(string: activityURL) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return
            }
            do{
                let decoder = JSONDecoder()
                self.flightlist = try decoder.decode([Flights].self, from: dataResponse)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }

    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let myAnnotation = annotation as! planeObject
        let annotationIdentifier = "annoID"
        var myAnnotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if myAnnotationView == nil {
            myAnnotationView = MKAnnotationView(annotation: myAnnotation, reuseIdentifier: annotationIdentifier)
            myAnnotationView?.image = UIImage(named: "planeAnnotation")
            myAnnotationView?.canShowCallout = true
            let myFloat = CGFloat(myAnnotation.track * .pi/180)
            myAnnotationView?.transform = CGAffineTransform(rotationAngle: myFloat)
        } else {
            myAnnotationView?.image = UIImage(named: "planeAnnotation")
            let myFloat = CGFloat(myAnnotation.track * .pi/180)
            myAnnotationView?.transform = CGAffineTransform(rotationAngle: myFloat)
            myAnnotationView?.canShowCallout = true
        }
        return  myAnnotationView
    }
    
    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    override func viewWillDisappear(_ animated: Bool) {
        flightTimer.invalidate()
        myMapView.removeAnnotations(myMapView.annotations)
    }

    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
}

