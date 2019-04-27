//
//  API.swift
//  CurrencyConvert
//
//  Created by Marco on 25/04/2019.
//  Copyright © 2019 vikings. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct API {
    
    func getConversionRates(from:String="USD", to:String="EUR", date:String, completionHandler: @escaping ((Double) -> Void)) {
        
        let defaults = UserDefaults.standard
        let url = "https://api.ratesapi.io/api/\(date)?base=\(from)&symbols=\(to)"
        Alamofire.request(url).validate(statusCode: 200..<299).responseJSON { response in
            
            switch response.result {
            case .success(let json):
                
                //if let json = response.result.value {
                    let d = JSON(json)
                    print(d)
                    
                    let rate = d["rates"][to].double
                    defaults.set(rate, forKey: "conversionRate")
                    defaults.set(Date(), forKey: "date")
                    
                    completionHandler(rate!)
                //}
                
            case .failure(let error):
                completionHandler( defaults.double(forKey: "conversionRate") )
            }
            
        }
    }
    
}

