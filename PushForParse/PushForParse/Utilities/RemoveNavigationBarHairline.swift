//
//  RemoveNavigationBarHairline.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 1/2/16.
//  Copyright © 2016 Chayel Heinsen. All rights reserved.
//

import Foundation
import UIKit

protocol RemoveNavigationBarHairline {
    func removeNavigationBarHairline(underView: UIView) -> UIImageView?
}

extension RemoveNavigationBarHairline {
    func removeNavigationBarHairline(underView: UIView) -> UIImageView? {
        
        if underView.isKindOfClass(UIImageView.self) && underView.bounds.size.height <= 1.0 {
            underView.hidden = true
            return underView as? UIImageView
        }
        
        for subview in underView.subviews {
            let imageView = removeNavigationBarHairline(subview)
            
            if let imageView = imageView {
                imageView.hidden = true
                return imageView
            }
        }
        
        return nil
    }
}

extension UIViewController: RemoveNavigationBarHairline {
    
}