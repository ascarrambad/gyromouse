//
//  TutorialViewController.swift
//  GyroMouse
//
//  Created by Matteo Riva on 10/09/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: scrollView.frame.size.height)
        
        let totWidth = ScreenSize.SCREEN_WIDTH * 3
        scrollView.contentSize = CGSize(width: totWidth, height: scrollView.contentSize.height)
        
        let tut1 = Bundle.main.loadNibNamed("tutorial", owner:self, options:nil)?.first! as! TutorialView
        let tut2 = Bundle.main.loadNibNamed("tutorial", owner:self, options:nil)?.first! as! TutorialView
        let tut3 = Bundle.main.loadNibNamed("tutorial", owner:self, options:nil)?.first! as! TutorialView
        
        tut1.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: scrollView.frame.size.height)
        tut2.frame = CGRect(x: tut1.frame.maxX, y: 0, width: ScreenSize.SCREEN_WIDTH, height: scrollView.frame.size.height)
        tut3.frame = CGRect(x: tut2.frame.maxX, y: 0, width: ScreenSize.SCREEN_WIDTH, height: scrollView.frame.size.height)
        
        let img1 = UIImage(named: "tut1")!
        let descr1 = "tut1".localized
        tut1.setImage(img1, AndExplanation: descr1)
        scrollView.addSubview(tut1)
        
        let img2 = UIImage(named: "tut2")!
        let descr2 = "tut2".localized
        tut2.setImage(img2, AndExplanation: descr2)
        scrollView.addSubview(tut2)
        
        let img3 = UIImage(named: "tut3")!
        let descr3 = "tut3".localized
        tut3.setImage(img3, AndExplanation: descr3)
        scrollView.addSubview(tut3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: "firstBoot") {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Info", message: "info_message".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                UIAlertView(title: "Info", message: "info_message".localized, delegate: nil, cancelButtonTitle: "OK").show()
            }
            UserDefaults.standard.set(true, forKey: "firstBoot")
        }
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / ScreenSize.SCREEN_WIDTH)
    }

}
