//
//  ViewController.swift
//  FFParseTvOS
//
//  Created by Jorge Mendoza on 10/11/15.
//  Copyright © 2015 Jorge Mendoza. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FFParseRequestDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Parse Calls
        let parse:FFParseRequest = FFParseRequest()
        //In this array add the name of the fiels in your parse.com object not the name of the object
        let includeArr = ["obj","media","userId"]
        parse.delegate = self
        
        /*
        
            Try one of this at the time.
        
        */
        
        //Retrive a Collection of Parse.com plane objects
        parse.retriveParseObjectByClassName("Post", include: nil)
        
        //Retrive a Collection Parse.com with it's relational fields
        parse.retriveParseObjectByClassName("Post", include: includeArr)
        
        //Retrieve an Object by Object Id and Class Name
        parse.retriveParseObjectById("Post", objectId: "p0rKbcZOjX", include:nil)
        
        //Retrieve an Object by Object Id and Class Name with relational data
        parse.retriveParseObjectById("Post", objectId: "p0rKbcZOjX", include:nil)
        
        //Update a parse Object
        parse.updateObject("Post", objectId: "p0rKbcZOjX", values: ["content":"This is the new updated content!!", "text":"This is the updated Text!!","number":237])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - FFParseRequestDelegate
    
    func fillDataSource(res: FFObject) {
        
        //Do your stuff with your Parse.com response
        print("Parse Response: \(res)")
    }


}

