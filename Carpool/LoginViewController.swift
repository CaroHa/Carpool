//
//  LoginViewController.swift
//  Carpool
//
//  Created by Eva on 02.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let current_uid = NSUserDefaults.standardUserDefaults().valueForKey("uid")
        print(current_uid)        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && FDataManager.dataService.CURRENT_USER_REF.authData != nil {
            print("LOGIN:")
            print(FDataManager.dataService.CURRENT_USER_REF)
//            print(FDataManager.dataService.CURRENT_USER_REF.valueForKey("username"))
//            print(FDataManager.dataService.CURRENT_USER_REF.valueForKey("email"))
            self.performSegueWithIdentifier("CurrentlyLoggedIn", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        
        if email != "" && password != "" {
            
            // Login with the Firebase's authUser method
            
            FDataManager.dataService.BASE_REF.authUser(email, password: password, withCompletionBlock: { error, authData in
                
                if error != nil {
                    print(error)
                    self.loginErrorAlert("Oops!", message: error.domain)
                } else {
                    
                    // Be sure the correct uid is stored.
                    print("\(authData)")
                    print("\(authData.uid)")
                    print("\(authData.valueForKey("provider"))")
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                    
                    // Enter the app!
                    
                    self.performSegueWithIdentifier("CurrentlyLoggedIn", sender: nil)
                }
            })
            
        } else {
            
            // There was a problem
            
            loginErrorAlert("Oops!", message: "Don't forget to enter your email and password.")
        }
    }
    
    func loginErrorAlert(title: String, message: String) {
        
        // Called upon login error to let the user know login didn't work.
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
