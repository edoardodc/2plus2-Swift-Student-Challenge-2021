//  Created by Edoardo de Cal on 1/20/20.
//  Copyright © 2020 Edoardo de Cal. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func labelBounceAnimation(duration: [TimeInterval], scale: [CGFloat]) {
        transform =
            CGAffineTransform.identity.scaledBy(x: scale[0], y: scale[0])
        UIView.animate(withDuration: duration[0], animations: {
            self.transform =
                CGAffineTransform.identity.scaledBy(x: scale[1], y: scale[1])
        }) { finished in
            UIView.animate(withDuration: duration[1], animations: {
                self.transform = CGAffineTransform.identity.scaledBy(x: scale[2], y: scale[2])
            }) { finished in
                UIView.animate(withDuration: duration[2], animations: {
                    self.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    func bounceAnimation(scale: [CGFloat], withDuration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions) {
        self.transform = CGAffineTransform(scaleX: scale[0], y: scale[1])
        UIView.animate(withDuration: withDuration,
                       delay: delay,
                       usingSpringWithDamping: 4,
                       initialSpringVelocity: 4,
                       options: options,
                       animations: { [weak self] in
                        self?.transform = .identity
            },
                       completion: nil)
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func shake(duration: CFTimeInterval, rangeValues: [Float]) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = [-rangeValues[0], rangeValues[0], -rangeValues[0], rangeValues[0], -rangeValues[1], rangeValues[1], -rangeValues[2], rangeValues[2], 0.0 ]
        layer.add(animation, forKey: "shakeAnimation")
    }
    
    func changeRandomColorBackgroundAnimation() {
        let red   = CGFloat((arc4random() % 256)) / 255.0
        let green = CGFloat((arc4random() % 256)) / 255.0
        let blue  = CGFloat((arc4random() % 256)) / 255.0
        let alpha = CGFloat(1.0)
        UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat, .autoreverse], animations: {
            self.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }, completion:nil)
    }
    
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
