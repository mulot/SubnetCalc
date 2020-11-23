//
//  SubnetCalcAppDelegate.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa


class AppDelegate: NSObject, NSApplicationDelegate {
    enum Constants {
        static let BUFFER_LINES:UInt = 1000
        static let NETWORK_BITS_MIN_CLASSLESS:UInt = 1
        static let NETWORK_BITS_MIN:UInt = 8
        static let NETWORK_BITS_MAX:UInt = 32
    }
    
    @IBOutlet var window: NSWindow!
    @IBOutlet var addrField: NSTextField!
    @IBOutlet var classBinaryMap: NSTextField!
    @IBOutlet var classBitMap: NSTextField!
    @IBOutlet var classHexaMap: NSTextField!
    @IBOutlet var exportButton: NSPopUpButton!
    @IBOutlet var classType: NSPopUpButton!
    @IBOutlet var maskBitsCombo: NSComboBox!
    @IBOutlet var maxHostsBySubnetCombo: NSComboBox!
    @IBOutlet var maxSubnetsCombo: NSComboBox!
    @IBOutlet var subnetBitsCombo: NSComboBox!
    @IBOutlet var subnetBroadcast: NSTextField!
    @IBOutlet var subnetHostAddrRange: NSTextField!
    @IBOutlet var subnetId: NSTextField!
    @IBOutlet var subnetMaskCombo: NSComboBox!
    @IBOutlet var subnetsHostsView: NSTableView!
    @IBOutlet var supernetMaskBitsCombo: NSComboBox!
    @IBOutlet var supernetMaskCombo: NSComboBox!
    @IBOutlet var supernetMaxCombo: NSComboBox!
    @IBOutlet var supernetMaxAddr: NSComboBox!
    @IBOutlet var supernetMaxSubnetsCombo: NSComboBox!
    @IBOutlet var supernetRoute: NSTextField!
    @IBOutlet var supernetAddrRange: NSTextField!
    @IBOutlet var tabView: NSTabView!
    @IBOutlet var subnetBitsSlide: NSSlider!
    @IBOutlet var bitsOnSlide: NSTextField!
    @IBOutlet var tabViewClassLess: NSButton!
    @IBOutlet var wildcard: NSButton!
    @IBOutlet var darkModeMenu: NSMenuItem!
    @IBOutlet var NSApp: NSApplication!
    var classless: Bool = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func checkAddr(address: NSString) -> Bool
    {
        return false
    }
    
    func initClassInfos(c: NSString)
    {
        
    }
    
    func initCIDR()
    {
        
    }
    
    func doIPSubnetCalc(mask: UInt)
    {
        
    }
    
    
    @IBAction func calc(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func ipAddrEdit(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeAddrClassType(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeMaxHosts(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeMaxSubnets(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeSubnetBits(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeSubnetMask(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeMaskBits(_ sender: AnyObject)
    {
        
    }
    
    func doSupernetCalc(maskBits: UInt)
    {
        
    }
    
    @IBAction func changeSupernetMaskBits(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeSupernetMask(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeSupernetMax(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeSupernetMaxAddr(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeSupernetMaxSubnets(_ sender: AnyObject)
    {
        
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        return 0
    }
    
    //Display all subnets info in the TableView Subnet/Hosts
    func tableView(aTableView: NSTableView, aTableColumn: NSTableColumn, row: Int) -> Any
    {
        return (Any).self
    }
    
    func printAllSubnets()
    {
        
    }
    
    func tableView(aTableView: NSTableView, anObject: Any, aTableColumn: NSTableColumn, row: Int)
    {
        
    }
    
    func bitsOnSlidePos()
    {
        
        
    }
    
    @IBAction func subnetBitsSlide(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeTableViewClass(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeWildcard(_ sender: AnyObject)
    {
        
    }
    
    
    @IBAction func exportCSV(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func exportClipboard(_ sender: AnyObject)
    {
        
    }
    
    func URLEncode(url: NSString) -> NSString
    {
        return "@TEST"
    }
    
    func windowDidResize(notif: NSNotification)
    {
        bitsOnSlidePos()
    }
    
    func windowWillClose(notif: NSNotification)
    {
        NSApp.terminate(self)
    }
    
    
    @IBAction func darkMode(_ sender: AnyObject)
    {
        if #available(OSX 10.14, *) {
            if (darkModeMenu!.state == NSControl.StateValue.off) {
                NSApp!.appearance = NSAppearance(named: NSAppearance.Name.darkAqua)
                darkModeMenu.state = NSControl.StateValue.on
            } else if (darkModeMenu!.state == NSControl.StateValue.on) {
                NSApp!.appearance = nil
                darkModeMenu.state = NSControl.StateValue.off
            }
        }
    }
    
}
