//
//  StoreProducts.swift
//  Brave Brick
//
//  Created by Binh Huynh on 10/24/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//

import Foundation
import StoreKit

//MARK: Add your products here

struct ProductList {
    static let Option_nonconsumable    : String = "your_optional_nonconsumable"
    static let products = [Option_nonconsumable]
}

//MARK: Deliver your products here

struct ProductDelivery {
    
    static let validatePurchase:Bool = true
    
    static func deliverProduct(_ product: String) {
        switch product {
        case ProductList.Option_nonconsumable:
            deliverNonconsumable(ProductList.Option_nonconsumable)
        default:
            break
        }
    }
    
    //MARK: Non-consumable products
    
    static func deliverNonconsumable(_ identifier: String) {
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.synchronize()
    }
    
    static func isProductAvailable(_ identifier: String) -> Bool {
        if UserDefaults.standard.bool(forKey: identifier) == true {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Consumable product
    
    static func deliverConsumable(_ identifier: String, units: Int) {
        let currentUnits:Int = UserDefaults.standard.integer(forKey: identifier)
        UserDefaults.standard.set(currentUnits + units, forKey: identifier)
        UserDefaults.standard.synchronize()
    }
    
    static func remainingUnits(_ identifier: String) -> Int {
        return UserDefaults.standard.integer(forKey: identifier)
    }
    
    
}
