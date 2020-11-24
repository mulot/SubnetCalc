//
//  SubnetCalcAppDelegate.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private enum Constants {
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
    
    private func initAddressTab() {
        classBitMap.stringValue = "nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh"
        classBinaryMap.stringValue = "00000001000000000000000000000000"
    }
    
    private func initCIDRTab() {
        for bits in (1...30) {
            supernetMaskBitsCombo.addItem(withObjectValue: bits)
        }
        
        for index in (2...31).reversed() {
            supernetMaskCombo.addItem(withObjectValue: IPSubnetCalc.digitize(ipAddress: (IPSubnetCalc.Constants.addr32Full << index)))
        }
        for index in (0...29) {
            supernetMaxCombo.addItem(withObjectValue: pow(2, index))
        }
        for index in (1...31) {
            supernetMaxAddr.addItem(withObjectValue: (pow(2, index) - 2))
        }
        for index in (0...31) {
            supernetMaxSubnetsCombo.addItem(withObjectValue: pow(2, index))
        }
    }
    
    private func initSubnetsTab() {
        for index in (2...24).reversed() {
            if (wildcard.state == NSControl.StateValue.on) {
                subnetMaskCombo.addItem(withObjectValue: IPSubnetCalc.digitize(ipAddress: ~(IPSubnetCalc.Constants.addr32Full << index)))
            }
            else {
                subnetMaskCombo.addItem(withObjectValue: IPSubnetCalc.digitize(ipAddress: (IPSubnetCalc.Constants.addr32Full << index)))
            }
        }
        for bits in (8...30) {
            maskBitsCombo.addItem(withObjectValue: bits)
        }
        for bits in (0...22) {
            subnetBitsCombo.addItem(withObjectValue: bits)
        }
        for index in (2...24) {
            maxHostsBySubnetCombo.addItem(withObjectValue: (pow(2, index) - 2))
        }
        for index in (0...22) {
            maxSubnetsCombo.addItem(withObjectValue: pow(2, index))
        }
    }
    
    private func bitsOnSlidePos()
    {
        var coordLabel = bitsOnSlide.frame
        let coordSlider = subnetBitsSlide.frame
        
        //bitsOnSlide.stringValue = "24"
        //print("bitsOnSlidePos")
        coordLabel.origin.x = coordSlider.origin.x - (coordLabel.size.width / 2) + (subnetBitsSlide.knobThickness / 2) + (((coordSlider.size.width - (subnetBitsSlide.knobThickness / 2)) / CGFloat(subnetBitsSlide.numberOfTickMarks)) * CGFloat(subnetBitsSlide.floatValue - 1.0))
        bitsOnSlide.frame = coordLabel
         /*
         coordLabel = [bitsOnSlide frame];
         coordSlider = [subnetBitsSlide frame];
         coordLabel.origin.x = coordSlider.origin.x - (coordLabel.size.width / 2) + ([subnetBitsSlide knobThickness] / 2) + (((coordSlider.size.width - ([subnetBitsSlide knobThickness] / 2)) / [subnetBitsSlide numberOfTickMarks]) * ([subnetBitsSlide floatValue] - 1.0));
         //NSLog(@"slide x : %f label width : %f slide knob : %f slide width : %f n tick marks : %d slide value : %f x coord %f", coordSlider.origin.x, coordLabel.size.width, [subnetBitsSlide knobThickness], coordSlider.size.width, (int)[subnetBitsSlide numberOfTickMarks], [subnetBitsSlide floatValue], coordLabel.origin.x);
         [bitsOnSlide setFrame: coordLabel];
         */
        
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let ipsc:IPSubnetCalc! = IPSubnetCalc("10.0.0.0")
            print("IP Address: \(ipsc.ipv4Address)")
            print("Mask Bits: \(ipsc.maskBits)")
            print("IP Network Class: \(ipsc.networkClass)")
        initAddressTab()
        initSubnetsTab()
        initCIDRTab()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func checkAddr(address: NSString) -> Bool
    {
        return false
    }
    
    private func initClassInfos(c: NSString)
    {
        
    }
    
    private func doIPSubnetCalc(mask: UInt)
    {
        
    }
    
    private func doSupernetCalc(maskBits: UInt)
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
    
    func URLEncode(url: String) -> String
    {
        return "@TEST"
    }
    
    func windowDidResize(_ notification: Notification)
    {
        print("Windows Did Resize")
        bitsOnSlidePos()
    }
    
    func windowWillClose(_ notification: Notification)
    {
        NSApp.terminate(self)
    }
}
