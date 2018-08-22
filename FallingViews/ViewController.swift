//
//  ViewController.swift
//  FallingViews
//
//  Created by Matteo Pacini on 22/08/2018.
//  Copyright © 2018 Codecraft Limited. All rights reserved.
//

import UIKit

extension UIColor {
    
    // https://gist.github.com/asarode/7b343fa3fab5913690ef
    class func random() -> UIColor {
        
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        
    }
    
}

class ViewSpawner {
    
    private static let minSize : CGFloat = 10
    private static let maxSize : CGFloat = 50
    
    private(set) var views : [UIView] = []
    
    func spawnView(inView view: UIView) {
        
        let size = ViewSpawner.minSize +
                   CGFloat(arc4random_uniform(UInt32(ViewSpawner.maxSize) - UInt32(ViewSpawner.minSize)))
        let newView = UIView(frame: CGRect(
            x: view.bounds.width/2 - size/2,
            y: 16,
            width: size,
            height: size
        ))
        newView.backgroundColor = .random()
        views.append(newView)
        view.addSubview(newView)
    }
    
}

class ViewController: UIViewController {
    
    let spawner = ViewSpawner()
    
    var itemsAnimator: UIDynamicAnimator?
    var gravityBehavior: UIGravityBehavior?
    var boundaryCollisionBehavior: UICollisionBehavior?
    var elasticityBehavior: UIDynamicItemBehavior?
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged(notification:)),
                                               name: Notification.Name.UIDeviceOrientationDidChange,
                                               object: nil)

        
        self.view.backgroundColor = UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
        
        (0...50).forEach { index in
            spawner.spawnView(inView: self.view)
        }
        
        itemsAnimator = UIDynamicAnimator(referenceView: view)
        
        gravityBehavior = UIGravityBehavior(items: spawner.views)
        
        boundaryCollisionBehavior = UICollisionBehavior(items: spawner.views)
        boundaryCollisionBehavior!.translatesReferenceBoundsIntoBoundary = true
        
        elasticityBehavior = UIDynamicItemBehavior(items: spawner.views)
        elasticityBehavior!.elasticity = 0.8
        
        itemsAnimator!.addBehavior(gravityBehavior!)
        itemsAnimator!.addBehavior(boundaryCollisionBehavior!)
        itemsAnimator!.addBehavior(elasticityBehavior!)
        
        
    }
    
    @objc func orientationChanged(notification: NSNotification) {
        if let device = notification.object as? UIDevice {
            switch device.orientation {
            case .portrait:
                gravityBehavior!.gravityDirection = CGVector(dx: 0, dy: 1.0)
            case .portraitUpsideDown:
                gravityBehavior!.gravityDirection = CGVector(dx: 0, dy: -1.0)
            case .landscapeLeft:
                gravityBehavior!.gravityDirection = CGVector(dx: -1, dy: 0)
            case .landscapeRight:
                gravityBehavior!.gravityDirection = CGVector(dx: 1, dy: 0)
            default:
                return
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

