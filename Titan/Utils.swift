//
//  Utils.swift
//  Titan
//
//  Created by Tim Gamble on 2/17/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import Foundation

class Utils: NSObject {
    
    static let shared = Utils()
    static var PARTY_ID = ""

    func generatePartyID() -> String {
        var randomString = ""
        for _ in 0...5 {
            randomString = randomString + String(Int(arc4random_uniform(10)))
        }
        return randomString
    }
}
