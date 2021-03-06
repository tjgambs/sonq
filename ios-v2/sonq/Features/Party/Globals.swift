//
//  Globals.swift
//  sonq
//
//  Created by Tim Gamble on 3/31/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation

struct Globals {
    static var partyId: String?
    static let deviceId: String? = UIDevice.current.identifierForVendor?.uuidString
    static var isHost: Bool?
    static var deviceName: String?
}
