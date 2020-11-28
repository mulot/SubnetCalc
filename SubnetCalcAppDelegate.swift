//
//  SubnetCalcAppDelegate.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSTableViewDataSource {
    private enum Constants {
        static let defaultIP: String = "10.0.0.0"
        static let BUFFER_LINES:Int = 1000
        static let NETWORK_BITS_MIN_CLASSLESS:Int = 1
        static let NETWORK_BITS_MIN:Int = 8
        static let NETWORK_BITS_MAX:Int = 32
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
    
    private var savedTabView: [NSTabViewItem]? //ex tab_tabView
    private var classless: Bool = false
    private var ipsc: IPSubnetCalc?
    
    private func initAddressTab() {
        classBitMap.stringValue = "nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh"
        classBinaryMap.stringValue = "00000001000000000000000000000000"
    }
    
    private func initCIDRTab() {
        for bits in (1...30) {
            supernetMaskBitsCombo.addItem(withObjectValue: String(bits))
        }
        
        for index in (2...31).reversed() {
            supernetMaskCombo.addItem(withObjectValue: IPSubnetCalc.digitize(ipAddress: (IPSubnetCalc.Constants.addr32Full << index)))
        }
        for index in (0...29) {
            supernetMaxCombo.addItem(withObjectValue: NSDecimalNumber(decimal: pow(2, index)).stringValue)
        }
        for index in (1...31) {
            supernetMaxAddr.addItem(withObjectValue: NSDecimalNumber(decimal: (pow(2, index) - 2)).stringValue)
        }
        for index in (0...31) {
            supernetMaxSubnetsCombo.addItem(withObjectValue: NSDecimalNumber(decimal: pow(2, index)).stringValue)
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
            maskBitsCombo.addItem(withObjectValue: String(bits))
        }
        for bits in (0...22) {
            subnetBitsCombo.addItem(withObjectValue: String(bits))
        }
        for index in (2...24) {
            maxHostsBySubnetCombo.addItem(withObjectValue: NSDecimalNumber(decimal: (pow(2, index) - 2)).stringValue)
        }
        for index in (0...22) {
            maxSubnetsCombo.addItem(withObjectValue: NSDecimalNumber(decimal: pow(2, index)).stringValue)
        }
    }
    
    private func bitsOnSlidePos()
    {
        var coordLabel = bitsOnSlide.frame
        let coordSlider = subnetBitsSlide.frame
        
        coordLabel.origin.x = coordSlider.origin.x - (coordLabel.size.width / 2) + (subnetBitsSlide.knobThickness / 2) + (((coordSlider.size.width - (subnetBitsSlide.knobThickness / 2)) / CGFloat(subnetBitsSlide.numberOfTickMarks)) * CGFloat(subnetBitsSlide.floatValue - 1.0))
        bitsOnSlide.frame = coordLabel
    }
    
    private func URLEncode(url: String) -> String
    {
        return "@TEST"
    }
    
    private func checkAddr(address: NSString) -> Bool
    {
        return false
    }
    
    private func initClassInfos(_ c: String)
    {
        if (c == "A")
        {
            classType.selectItem(at: 0)
        }
        else if (c == "B")
        {
            classType.selectItem(at: 1)
        }
        else if (c == "C")
        {
            classType.selectItem(at: 2)
        }
        else if (c == "D")
        {
            classType.selectItem(at: 3)
            savedTabView = tabView.tabViewItems
            if (savedTabView != nil)
            {
                tabView.removeTabViewItem(savedTabView![1])
                tabView.removeTabViewItem(savedTabView![2])
                tabView.removeTabViewItem(savedTabView![3])
            }
        }
    }
    
    private func splitAddrMask(address: String) -> (String, String?) {
        let ipInfo = address.split(separator: "/")
        if ipInfo.count == 2 {
            return (String(ipInfo[0]), String(ipInfo[1]))
        }
        else if ipInfo.count > 2 {
            print("Bad IP format: \(ipInfo)")
            return ("", nil)
        }
        return (address, nil)
    }
    
    
    private func doAddressMap() {
        if (ipsc != nil) {
            self.initClassInfos(ipsc!.netClass())
            classBitMap.stringValue = ipsc!.bitMap()
            classBinaryMap.stringValue = ipsc!.binaryMap()
            classHexaMap.stringValue = ipsc!.hexaMap()
        }
    }
    
    private func doSubnet()
    {
        if (ipsc != nil) {
            subnetBitsCombo.selectItem(withObjectValue: String(ipsc!.subnetBits()))
            maskBitsCombo.selectItem(withObjectValue: String(ipsc!.maskBits))
            maxSubnetsCombo.selectItem(withObjectValue: String(ipsc!.maxSubnets()))
            maxHostsBySubnetCombo.selectItem(withObjectValue: String(ipsc!.maxHosts()))
            subnetId.stringValue = ipsc!.subnetId()
            subnetBroadcast.stringValue = ipsc!.subnetBroadcast()
            subnetHostAddrRange.stringValue = ipsc!.subnetRange()
            if (wildcard.state == NSControl.StateValue.on) {
                subnetMaskCombo.selectItem(withObjectValue: ipsc!.wildcardMask())
            }
            else {
                subnetMaskCombo.selectItem(withObjectValue: ipsc!.subnetMask())
            }
            /*
             if ([wildcard state] == NSOnState)
             {
             [subnetMaskCombo selectItemWithObjectValue: [IPSubnetCalc denumberize: ~([ipsc subnetMaskIntValue])]];
             }
             else
             {
             [subnetMaskCombo selectItemWithObjectValue: [ipsc subnetMask]];
             }
             */
        }
    }
    
    private func doSubnetHost()
    {
        if (ipsc != nil) {
            bitsOnSlide.stringValue = String(ipsc!.maskBits)
            subnetBitsSlide.intValue = Int32(ipsc!.maskBits)
            self.bitsOnSlidePos()
            subnetsHostsView.reloadData()
        }
    }
    
    private func doCIDR()
    {
        if (ipsc != nil) {
            //supernetRoute.stringValue = ipsc!.subnetId()
            supernetAddrRange.stringValue = ipsc!.subnetCIDRRange()
        }
    }
    
    private func myAlert(message: String, info: String)
    {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = message
        alert.alertStyle = NSAlert.Style.warning
        alert.informativeText = info
        alert.runModal()
    }
    
    private func doIPSubnetCalc()
    {
        let ipaddr: String
        var ipmask: String?
        
        if (addrField.stringValue.isEmpty) {
            if (ipsc == nil)
            {
                addrField.stringValue = Constants.defaultIP
                ipaddr = Constants.defaultIP
                ipmask = nil
            }
            else {
                addrField.stringValue = ipsc!.ipv4Address
                ipaddr = ipsc!.ipv4Address
                ipmask = String(ipsc!.maskBits)
            }
        }
        else {
            (ipaddr, ipmask) = splitAddrMask(address: addrField.stringValue)
            if (ipmask == nil && ipsc != nil) {
                ipmask = String(ipsc!.maskBits)
            }
        }
        if (IPSubnetCalc.isValidIP(ipAddress: ipaddr, mask: ipmask) == true) {
            //print("IP Address: \(ipaddr) mask: \(ipmask)")
            addrField.stringValue = ipaddr
            if (ipmask == nil) {
                ipsc = IPSubnetCalc(ipaddr)
            }
            else {
                ipsc = IPSubnetCalc(ipAddress: ipaddr, maskbits: Int(ipmask!)!)
            }
            if (ipsc != nil) {
                if (tabView.numberOfTabViewItems != 4 && savedTabView != nil) {
                    tabView.addTabViewItem(savedTabView![1])
                    tabView.addTabViewItem(savedTabView![2])
                    tabView.addTabViewItem(savedTabView![3])
                }
                self.doAddressMap()
                self.doSubnet()
                self.doSubnetHost()
                self.doCIDR()
            }
        }
        else {
            myAlert(message: "Bad IP Address", info: "Bad format")
            return
        }
    }
    
    private func doSupernetCalc(maskBits: UInt)
    {
        
    }
    
    @IBAction func calc(_ sender: AnyObject)
    {
        self.doIPSubnetCalc()
    }
    
    @IBAction func ipAddrEdit(_ sender: AnyObject)
    {
        self.calc(sender)
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
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.objectValueOfSelectedItem as? String) != nil {
            ipsc!.maskBits = sender.intValue + ipsc!.netBits()
            self.doIPSubnetCalc()
        }
        else {
            myAlert(message: "Bad Subnet Bits", info: "Bad format")
            return
        }
    }
    
    @IBAction func changeSubnetMask(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if let maskStr = sender.objectValueOfSelectedItem as? String {
            let mask:UInt32 = IPSubnetCalc.numerize(ipAddress: maskStr)
            if (wildcard.state == NSControl.StateValue.on) {
                ipsc!.maskBits = Int(IPSubnetCalc.maskBits(mask: ~mask))
            }
            else {
                ipsc!.maskBits = Int(IPSubnetCalc.maskBits(mask: mask))
                //print("changeSubnetMask object value : \(str)")
            }
            self.doIPSubnetCalc()
        }
        else {
            myAlert(message: "Bad Subnet Mask", info: "Bad format")
            return
        }
    }
    
    @IBAction func changeMaskBits(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.objectValueOfSelectedItem as? String) != nil {
            ipsc!.maskBits = sender.intValue
            self.doIPSubnetCalc()
        }
        else {
            myAlert(message: "Bad Mask Bits", info: "Bad format")
            return
        }
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
    
    func printAllSubnets()
    {
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        if (ipsc != nil) {
            if (self.classless == true) {
                return Int(truncating: NSDecimalNumber(decimal: pow(2, (ipsc!.maskBits - Constants.NETWORK_BITS_MIN_CLASSLESS))))
            }
            else {
                return (ipsc!.maxSubnets())
            }
        }
        return 0
    }
    
    //Display all subnets info in the TableView Subnet/Hosts
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?,
                   row: Int) -> Any?
    {
        if (ipsc != nil) {
            
            let mask: UInt32 = UInt32(row) << (32 - ipsc!.maskBits)
            //print("tableView mask : \(mask) row : \(UInt32(row)) lshift : \(32 - ipsc!.maskBits)")
            let ipaddr = (IPSubnetCalc.numerize(ipAddress: ipsc!.subnetId())) | mask
            let ipsc_tmp = IPSubnetCalc(ipAddress: IPSubnetCalc.digitize(ipAddress: ipaddr), maskbits: ipsc!.maskBits)
            if (tableColumn != nil) {
                if (tableColumn!.identifier.rawValue == "numCol") {
                    return (row + 1)
                }
                else if (tableColumn!.identifier.rawValue == "subnetCol") {
                    return (ipsc_tmp!.subnetId())
                }
                else if (tableColumn!.identifier.rawValue == "rangeCol") {
                    return (ipsc_tmp!.subnetRange())
                }
                else if (tableColumn!.identifier.rawValue == "broadcastCol") {
                    return (ipsc_tmp!.subnetBroadcast())
                }
            }
        }
        return (nil)
    }
    
    
    @IBAction func subnetBitsSlide(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        //print("subnetBitsSlide bits value : \(sender.intValue as Int)")
        if (sender.intValue as Int >= Constants.NETWORK_BITS_MIN)
        {
            ipsc!.maskBits = sender.intValue as Int
            self.doIPSubnetCalc()
        }
        else {
            ipsc!.maskBits = Constants.NETWORK_BITS_MIN
            self.doIPSubnetCalc()
        }
        subnetsHostsView.reloadData()
        /*
         else {
         myAlert(message: "Bad Subnet Bits", info: "Bad value")
         return
         }
         */
    }
    
    @IBAction func changeTableViewClass(_ sender: AnyObject)
    {
        
    }
    
    @IBAction func changeWildcard(_ sender: AnyObject)
    {
        subnetMaskCombo.removeAllItems()
        if (wildcard.state == NSControl.StateValue.on) {
            for index in (2...24).reversed() {
                subnetMaskCombo.addItem(withObjectValue: IPSubnetCalc.digitize(ipAddress: ~(IPSubnetCalc.Constants.addr32Full << index)))
            }
            if (ipsc != nil) {
                subnetMaskCombo.selectItem(withObjectValue: ipsc!.wildcardMask())
            }
            else {
                subnetMaskCombo.selectItem(withObjectValue: "0.0.0.255")
            }
        }
        else {
            for index in (2...24).reversed() {
                subnetMaskCombo.addItem(withObjectValue: IPSubnetCalc.digitize(ipAddress: (IPSubnetCalc.Constants.addr32Full << index)))
            }
            if (ipsc != nil) {
                subnetMaskCombo.selectItem(withObjectValue: ipsc!.subnetMask())
            }
            else {
                subnetMaskCombo.selectItem(withObjectValue: "255.0.0.0")
            }
        }
        /*
         int                         i;
         unsigned int                mask = -1;
         unsigned int                addr_nl;
         
         [subnetMaskCombo removeAllItems];
         if ([wildcard state] == NSOnState)
         {
         for (i = 24; i > 1; i--)
         {
         addr_nl = (mask << i);
         [subnetMaskCombo addItemWithObjectValue: [IPSubnetCalc denumberize: ~addr_nl]];
         }
         if (ipsc)
         {
         [subnetMaskCombo selectItemWithObjectValue: [IPSubnetCalc denumberize: ~([ipsc subnetMaskIntValue])]];
         }
         else
         {
         [subnetMaskCombo selectItemWithObjectValue: @"0.0.0.255"];
         }
         }
         else
         {
         for (i = 24; i > 1; i--)
         {
         addr_nl = (mask << i);
         [subnetMaskCombo addItemWithObjectValue: [IPSubnetCalc denumberize: addr_nl]];
         }
         if (ipsc)
         {
         [subnetMaskCombo selectItemWithObjectValue: [ipsc subnetMask]];
         }
         else
         {
         [subnetMaskCombo selectItemWithObjectValue: @"255.0.0.0"];
         }
         }
         */
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
    
    func windowDidResize(_ notification: Notification)
    {
        bitsOnSlidePos()
    }
    
    func windowWillClose(_ notification: Notification)
    {
        NSApp.terminate(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        initAddressTab()
        initSubnetsTab()
        initCIDRTab()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
