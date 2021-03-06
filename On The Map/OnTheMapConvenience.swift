//
//  OnTheMapConvenience.swift
//  On The Map
//
//  Created by TY on 3/25/16.
//  Copyright © 2016 On The Map. All rights reserved.
//

//Convenience method to avoid code pyramid/do error checking for the client functions

import UIKit
import Foundation

extension OnTheMapClient{
    
    //Create a conenience method to easily take user input and compares it with Udacity user data
    func postSession(username: String, password: String, completionHandler: (sessionID: String?, error: NSError?) -> Void){
        print("Post session was called!")
        
        let method = Methods.Session
        let jsonBody = [ JSONBodyKeys.Udacity:[
            JSONBodyKeys.User : username,
            JSONBodyKeys.Pass : password
            ],
        ]
        //Call taskForPostMethod created in OnTheMapClient
        taskForPostMethod(method, jsonBody: jsonBody){(JSONResult, error) in
            print("taskForPost executed!")
            guard error == nil else{
                completionHandler(sessionID: nil, error: error)
                return
            }
            
            //If the matching user account is returned from the request, print the account data
            if let dictionary = JSONResult![JSONResponseKeys.Account] as? [String:AnyObject]{
                print("JSONResult yielded account:\(dictionary)")
                if let result = dictionary[JSONResponseKeys.Key] as? String {
                    print("Found sessionID: \(result)")
                    completionHandler(sessionID: result, error: nil)
                } else {
                    completionHandler(sessionID: nil, error: error)
                    print("Could not parse session.")
                }
            } else {
                completionHandler(sessionID: nil, error: error)
                print("Could not parse session.")
            }
        }
    }
    
    //Delete session token before logging out/transitioning to a new view
    func deleteSession(tabBarController: UITabBarController) {
        
        let method = Methods.Session
        
        taskForDeleteMethod(method) { (JSONResponse, error) in
            
            guard error == nil else{
                print("There was an error logging out: \(error)")
                return
            }
        }
        //Return to initial view controller
        dispatch_async(dispatch_get_main_queue(), {
            tabBarController.dismissViewControllerAnimated(true, completion: nil)
        })
        print("Logout was successful!")
    }
    
    //After user login data is verified get necessary data w/ client method
    func getUserData(userID: String, completionHandler: (result: [String]?, error: NSError?) -> Void) {
        let method = Methods.Users + userID
        
        taskForGetMethod(method) {(JSONResult, error) in
            
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            if let dictionary = JSONResult[JSONResponseKeys.User] as? [String:AnyObject] {
                /* Array for user name */
                var result = [String]()
                
                if let firstName = dictionary[JSONResponseKeys.FirstName] as? String {
                    result.append(firstName)
                    if let lastName = dictionary[JSONResponseKeys.LastName] as? String {
                        result.append(lastName)
                        completionHandler(result: result, error: nil)
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "getUserData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse user data: Last Name"]))
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getUserData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse user data: First Name"]))
                }
            }
        }
    }
}