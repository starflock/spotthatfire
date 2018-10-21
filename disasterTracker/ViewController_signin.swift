//
//  ViewController_signin.swift
//  disasterTracker
//
//  Created by Gaelle Muller-Greven on 10/20/18.
//  Copyright © 2018 Gaelle Muller-Greven. All rights reserved.
//

import UIKit

class ViewController_signin: UIViewController {
    
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    
    @IBOutlet var successLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet weak var segControl: UISegmentedControl!
    
    
    
    @IBAction func signinButton(_ sender: UIButton) {

        if segControl.selectedSegmentIndex == 0 {
    
        print("----------- HERE 0 -------------")
        
        let json: [String: Any] = [
                "email" : inputEmail.text!,
                "password" : inputPassword.text!
            ]
    
    
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    
            let url = NSURL(string: "https://starflock.herokuapp.com/login")!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
    
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
    
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
    
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    print(statusCode)
                    //let statusCode = 200
                    if (statusCode == 200 || statusCode == 201) {
                        //self.hiddenBool = false
                        //print(self.hiddenBool)
                        // let json = try? JSONSerialization.jsonObject(with: data.unsafelyUnwrapped, options: [])

                        UserDefaults.standard.set(String(data: data.unsafelyUnwrapped, encoding: String.Encoding.utf8), forKey: "idToken")
                        print(UserDefaults.standard.string(forKey: "idToken") as Any)
                        DispatchQueue.main.async {
                            self.successLabel.isHidden = false
                            self.errorLabel.isHidden = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            self.performSegue(withIdentifier: "segue_signedin", sender: self)
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.errorLabel.isHidden = false
                            self.successLabel.isHidden = true

                        }
                    }
                }
            }
    
            task.resume()
        
            } catch {
                print(error)
        }

    }
       
    
    
    if segControl.selectedSegmentIndex == 1 {
    
    print("----------- HERE 1 -------------")
    
    let json: [String: Any] = [
    "email" : inputEmail.text!,
    "password" : inputPassword.text!
    ]
    
    
    do {
    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    
    let url = NSURL(string: "https://starflock.herokuapp.com/register")!
    let request = NSMutableURLRequest(url: url as URL)
    request.httpMethod = "POST"
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
    
    if let httpResponse = response as? HTTPURLResponse {
    let statusCode = httpResponse.statusCode
    //let statusCode = 200
    if (statusCode == 200 || statusCode == 201) {
    //self.hiddenBool = false
    //print(self.hiddenBool)
    
    DispatchQueue.main.async {
    self.successLabel.isHidden = false
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
    self.performSegue(withIdentifier: "segue_signedin", sender: self)
    })
    }
    }
    }
    
    task.resume()
    
    } catch {
    print(error)
    }
    
    }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        successLabel.isHidden = true
        errorLabel.isHidden = true

        // Do any additional setup after loading the view.
    }


}
