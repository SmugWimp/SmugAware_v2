//
//  gagActivity.swift
//  Guam Airport Guide
//
//  Created by SmugWimp on 3/16/19.
//  Copyright © 2019 Marianas GPS, LLC. All rights reserved.
//
/*
 
 {
 "hex": "a47809",
 "squawk": "2751",
 "flight": "UAL183  ",
 "lat": 13.264315,
 "lon": 142.936803,
 "validposition": 1,
 "altitude": 31550,
 "vert_rate": 1920,
 "track": 266,
 "validtrack": 1,
 "speed": 456,
 "messages": 2324,
 "seen": 255,
 "mlat": false
 }
 
 */

import Foundation
import UIKit
import MapKit

//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------

// ---------------------------------------------------------------------
class Flights: Codable {
    var flight: String?
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
// ---------------------------------------------------------------------

class activity_VC: UIViewController, MKMapViewDelegate {
    // -----------------------------------------------------------------------
    // -----------------------------------------------------------------------
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var bannerView: UIView!
    
    // You're going to want the initial location to be closer to where you are, not me.
    let initialLocation = CLLocation(latitude: 13.4, longitude: 144.8)
    let regionRadius: CLLocationDistance = 150000
    let activityURL = "https://www.somedomain.com/path/to/data.json";
    let reachability = Reachability()
    var flightlist = [Flights]()
    var flightTimer = Timer()

    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // ---------------------------------------------------------------------
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if reachability.isConnectedToNetwork() {
            // --------------------------------------------------------------------
            myMapView.delegate = self
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius, regionRadius)
            // placeAnnotationOnMap()
            myMapView.setRegion(coordinateRegion, animated: true)
            myMapView.showsUserLocation = false
            myMapView.mapType = MKMapType.standard
            // --------------------------------------------------------------------
            
            flightTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(placeAnnotationOnMap), userInfo: nil, repeats: true)
            // placeAnnotationOnMap()
            // --------------------------------------------------------------------
        } else {
            // --------------------------------------------------------------------
            let alertBox = UIAlertController(title: "No Network Found", message: "We don't seem to detect a network. This application requires a network connection to operate.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in print("you have pressed the ok button")})
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
            // here is where you test for location, and if it has a value, or throw it out (typically 0,0 coordinates, near africa)
            if (myLat <= 0)||(myLon <= 0) {
//                print("not this one.")
//                print(Flights.flight!)
            } else {
                let planeLoc = CLLocationCoordinate2D(latitude: myLat, longitude: myLon)
                let planePin = planeObject(title: Flights.flight!, track: Flights.track!, coordinate: planeLoc)
                myMapView.addAnnotation(planePin)
//                print(Flights.flight!)
            }
        }
    }
    
    
    
    // --------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------

    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------

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
                // get ready, here it comes...
                self.flightlist = try decoder.decode([Flights].self, from: dataResponse)
                // you can relax now; There it goes...
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
        if (annotation is planeObject) {
            // print("comes a Plane Object")            
            // print(myAnnotation.track)
            // print(myAnnotation.title!)
            // print(myAnnotation.coordinate.longitude)
        }
        
        let annotationIdentifier = "annoID"
        var myAnnotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if myAnnotationView == nil {
            myAnnotationView = MKAnnotationView(annotation: myAnnotation, reuseIdentifier: annotationIdentifier)
			//			
            myAnnotationView?.image = UIImage(named: "planeAnnotation")
            myAnnotationView?.canShowCallout = true
            let myFloat = CGFloat(myAnnotation.track * .pi/180)
            myAnnotationView?.transform = CGAffineTransform(rotationAngle: myFloat)
        } else {
            myAnnotationView?.image = UIImage(named: "planeAnnotation")
            myAnnotationView?.canShowCallout = true
            let myFloat = CGFloat(myAnnotation.track * .pi/180)
            myAnnotationView?.transform = CGAffineTransform(rotationAngle: myFloat)
        }
        return  myAnnotationView
    }
    
    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    func mapView (_ map:MKMapView, didAddAnnotationViews views:NSArray) {}

    
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
    // -----------------------------------------------------------------------
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
}


