//
//  ViewController.swift
//  disasterTracker
//
//  Created by Gaelle Muller-Greven on 10/19/18.
//  Copyright © 2018 Gaelle Muller-Greven. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var myMap: MKMapView!
    //@IBOutlet weak var successfullyReportedLabel: UILabel!
    @IBOutlet var successfullyReportedLabel: UILabel!
    
    private var lat = Double()
    private var lon = Double()
    private var alt = Double()
    private var time = Date()
    var hiddenBool = Bool()

    private var device_id = String(describing: UIDevice.current.identifierForVendor!)

    let manager = CLLocationManager()
    
    func getLatitude() {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        myMap.setRegion(region, animated: true)
        
        self.myMap.showsUserLocation = true
        
        lat = location.coordinate.latitude
        print(lat)
        lon = location.coordinate.longitude
        print(lon)
        alt = location.altitude
        print(alt)
        time = location.timestamp
        print(time)
        
        print(device_id)
        
        
    }
    
    @IBAction func reportFireBtn(_ sender: UIButton) {

        print("BUTTON HAS BEEN CLICKED !")
        
        //successfullyReportedLabel.isHidden = false
        
            let json: [String: Any] = [
                "location" :
                [
                        "latitude" : lat,
                        "longitude" : lon
                ],
                "device_id": device_id,
                "time": String(describing: time)
            ]
            
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                let url = NSURL(string: "https://starflock.herokuapp.com/fires")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                //request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        //self.statusCode2 = httpResponse.statusCode
                        let statusCode = httpResponse.statusCode
                        print(statusCode)
                        if (statusCode == 200 || statusCode == 201) {
                            self.hiddenBool = false
                            print(self.hiddenBool)
                            
                            DispatchQueue.main.async {
                                self.successfullyReportedLabel.isHidden = false
                            }
                            
                            //self.successfullyReportedLabel.isHidden = false
                            //self.successfullyReportedLabel.setNeedsDisplay()
                        }
                    }
                    
                    //print(hiddenBool)
                    //successfullyReportedLabel.isHidden = hiddenBool
                    
//                    if error != nil{
//                        print("Error1 -> \(String(describing: error))")
//                        return
//                    }
//                    do {
//                        let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
//                        print("Result -> \(String(describing: result))")
//                        
//                    } catch {
//                        print("Error2 -> \(error)")
//                    }
                }
                
                task.resume()
            } catch {
                print(error)
            }
        

        successfullyReportedLabel.isHidden = hiddenBool
    }
    
    //let statusCode2 = reportFireBtn(<#T##ViewController#>)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        hiddenBool = true
        self.successfullyReportedLabel.isHidden = hiddenBool
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

