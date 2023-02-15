//
//  ServerDiscoveryTableViewController.swift
//  GyroMouse
//
//  Created by Matteo Riva on 07/08/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit

class ServerDiscoveryTableViewController: UITableViewController {
    
    let client = (UIApplication.shared.delegate as! AppDelegate).client
    
    private lazy var loadingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.center = CGPoint(x: ScreenSize.SCREEN_WIDTH / 2, y: ScreenSize.SCREEN_HEIGHT / 2)
        view.backgroundColor = blue.withAlphaComponent(0.8)
        view.layer.cornerRadius = 15
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = CGPoint(x: 50, y: 50)
        spinner.color = yellow
        spinner.startAnimating()
        view.addSubview(spinner)
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        center.addObserver(forName: ServerDiscoveredServicesDidChangeNotification, object: client, queue: OperationQueue.main) {[unowned self] (_) -> Void in
                self.tableView.reloadData()
        }
        
        center.addObserver(forName: ClientDidCompleteLocalConnectionNotification, object: client, queue: OperationQueue.main) {[unowned self] (_) -> Void in
            self.performSegue(withIdentifier: "mouse", sender: self)
            self.loadingView.removeFromSuperview()
        }
        
        center.addObserver(forName: ClientDidFailLocalConnectionNotification, object: client, queue: OperationQueue.main) {[unowned self] (_) -> Void in
            self.loadingView.removeFromSuperview()
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "error".localized, message: "connect_error".localized, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertView(title: "Errore", message: "connect_error".localized, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        
        center.addObserver(forName: DidEnterBackgroundNotification, object: nil, queue: OperationQueue.main) {[unowned self] (_) -> Void in
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: "firstBoot") {
            self.performSegue(withIdentifier: "tutorialSegue", sender: self)
        }
    }
    
    deinit {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client.services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "server", for: indexPath)
        cell.textLabel?.text = client.services[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        client.connectToLocalService(client.services[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController!.view.addSubview(loadingView)
    }

}
