//
//  ViewController.swift
//  GyroMouse
//
//  Created by Matteo Riva on 07/08/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit
import CoreMotion

class DetailsViewController: UIViewController {
    
    let manager = CMMotionManager()

    @IBOutlet weak var xG: UILabel!
    @IBOutlet weak var yG: UILabel!
    @IBOutlet weak var zG: UILabel!
    
    @IBOutlet weak var roll: UILabel!
    @IBOutlet weak var pitch: UILabel!
    @IBOutlet weak var yaw: UILabel!
    
    @IBOutlet weak var xQ: UILabel!
    @IBOutlet weak var yQ: UILabel!
    @IBOutlet weak var zQ: UILabel!
    @IBOutlet weak var wQ: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.1
            
            manager.startDeviceMotionUpdates(to: OperationQueue.main) {[weak self] (data, error) -> Void in
                if error == nil {
                    self?.xG.text = "\(data!.gravity.x)"
                    self?.yG.text = "\(data!.gravity.y)"
                    self?.zG.text = "\(data!.gravity.z)"
                    
                    self?.pitch.text = "\(data!.attitude.pitch)"
                    self?.yaw.text = "\(data!.attitude.yaw)"
                    self?.roll.text = "\(data!.attitude.roll)"
                    
                    self?.xQ.text = "\(data!.rotationRate.x)"
                    self?.yQ.text = "\(data!.rotationRate.y)"
                    self?.zQ.text = "\(data!.rotationRate.z)"
                    self?.wQ.text = "\(data!.attitude.quaternion.w)"
                }
            }
        }
        
    }
    
    deinit {
        manager.stopDeviceMotionUpdates()
    }

    @IBAction func closeAction() {
        dismiss(animated: true, completion: nil)
    }
}

