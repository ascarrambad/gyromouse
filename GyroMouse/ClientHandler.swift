//
//  ClientHandler.swift
//  GyroMouse
//
//  Created by Matteo Riva on 28/08/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

let ServerDiscoveredServicesDidChangeNotification = Notification.Name("ServerDiscoveredServicesDidChangeNotification")
let ClientDidCompleteLocalConnectionNotification = Notification.Name("ClientDidCompleteLocalConnectionNotification")
let ClientDidFailLocalConnectionNotification = Notification.Name("ClientDidFailLocalConnectionNotification")
let ClientDidDisconnectNotification = Notification.Name("ClientDidDisconnectNotification")

class ClientHandler: NSObject, NetServiceDelegate, NetServiceBrowserDelegate, GCDAsyncSocketDelegate {
    
    private var socket: GCDAsyncSocket?
    private var serviceBrowser: NetServiceBrowser?
    
    private(set) var services = [NetService]()
    
    deinit {
        socket?.setDelegate(nil, delegateQueue: nil)
        socket = nil
        
        serviceBrowser?.delegate = nil
        serviceBrowser = nil
    }
    
    //MARK: - Privates
    
    private func sendNotificationWithName(_ name: Notification.Name, userInfo: [String : Any]?) {
        let center = NotificationCenter.default
        let notif = Notification(name: name, object: self, userInfo: userInfo)
        center.post(notif)
    }
    
    private func connectWithService(_ service: NetService) -> Bool {
        var isConnected = false
        
        // Copy Service Addresses
        let addresses = service.addresses!
        
        if socket == nil || socket?.isDisconnected ?? false {
            // Initialize Socket
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            // Connect
            while !isConnected && addresses.count != 0 {
                let address = addresses.first!
                
                do {
                    try socket!.connect(toAddress: address)
                    isConnected = true
                } catch {
                    isConnected = false
                    print("Unable to connect to address. Error \(error) with user info \(error.localizedDescription).", terminator: "\n")
                }
            }
            
        } else {
            isConnected = socket?.isConnected ?? false
        }
        
        return isConnected
    }
    
    //MARK: - Publics
    
    func startBrowsing() {
        
        services = []
        
        // Initialize Service Browser
        serviceBrowser = NetServiceBrowser()
        
        // Configure Service Browser
        serviceBrowser!.delegate = self
        serviceBrowser!.searchForServices(ofType: "_gyroserver._tcp.", inDomain:"local.")
    }
    
    func stopBrowsing() {
        serviceBrowser?.stop()
        serviceBrowser?.delegate = nil
        serviceBrowser = nil
        services.removeAll()
    }
    
    func connectToLocalService(_ service: NetService) {
        
        // Resolve Service
        service.delegate = self
        service.resolve(withTimeout: 30)
        
    }
    
    func sendPacket(_ packet: GyroPacket) {
        // Encode Packet Data
        let packetData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: packetData)
        archiver.encode(packet, forKey: "packet")
        archiver.finishEncoding()
        
        // Initialize Buffer
        let buffer = NSMutableData()
        
        // Fill Buffer
        var headerLength = UInt64(packetData.length)
        buffer.append(&headerLength, length: MemoryLayout<UInt64>.size)
        buffer.append(packetData.bytes, length: packetData.length)
        
        // Write Buffer
        socket?.write(buffer as Data, withTimeout: -1, tag: 0)
    }
    
    func endConnection() {
        socket?.disconnect()
        socket?.setDelegate(nil, delegateQueue: nil)
        socket = nil
    }
    
    //MARK: - NSNetServiceBrowserDelegate
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        // Update Services
        services.append(service)
        
        if !moreComing {
            sendNotificationWithName(ServerDiscoveredServicesDidChangeNotification, userInfo: nil)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        // Update Services
        services.remove(at: services.index(of: service)!)
        
        if !moreComing {
            sendNotificationWithName(ServerDiscoveredServicesDidChangeNotification, userInfo: nil)
        }
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        stopBrowsing()
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        stopBrowsing()
    }
    
    //MARK: - NSNetServiceDelegate
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        sender.delegate = nil
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        // Connect With Service
        if connectWithService(sender) {
            print("Did Connect with Service: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))", terminator: "\n")
        } else {
            print("Unable to Connect with Service: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))", terminator: "\n")
            sendNotificationWithName(ClientDidFailLocalConnectionNotification, userInfo: nil)
        }
    }
    
    //MARK: - GCDAsyncSocketDelegate
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Socket Did Connect to Host: \(host) Port: \(port)", terminator: "\n")
        
        // Start Reading
        sock.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1, tag: 0)
        
        stopBrowsing()
        sendNotificationWithName(ClientDidCompleteLocalConnectionNotification, userInfo: nil)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        socket?.delegate = nil
        socket = nil
        
        startBrowsing()
        sendNotificationWithName(ClientDidDisconnectNotification, userInfo: nil)
        
        if err != nil {
            print("Socket Did Disconnect with Error \(err!) with user info \(err!.localizedDescription).", terminator: "\n")
            sendNotificationWithName(ClientDidFailLocalConnectionNotification, userInfo: nil)
        } else {
            print("Socket Did Disconnect", terminator: "\n")
        }
    }

}
