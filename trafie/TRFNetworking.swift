//
//  Networking.swift
//  trafie
//
//  Created by mathiou on 9/2/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import Alamofire

class TRFNetworking {
    
    // Get nearby events by a provided Zip Code
    class func getEventsNearby() {
        Alamofire.request(.GET, "http://api.jambase.com/events", parameters: ["zipCode": "95128","page":"0","api_key": "YOUR_KEY_HERE" ])
            .response { (request, response, data, error) in
                println(request)
                println(response)
                println(data)
                println(error)
        }
    }
}