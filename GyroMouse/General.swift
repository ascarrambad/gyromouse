//
//  General.swift
//  Subspedia
//
//  Created by Matteo Riva on 16/07/15.
//  Copyright (c) 2015 Matteo Riva. All rights reserved.
//

import UIKit

struct ScreenSize {
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct OsVersion {
    static let IS_OS_8_OR_LATER = (UIDevice.current.systemVersion as NSString).floatValue >= 8
    static let IS_OS_9 = (UIDevice.current.systemVersion as NSString).floatValue == 9
    static let IS_OS_8 = (UIDevice.current.systemVersion as NSString).floatValue == 8
    static let IS_OS_7 = (UIDevice.current.systemVersion as NSString).intValue == 7
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
}
/*
 extension UIImageView {
 
 typealias complType = (() -> Void)?
 
 func setImageWithURL(url: NSURL, placeholder: UIImage?, completion: complType) {
 self.image = placeholder
 NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {[unowned self] (data, _, error) in
 if error == nil {
 dispatch_async(dispatch_get_main_queue()) {
 self.image = UIImage(data: data!)
 }
 }
 completion?()
 }).resume()
 }
 }
 */
extension Date {
    init?(dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        guard let d = dateStringFormatter.date(from: dateString) else {
            return nil
        }
        self.init(timeInterval:0, since:d)
    }
}

extension Int16 {
    func format(_ f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Int {
    func format(_ f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func isValidEmail(_ strictFilter: Bool) -> Bool {
        let stricterFilterString = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let laxString = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let emailRegex = strictFilter ? stricterFilterString : laxString
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    func stringBetweenStrings(_ start: String, end: String) -> String? {
        var newString = self
        var scanner = Scanner(string:self)
        var result1: NSString?
        if (scanner.scanUpTo(start == "" ? end : start, into: &result1)) {
            if start == "" {
                return result1 as? String
            } else {
                newString = newString.replacingOccurrences(of: result1! as String, with: "")
                newString = newString.replacingOccurrences(of: start as String, with: "")
                scanner = Scanner(string: newString)
                
                var result2: NSString?
                if (scanner.scanUpTo(end, into: &result2)) {
                    return result2 as? String
                }
            }
        }
        return nil
    }
}

extension UIApplication {
    class func versionNumberAndBuild() -> String {
        let infoDictionary = Bundle.main.infoDictionary!
        let build: String = infoDictionary[String(kCFBundleVersionKey)] as! String
        let version: String = infoDictionary["CFBundleShortVersionString"] as! String
        return "version".localized + " \(version) (\(build))"
    }
}

func dateComponents(_ date: Date) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int) {
    let components = NSCalendar.current.dateComponents([.year, .month, .weekday, .minute, .hour], from:date)
    return (components.year!,components.month!,components.day!, components.hour!, components.minute!)
}

extension URL {
    
    enum StorageType {
        case persistent
        case effimeral
        case shared
    }
    
    static func URLForPersistentStore(_ type: StorageType, containerGroup: String?) -> URL {
        
        let searchPath: FileManager.SearchPathDirectory?
        let url: URL
        
        switch type {
        case .persistent:
            searchPath = .documentDirectory
            url = FileManager.default.urls(for: searchPath!, in: .userDomainMask).last!
        case .effimeral:
            searchPath = .cachesDirectory
            url = FileManager.default.urls(for: searchPath!, in: .userDomainMask).last!
        case .shared:
            url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: containerGroup!)!
        }
        
        return url
    }
}

extension UIColor {
    var inverse: UIColor {
        get {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
                return UIColor(red: 1.0-r, green: 1.0-g, blue: 1.0-b, alpha: a)
            }
            return self
        }
    }
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        let countInt = count as! Int
        
        for i in 0..<countInt - 1 {
            let j = Int(arc4random_uniform(UInt32(countInt - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
