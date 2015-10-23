//
//  Functions.swift
//  FFParseTvOS
//
//  Created by Jorge Mendoza on 10/13/15.
//  Copyright © 2015 Jorge Mendoza. All rights reserved.
//

import Foundation



/**
 String Enumeration
 
 - POST:   HTTP POST Operation
 - GET:    HTTP GET Operation
 - PUT:    HTTP Put Operation
 - DELETE: HTTP DELETE Operation
 */
enum HTTPMethod:String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

/**
 
 Kind of Parse Object to be requested,
 single object, objects collections (of the same class)
 or Query complex objects
 
 
 - Collection: Array of objects
 - Query:      Custom Search
 - Single:     Specifi instance of a parse.com object with specifi ObjectId
 
 */

enum ParseRequestType {
    case Collection
    case Query
    case Single
}

/**
 *  Parse AppId and APIKey tokens
    to access the Parse.com REST API
 */

struct ParseConfig {
    let appId:String!
    let apiKey:String!
    
    init(app:String, api:String){
        self.appId = app
        self.apiKey = api
    }
}

struct ParseQuery {
    let value:AnyObject!
    let condition:String!
    let field:String!
    let objectToInclude:String?
    
    init(v:AnyObject!, c:String!, f:String!, include:String?){
        self.value = v
        self.condition = c
        self.field = f
        self.objectToInclude = include
    }
}

typealias FFObject = [String:AnyObject]

/**
 *  Build the base urls to access the parse.com REST API
    More info https://parse.com/docs/rest/
 */
struct HttpHandler {
    
    let config:ParseConfig
    let prefix = "https://"
    let parseUrlPrefix = "api.parse.com/1/classes"
    
    func parseBaseUrl() -> String {
        return self.prefix + self.parseUrlPrefix
    }
    
    func parseClassUrl(className:String) -> String {
        return self.parseBaseUrl() + "/" + className
    }
    
    func parseClassObjectById(className:String, objectId:String) -> String {
        return self.parseBaseUrl() + "/" + className + "/" + objectId
    }
    
    func parseClassCollection(className:String, include:[String]?) -> String {
        return self.parseBaseUrl() + "/" + className
    }
    
    func parseQuery(className:String, query:Dictionary<String,String>, include:[String]?) -> String {
        //Add Query conditions
        return self.parseBaseUrl() + "/" + className
    }
    
    func parseObjectWithInclude(className:String, objectId:String, include:[String]) -> String {
        return self.parseBaseUrl() + "/" + className + "/" + objectId + "?include=" + ",".StringFromArray(include)
    }
    
    init(conf:ParseConfig){
        self.config = conf
    }
}

/**
 *  Method to implement in the calling class requesting the
    parse.com data
 */
protocol FFParseRequestDelegate {
    func fillDataSource(res:FFObject)
}

/// FFParseRequest
class FFParseRequest: NSObject {
    
//    let parse:ParseConfig = ParseConfig(app: "YOUR-PARSE-APP-ID", api: "YOUR-PARSE-API-KEY")
    let parse:ParseConfig = ParseConfig(app: "1puFz88EANTHK1NY5HeAQ89csHAwcPz4hSDkA5so", api: "TfJIz5XigjZH7xRgqXPBosHB7yPcLNjslpmE2OOv")
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let queue:NSOperationQueue = NSOperationQueue()
    var delegate:FFParseRequestDelegate!
    
    /**
     Builds the parse.com URL Request with custom Header values
     with AppId and Rest API Key
     
     - parameter app:        Parse.com AppId
     - parameter api:        Parse.com API Key
     - parameter url:        Custom Parse.com REST Api Url
     - parameter httpMethod: HTTP Operation (POST, GET, PUT or DELETE)
     
     - returns: Custom NSMutableRequest
     */
    private func parseURLRequest(app:String, api:String, url:NSURL, httpMethod:HTTPMethod) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue(app, forHTTPHeaderField:"X-Parse-Application-Id")
        request.addValue(api, forHTTPHeaderField:"X-Parse-REST-API-Key")
        request.HTTPMethod = httpMethod.rawValue
        return request
    }
    
    
//    func parseURLPUTRequest(app:String, api:String, url:NSURL, httpMethod:HTTPMethod) -> NSMutableURLRequest {
//        
//        let request = NSMutableURLRequest(URL: url)
//        request.addValue(app, forHTTPHeaderField:"X-Parse-Application-Id")
//        request.addValue(api, forHTTPHeaderField:"X-Parse-REST-API-Key")
//        request.HTTPMethod = httpMethod.rawValue
////        request.HTTPBody = encodeData
//        return request
//    }
    
    
    
    /**
     Builds the complete Parse.com Request with all the parameters
     requiered by the kind of ParseRequest (Single, Query or Collection)
     
     - parameter config:      ParseConfig object
     - parameter className:   Name of the Parse.com table or Object
     - parameter ObjectId:    The value of the ObjectId attribute in the parse.com object
     - parameter query:       Set of conditions to be applied to the parse.com request
     - parameter requestType: ParseRequestType (Single, Query or Collection)
     
     - returns: Full NSMutableURLRequest with custom values
     */
    private func buildParseGETRequest(config:ParseConfig, className:String, objectId:String?, query:Dictionary<String,String>?, include:[String]?, requestType:ParseRequestType) -> NSMutableURLRequest {
        let http:HttpHandler = HttpHandler(conf: config)
        let url:NSURL = {
            
            switch (requestType){
            case .Collection:
                return NSURL(string:http.parseClassCollection(className, include:include ))!
            case .Single:
                
                if let inc = include as [String]! {
                    return NSURL(string:http.parseObjectWithInclude(className, objectId: objectId!, include: inc))!
                } else {
                    return NSURL(string:http.parseClassObjectById(className, objectId: objectId!))!
                }
                
                
            case .Query:
                return NSURL(string:http.parseQuery(className, query: query!, include: include))!
            }
        }()
        return parseURLRequest(config.appId, api: config.apiKey, url:url , httpMethod: .GET)
    }
    
    private func buildParsePutRequest(config:ParseConfig, className:String, objectId:String?) -> NSMutableURLRequest {

        let http:HttpHandler = HttpHandler(conf: config)
        let url = NSURL(string: http.parseClassObjectById(className, objectId: objectId!))!
            
        return parseURLRequest(config.appId, api: config.apiKey, url:url , httpMethod: .PUT)
    }
    
    /**
     Transforms the recived data from the request
     into FFObject (Dictionary<String, AnyObject>
     
     - parameter data: Request Response data
     
     - returns: FFObject with request results as a Dictionary Object
     */
    private func JSONFromData(data:NSData?) -> FFObject? {
        let dict:FFObject!
        
        if let dt = data as NSData! {
            
            do {
                try dict = NSJSONSerialization.JSONObjectWithData(dt, options: NSJSONReadingOptions.MutableContainers) as! FFObject
            } catch _ { dict = nil}
            
            return dict
        } else {
            
            return nil
        }
    }
    
    /**
     Search specific parse.com objects by Id
     
     - parameter className: Name of the Parse.com table or Object
     - parameter objectId:  The value of the ObjectId attribute in the parse.com object
     */
    func retriveParseObjectById(className:String, objectId:String, include:[String]?) -> Void {
        let session = NSURLSession(configuration: self.config, delegate: nil, delegateQueue: self.queue)
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(self.buildParseGETRequest(parse, className:className, objectId: objectId, query: nil, include:include, requestType: .Single )){(data, response, error) in
            
            let res:FFObject =  self.JSONFromData(data)!
            self.delegate.fillDataSource(res)
        }
        task.resume()
    }
    
    /**
     Search and retrieve the entire collection of objects with specific class name
     
     - parameter className: Name of the Parse.com table or Object
     */
    func retriveParseObjectByClassName(className:String, include:[String]?) -> Void {
        let session = NSURLSession(configuration: self.config, delegate: nil, delegateQueue: self.queue)
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(self.buildParseGETRequest(parse, className:className, objectId: nil, query: nil, include:include ,requestType: .Collection )){(data, response, error) in
            
            if error != nil {
                self.delegate.fillDataSource(["":""])
            } else {
                let res:FFObject =  self.JSONFromData(data)!
                self.delegate.fillDataSource(res)
            }
        }
        task.resume()
    }
    
    func updateObject(className:String, objectId:String, values:FFObject) -> Void {
        let session = NSURLSession(configuration: self.config, delegate: nil, delegateQueue: self.queue)
        let task : NSURLSessionDataTask = session.uploadTaskWithRequest(self.buildParsePutRequest(parse, className:className, objectId:objectId), fromData: values.flatStringFromDictionary()) {
            //"".flatStringFromDictionary(values) ){
            //dataTaskWithRequest(self.buildParsePutRequest(parse, className:className, objectId:objectId, updateValues:values) ){
                (data, response, error) in
            
//            print("Response: \(response)")
//            print("Error: \(error)")
            
            if error != nil {
                self.delegate.fillDataSource(["":""])
            } else {
//                print("PUT Succed")
                let res:FFObject =  self.JSONFromData(data)!
                self.delegate.fillDataSource(res)
            }
        }
        task.resume()
    }
}

extension String {
    func StringFromData(data:NSData) -> String {
        return  String(NSString(data: data, encoding: NSUTF8StringEncoding))
    }
    
    func StringFromArray(xs:[String]) -> String {
        return xs.joinWithSeparator(self)
    }
}

extension Dictionary  {
    
    func flatStringFromDictionary() -> NSData {
        
        var res:String = ""
        var count:Int = self.keys.count
        
        for (key,value) in self {
            
            if let val = value as? String {
                res = res + "\"\(key)\" : \"\(val)\""
            } else {
                //case not string
                res = res + "\"\(key)\" : \(value)"
            }
            
            count--
            
            if count != 0 {
                res = res + ","
            }
        }
        res = "{" + res + "}"
        
        return res.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}