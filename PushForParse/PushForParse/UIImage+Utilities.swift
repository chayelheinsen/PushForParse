//
//  UIImage+Utilities.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 11/1/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}