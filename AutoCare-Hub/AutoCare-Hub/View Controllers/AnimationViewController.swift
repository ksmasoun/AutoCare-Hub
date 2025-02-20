//
//  AnimationViewController.swift
//  Midterm-Karanveer
//
//  Created by Karanveer Singh on 2/15/25.
//

import UIKit

class AnimationViewController: UIViewController {
    
    @IBOutlet var imgView : UIImageView!
    var spinAndFadeLayer: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carSlideShow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spinAndFadeCar()
    }
    
    
    func carSlideShow()
    {
        let i1 = UIImage(named: "car1.jpeg")!
        let i2 = UIImage(named: "car3.jpeg")!
        let i3 = UIImage(named: "car4.jpeg")!
        let i4 = UIImage(named: "car5.jpeg")!
        let i5 = UIImage(named: "car6.jpeg")!
        
        let arrImg = [i1,i2,i3,i4,i5]
       
        imgView.animationImages = arrImg
        imgView.animationDuration = 4.0
        imgView.animationRepeatCount = 0
        imgView.startAnimating()
                            
    }
    
    func spinAndFadeCar() {
        let carImg = UIImage(named: "car2.jpeg")
        spinAndFadeLayer = .init()
        spinAndFadeLayer?.contents = carImg?.cgImage
        spinAndFadeLayer?.bounds = CGRect(x: 0, y: 0, width: 175, height: 175)
        spinAndFadeLayer?.position = CGPoint(x:200, y: 200)
        view.layer.addSublayer(spinAndFadeLayer!)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.timingFunction = CAMediaTimingFunction (name: .easeInEaseOut)
        fadeAnimation.fromValue = NSNumber.init(value: 1.0)
        fadeAnimation.toValue = NSNumber.init(value: 0.0)
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.autoreverses = true
        fadeAnimation.duration = 2.0
        fadeAnimation.autoreverses = true
        fadeAnimation.fillMode = .both
        fadeAnimation.repeatCount = .infinity
        fadeAnimation.beginTime = 1.0
        fadeAnimation.isAdditive = false
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = 2 * Double.pi
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = 2.0
        rotateAnimation.repeatCount = .infinity
        
        spinAndFadeLayer?.add(fadeAnimation, forKey: "fade")
        spinAndFadeLayer?.add(rotateAnimation, forKey: "rotate")
    }
}
