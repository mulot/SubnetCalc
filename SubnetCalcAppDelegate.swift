//
//  SubnetCalcAppDelegate.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa

struct Constants {
    static let BUFFER_LINES:Int = 1000
    static let NETWORK_BITS_MIN_CLASSLESS:Int = 1
    static let NETWORK_BITS_MIN:Int = 8
    static let NETWORK_BITS_MAX:Int = 32
}

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func changeMaskBits(sender: Any)
    {
        
    }

}


