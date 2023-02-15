//
//  MouseViewController.swift
//  GyroMouse
//
//  Created by Matteo Riva on 08/08/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit
import CoreMotion

class MouseViewController: UIViewController, KeyboardHandlerDelegate, UITextFieldDelegate, UIActionSheetDelegate, SettingsViewControllerDelegate {
    
    @IBOutlet weak var keyboard: KeyboardHandler!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var volumeUPButton: UIButton!
    @IBOutlet weak var volumeDWButton: UIButton!
    @IBOutlet weak var powerButton: UIButton!
    
    private let client = (UIApplication.shared.delegate as! AppDelegate).client
    private let manager = CMMotionManager()
    
    private var moveVelocity = UserDefaults.standard.double(forKey: "moveVelocity")
    private var scrollVelocity = UserDefaults.standard.double(forKey: "scrollVelocity")
    private var shakeToReset = UserDefaults.standard.bool(forKey: "shakeToReset")
    
    private lazy var handler: CMDeviceMotionHandler = {
        return {[weak self] (data, error) -> Void in
            if error == nil {
                
                let roll = data!.attitude.roll
                
                var type = GyroPacketType.scroll
                
                if roll > -0.45 && roll < 0.45 {
                    type = .movement
                }
                
                let packet = GyroPacket(type: type, minimumVersion: minimumVersion)
                
                packet.gravX = data!.gravity.x
                packet.gravY = data!.gravity.y
                packet.gravZ = data!.gravity.z
                packet.rotatX =  data!.rotationRate.x//data!.attitude.pitch
                packet.roll = roll
                packet.rotatZ = data!.rotationRate.z//data!.attitude.yaw
                packet.accX = data!.userAcceleration.x
                packet.accY = data!.userAcceleration.y
                packet.accZ = data!.userAcceleration.z
                packet.moveVelocity = self?.moveVelocity ?? 0
                packet.scrollVelocity = self?.scrollVelocity ?? 0
                
                self?.client.sendPacket(packet)
            }
        }
    }()
    
    private var isKeyboardOnScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboard.keyBoardDelegate = self
        keyboard.delegate = self
        
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: handler)
        }
        
        NotificationCenter.default.addObserver(forName: ClientDidDisconnectNotification, object: client, queue: OperationQueue.main) {[weak self] (_) -> Void in
            _=self?.navigationController?.popViewController(animated: true)
        }
        
        let maskPath = UIBezierPath(roundedRect: buttonsView.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 5, height: 5))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.view.bounds
        maskLayer.path = maskPath.cgPath
        buttonsView.layer.mask = maskLayer
        
        keyboardButton.setImage(UIImage(named: "keyboard")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        volumeUPButton.setImage(UIImage(named: "volumeUP")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        volumeDWButton.setImage(UIImage(named: "volumeDW")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        powerButton.setImage(UIImage(named: "shutdown")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        manager.stopDeviceMotionUpdates()
        client.endConnection()
    }
    
    //MARK: - Mouse actions

    @IBAction func mouseClickActionUp(_ sender: UIButton) {
        
        let packet = GyroPacket(type: .click, minimumVersion: minimumVersion)
        packet.button = ButtonType(rawValue: sender.tag)!
        packet.click = .up
        
        sender.backgroundColor = blue
        
        client.sendPacket(packet)
    }
    
    @IBAction func mouseClickActionDown(_ sender: UIButton) {
        let packet = GyroPacket(type: .click, minimumVersion: minimumVersion)
        packet.button = ButtonType(rawValue: sender.tag)!
        packet.click = .down
        
        sender.backgroundColor = yellow
        
        client.sendPacket(packet)
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake && shakeToReset {
            resetPointerPositionAction()
        }
    }
    
    //MARK: - Button actions
    
    @IBAction func showHideKeyboard(_ sender: UIBarButtonItem) {
        if isKeyboardOnScreen {
            keyboard.hideKeyboard()
        } else {
            keyboard.showKeyboard()
        }
    }
    
    @IBAction func changeVolumeAction(_ sender: UIButton) {
        let packet = GyroPacket(type: GyroPacketType(rawValue: sender.tag)!, minimumVersion: minimumVersion)
        client.sendPacket(packet)
    }
    
    
    @IBAction func sendShutdownAction() {
        
        if #available(iOS 8.0, *) {
            let packet = GyroPacket(type: .shutdown, minimumVersion: minimumVersion)
            let alert = UIAlertController(title: "", message: "choose_action".localized, preferredStyle: .actionSheet)
            let shutdownAction = UIAlertAction(title: "shutdown".localized, style: .default) {[unowned self] (_) -> Void in
                packet.shutdownType = .shutdown
                self.client.sendPacket(packet)
            }
            
            let rebootAction = UIAlertAction(title: "reboot".localized, style: .default) {[unowned self] (_) -> Void in
                packet.shutdownType = .reboot
                self.client.sendPacket(packet)
            }
            
            let logoutAction = UIAlertAction(title: "Logout", style: .default) {[unowned self] (_) -> Void in
                packet.shutdownType = .logout
                self.client.sendPacket(packet)
            }
            
            let sleepAction = UIAlertAction(title: "standby".localized, style: .default) {[unowned self] (_) -> Void in
                packet.shutdownType = .sleep
                self.client.sendPacket(packet)
            }
            
            let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
            
            alert.addAction(shutdownAction)
            alert.addAction(rebootAction)
            alert.addAction(logoutAction)
            alert.addAction(sleepAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            let sheet = UIActionSheet(title: "choose_action".localized,
                delegate: self,
                cancelButtonTitle: nil,
                destructiveButtonTitle: nil,
                otherButtonTitles: "shutdown".localized,
                "reboot".localized,
                "Logout",
                "standby".localized,
                "cancel".localized)
            sheet.cancelButtonIndex = 4
            sheet.show(in: view)
        }
    }
    
    
    @IBAction func resetPointerPositionAction() {
        let packet = GyroPacket(type: .resetPointerPosition, minimumVersion: minimumVersion)
        client.sendPacket(packet)
    }
    
    //MARK: - KeyboardHandlerDelegate
    
    func keyboardHandlerDidShowKeyboard(_ keyhandler: KeyboardHandler) {
        leftButton.isUserInteractionEnabled = false
        rightButton.isUserInteractionEnabled = false
        manager.stopDeviceMotionUpdates()
        isKeyboardOnScreen = true
    }
    
    func keyboardHandlerDidHideKeyboard(_ keyhandler: KeyboardHandler) {
        leftButton.isUserInteractionEnabled = true
        rightButton.isUserInteractionEnabled = true
        manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: handler)
        isKeyboardOnScreen = false
    }
    
    func keyboardHandlerDidDeleteBackward(_ keyhandler: KeyboardHandler) {
        let packet = GyroPacket(type: .deleteBackward, minimumVersion: minimumVersion)
        client.sendPacket(packet)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let packet = GyroPacket(type: .keyTapped, minimumVersion: minimumVersion)
        packet.key = string
        client.sendPacket(packet)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let packet = GyroPacket(type: .returnTapped, minimumVersion: minimumVersion)
        client.sendPacket(packet)
        keyboard.text = ""
        return false
    }
    
    //MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex < 4 {
            let packet = GyroPacket(type: .shutdown, minimumVersion: minimumVersion)
            packet.shutdownType = ShutdownType(rawValue: buttonIndex)!
            client.sendPacket(packet)
        }
    }
    
    //MARK: - SettingsViewControllerDelegate
    
    func settingsDidChangeMoveVelocity(_ moveVelocity: Double) {
        self.moveVelocity = moveVelocity
    }
    
    func settingsDidChangeScrollVelocity(_ scrollVelocity: Double) {
        self.scrollVelocity = scrollVelocity
    }
    
    func settingsDidChangeShakeToReset(_ shakeActive: Bool) {
        self.shakeToReset = shakeActive
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            let controller = segue.destination as! UINavigationController
            let view = controller.viewControllers.first! as! SettingsViewController
            view.delegate = self
        }
    }
    
}
