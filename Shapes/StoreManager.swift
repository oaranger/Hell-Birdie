//
//  StoreManager.swift
//  Brave Brick
//
//  Created by Binh Huynh on 10/24/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//

import Foundation
import StoreKit

//MARK: Protocols

protocol StoreManagerDelegate: class {
    func updateWithProducts(_ products:[SKProduct])
    func refreshPurchaseStatus()
}

//MARK: Store Manager class

class StoreManager: NSObject {
    
    weak var delegate: StoreManagerDelegate?
    var loadedProducts: [SKProduct] = []
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self) //Neil
        getProductList()
    }
    
    deinit {
        //if SKPaymentQueue.canMakePayments() {
        SKPaymentQueue.default().remove(self)
        //}
    }
    
    //MARK: Request products
    
    func getProductList() {
        if SKPaymentQueue.canMakePayments() {
            let products = NSSet(array: ProductList.products)
            let request = SKProductsRequest(productIdentifiers: products as! Set<String>)
            request.delegate = self
            request.start()
        }
    }
    
    //MARK: Purchasing
    
    func restoreCompletedTransactions() {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    func purchaseProduct(_ product: SKProduct) {
        //SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension StoreManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        loadedProducts = response.products
        if loadedProducts.count != 0 {
            delegate?.updateWithProducts(loadedProducts)
        }
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    //validateReceipt(transaction as! SKPaymentTransaction)
                    ProductDelivery.deliverProduct(trans.payment.productIdentifier)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    //SKPaymentQueue.defaultQueue().removeTransactionObserver(self) //BH
                    self.delegate?.refreshPurchaseStatus()
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    //SKPaymentQueue.defaultQueue().removeTransactionObserver(self) //BH
                    break
                case .restored:
                    //validateReceipt(transaction as! SKPaymentTransaction)
                    ProductDelivery.deliverProduct(trans.payment.productIdentifier)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    //SKPaymentQueue.defaultQueue().removeTransactionObserver(self) //BH
                    self.delegate?.refreshPurchaseStatus()
                    break
                default:
                    break
                }
            }
        }
    }
    
}

extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}
