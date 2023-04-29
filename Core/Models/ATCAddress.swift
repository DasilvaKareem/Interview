//
//  ATCAddress.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/26/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import UIKit

class ATCAddress: ATCGenericBaseModel {

    var name: String?
    var line1: String?
    var line2: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var phone: String?
    var email: String?

    convenience init(name: String? = nil,
                     line1: String? = nil,
                     line2: String? = nil,
                     city: String? = nil,
                     state: String? = nil,
                     postalCode: String? = nil,
                     country: String? = nil,
                     phone: String? = nil,
                     email: String? = nil) {
        self.init(jsonDict: [:])
        self.name = name
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.phone = phone
        self.email = email
    }

    required init(jsonDict: [String: Any]) {
        name = jsonDict["name"] as? String
        line1 = jsonDict["line1"] as? String
        line2 = jsonDict["line2"] as? String
        city = jsonDict["city"] as? String
        postalCode = jsonDict["postalCode"] as? String
        country = jsonDict["country"] as? String
        phone = jsonDict["phone"] as? String
        email = jsonDict["email"] as? String
    }

    var description: String {
        var address = (
            (String.isEmpty(name) ? "" : (name! + ", ")) +
                (String.isEmpty(line1) ? "" : (line1! + ", ")) +
                (String.isEmpty(line2) ? "" : (line2! + ", ")) +
                (String.isEmpty(city) ? "" : (city! + ", ")) +
                (String.isEmpty(postalCode) ? "" : (postalCode! + ", ")) +
                (String.isEmpty(country) ? "" : (country! + ", ")) +
                (String.isEmpty(phone) ? "" : (phone! + ", ")) +
                (String.isEmpty(email) ? "" : (email! + ", ")))
        if (address.count < 4) {
            return address
        }
        address = String(address.dropLast())
        address = String(address.dropLast())
        return String(address)
    }

    var representation: [String : Any] {
        let rep: [String : Any] = [
            "name": name ?? "",
            "line1": line1 ?? "",
            "line2": line2 ?? "",
            "city": city ?? "",
            "postalCode": postalCode ?? "",
            "country": country ?? "",
            "phone": phone ?? "",
            "email": email ?? "",
        ]
        return rep
    }
}
