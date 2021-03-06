import UIKit
import MapKit
import CoreLocation
//import SwiftyJSON
//import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet var successfullyReportedLabel: UILabel!
    
    private var lat = Double()
    private var lon = Double()
    private var alt = Double()
    private var time = Date()
    var hiddenBool = Bool()
    var zoomValue = 150
    
    @IBAction func zoomBtn(_ sender: UIStepper) {
        
        if Int(sender.value) > zoomValue {
            
            var region: MKCoordinateRegion = myMap.region
            region.span.latitudeDelta /= 2.0
            region.span.longitudeDelta /= 2.0
            myMap.setRegion(region, animated: true)
            
        }
        if Int(sender.value) < zoomValue {
            
            var region: MKCoordinateRegion = myMap.region
            region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
            myMap.setRegion(region, animated: true)
            
        }
        
        zoomValue = Int(sender.value)
        
    }
    
    
    private var device_id = String(describing: UIDevice.current.identifierForVendor!)
    
    let manager = CLLocationManager()
    
    func getLatitude() {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.03, 0.03)
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
        
        manager.stopUpdatingLocation()
        
        
    }
    
    @IBAction func reportFireBtn(_ sender: UIButton) {
        
        var json: [String: Any] = [
            "location" :
                [
                    "latitude" : lat,
                    "longitude" : lon,
                    "altitude" : alt
            ],
            "device_id": device_id,
            "time": String(describing: time)
        ]
        
        var idToken = UserDefaults.standard.string(forKey: "idToken")
        if idToken != nil {
            json["idToken"] = idToken.unsafelyUnwrapped
        }
        
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
                    let statusCode = httpResponse.statusCode
                    print(statusCode)
                    if (statusCode == 200 || statusCode == 201) {
                        self.hiddenBool = false
                        print(self.hiddenBool)
                        DispatchQueue.main.async {
                            self.successfullyReportedLabel.isHidden = false
                        }
                    }
                }
                
            }
            
            task.resume()
        } catch {
            print(error)
        }
        
        
        successfullyReportedLabel.isHidden = hiddenBool

        
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        myMap.reloadInputViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        myMap.reloadInputViews()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        hiddenBool = true
        self.successfullyReportedLabel.isHidden = hiddenBool
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
        //var firesData: [String] = []
        
        /*let firesData = [
            ["lat": 41.412156, "lon": -81.862931],
            ["lat": 41.412157, "lon": -81.862932],
            ["lat": 41.512156, "lon": -81.862931]
        ]*/
        
        let myUrl = NSURL(string:"https://starflock.herokuapp.com/fires")!
        URLSession.shared.dataTask(with: myUrl as URL) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    print(String(bytes: data.unsafelyUnwrapped, encoding: String.Encoding.utf8))
                    let json = try JSONSerialization.jsonObject(with: data.unsafelyUnwrapped, options: []) as? [[String:Any]]
                    print(json)
                    if json != nil {
                        for report in json.unsafelyUnwrapped ?? [] {
                            print("------------------")
                            print(report)
                            let fireLat = Double(report["lat"]! as! String) ?? 0
                            let fireLon = Double(report["lon"]! as! String) ?? 0
                            
                            DispatchQueue.main.async {
                                let annotation = MKPointAnnotation()
                                annotation.coordinate.latitude = fireLat
                                annotation.coordinate.longitude = fireLon
                                
                                print("ADDING")
                                print(annotation.coordinate.latitude, annotation.coordinate.longitude)
                                
                                
                                
                                self.myMap.addAnnotation(annotation)
                                var fireLoc = [MKPointAnnotation]()

                                fireLoc.append(annotation)
                                self.myMap.showAnnotations(fireLoc, animated: true)
                            }
                            
                        }
                    } else {
                        print(json)
                        print("JSON is not an array of dictionaries")
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            }.resume()
    }
    
}
