//
//  SettingsViewController.swift
//  GyroMouse
//
//  Created by Matteo Riva on 08/09/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsDidChangeMoveVelocity(_ moveVelocity: Double);
    func settingsDidChangeScrollVelocity(_ scrollVelocity: Double);
    func settingsDidChangeShakeToReset(_ shakeActive: Bool);
}

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var moveSlider: UISlider!
    @IBOutlet weak var scrollSlider: UISlider!
    @IBOutlet weak var shakeSwitch: UISwitch!
    @IBOutlet weak var screenSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    weak var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let moveVelocity = UserDefaults.standard.double(forKey: "moveVelocity")
        let scrollVelocity = UserDefaults.standard.double(forKey: "scrollVelocity")
        let shakeGest = UserDefaults.standard.bool(forKey: "shakeToReset")
        let keepActive = UserDefaults.standard.bool(forKey: "keepScreenActive")
        
        moveSlider.value = Float(moveVelocity)
        scrollSlider.value = Float(scrollVelocity)
        shakeSwitch.isOn = shakeGest
        screenSwitch.isOn = keepActive
        
        versionLabel.text = UIApplication.versionNumberAndBuild()
        
    }
    
    @IBAction func moveSliderDidChange() {
        let value = Double(moveSlider.value)
        UserDefaults.standard.set(value, forKey: "moveVelocity")
        delegate?.settingsDidChangeMoveVelocity(value)
    }

    @IBAction func scrollSliderDidChange() {
        let value = Double(scrollSlider.value)
        UserDefaults.standard.set(value, forKey: "scrollVelocity")
        delegate?.settingsDidChangeScrollVelocity(value)
    }
    
    @IBAction func shakeSwitchDidChange() {
        UserDefaults.standard.set(shakeSwitch.isOn, forKey: "shakeToReset")
        delegate?.settingsDidChangeShakeToReset(shakeSwitch.isOn)
    }
    
    @IBAction func screenSwitchDidChange() {
        UserDefaults.standard.set(screenSwitch.isOn, forKey: "keepScreenActive")
        UIApplication.shared.isIdleTimerDisabled = screenSwitch.isOn
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }

}
