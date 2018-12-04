//
//  UIView+Extension.swift
//  Brave Brick
//
//  Created by Binh Huynh on 10/24/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
