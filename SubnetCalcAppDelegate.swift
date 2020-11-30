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
        static let BUFFER_LINES:Int = 200000000
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
    
    private func doCIDR(maskbits: Int? = nil)
    {
        if (ipsc != nil) {
            if (maskbits == nil) {
                supernetMaskBitsCombo.selectItem(withObjectValue: String(ipsc!.maskBits))
                supernetMaskCombo.selectItem(withObjectValue: ipsc!.subnetMask())
                supernetMaxSubnetsCombo.selectItem(withObjectValue: String(ipsc!.maxCIDRSubnets()))
                supernetMaxAddr.selectItem(withObjectValue: String(ipsc!.maxHosts()))
                supernetMaxCombo.selectItem(withObjectValue: String(ipsc!.maxCIDRSupernet()))
                supernetRoute.stringValue = ipsc!.subnetId() + "/" + String(ipsc!.maskBits)
                supernetAddrRange.stringValue = ipsc!.subnetCIDRRange()
            }
            else {
                let ipsc_tmp = IPSubnetCalc(ipAddress: ipsc!.ipv4Address, maskbits: maskbits!)
                if (ipsc_tmp != nil) {
                    supernetMaskBitsCombo.selectItem(withObjectValue: String(ipsc_tmp!.maskBits))
                    supernetMaskCombo.selectItem(withObjectValue: ipsc_tmp!.subnetMask())
                    supernetMaxSubnetsCombo.selectItem(withObjectValue: String(ipsc_tmp!.maxCIDRSubnets()))
                    supernetMaxAddr.selectItem(withObjectValue: String(ipsc_tmp!.maxHosts()))
                    supernetMaxCombo.selectItem(withObjectValue: String(ipsc_tmp!.maxCIDRSupernet()))
                    supernetRoute.stringValue = ipsc_tmp!.subnetId() + "/" + String(ipsc_tmp!.maskBits)
                    supernetAddrRange.stringValue = ipsc_tmp!.subnetCIDRRange()
                }
            }
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
        if (tabView.numberOfTabViewItems != 4 && savedTabView != nil) {
            tabView.addTabViewItem(savedTabView![1])
            tabView.addTabViewItem(savedTabView![2])
            tabView.addTabViewItem(savedTabView![3])
        }
        if (sender.indexOfSelectedItem() == 0)
        {
            classBitMap.stringValue = "nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh"
            classBinaryMap.stringValue = "00000001000000000000000000000000"
        }
        else if (sender.indexOfSelectedItem() == 1)
        {
            classBitMap.stringValue = "nnnnnnnn.nnnnnnnn.hhhhhhhh.hhhhhhhh"
            classBinaryMap.stringValue = "10000000000000000000000000000000"
        }
        else if (sender.indexOfSelectedItem() == 2)
        {
            classBitMap.stringValue = "nnnnnnnn.nnnnnnnn.nnnnnnnn.hhhhhhhh"
            classBinaryMap.stringValue = "11000000000000000000000000000000"
        }
        else if (sender.indexOfSelectedItem() == 3)
        {
            savedTabView = tabView.tabViewItems
            if (savedTabView != nil)
            {
                tabView.removeTabViewItem(savedTabView![1])
                tabView.removeTabViewItem(savedTabView![2])
                tabView.removeTabViewItem(savedTabView![3])
            }
            classBitMap.stringValue = "hhhhhhhh.hhhhhhhh.hhhhhhhh.hhhhhhhh"
            classBinaryMap.stringValue = "11100000000000000000000000000000"
        }
    }
    
    @IBAction func changeMaxHosts(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.indexOfSelectedItem != -1) {
            ipsc!.maskBits = 30 - sender.indexOfSelectedItem()
            self.doIPSubnetCalc()
        }
        else {
            myAlert(message: "Bad Max Hosts", info: "Bad value")
            return
        }
    }
    
    @IBAction func changeMaxSubnets(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.indexOfSelectedItem != -1) {
            ipsc!.maskBits = 8 + sender.indexOfSelectedItem()
            self.doIPSubnetCalc()
        }
        else {
            myAlert(message: "Bad Max Subnets", info: "Bad value")
            return
        }
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
        // Check cast as String needed ?
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
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.objectValueOfSelectedItem as? String) != nil {
            let classType = ipsc!.netClass()
            var result: Int = -1
            
            if (classType == "A") {
                result = sender.intValue - 8
            }
            else if (classType == "B") {
                result = sender.intValue - 16
            }
            else if (classType == "C") {
                result = sender.intValue - 24
            }
            if (result >= 0) {
                ipsc!.maskBits = sender.intValue
                self.doIPSubnetCalc()
            }
            else {
                doCIDR(maskbits: sender.intValue)
            }
        }
        else {
            myAlert(message: "Bad CIDR Mask Bits", info: "Bad format")
            return
        }
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
            if (tabViewClassLess.state == NSControl.StateValue.on) {
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
        if (sender.intValue as Int >= Constants.NETWORK_BITS_MIN)
        {
            ipsc!.maskBits = sender.intValue as Int
            self.doIPSubnetCalc()
            //subnetsHostsView.reloadData()
        }
        else {
            let maskbits = sender.intValue as Int
            ipsc!.maskBits = Constants.NETWORK_BITS_MIN
            self.doIPSubnetCalc()
            if (tabViewClassLess.state == NSControl.StateValue.on) {
                ipsc!.maskBits = maskbits
                self.doSubnetHost()
            }
        }
    }
    
    @IBAction func changeTableViewClass(_ sender: AnyObject)
    {
        if (tabViewClassLess.state == NSControl.StateValue.off) {
            if (ipsc != nil) {
                if (ipsc!.maskBits < Constants.NETWORK_BITS_MIN) {
                    ipsc!.maskBits = Constants.NETWORK_BITS_MIN
                    self.doIPSubnetCalc()
                }
            }
        }
        self.doSubnetHost()
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
        }
        else {
            for index in (2...24).reversed() {
                subnetMaskCombo.addItem(withObjectValue: IPSubnetCalc.digitize(ipAddress: (IPSubnetCalc.Constants.addr32Full << index)))
            }
            if (ipsc != nil) {
                subnetMaskCombo.selectItem(withObjectValue: ipsc!.subnetMask())
            }
        }
    }
    
    @IBAction func exportCSV(_ sender: AnyObject)
    {
        if (ipsc != nil) {
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["csv"]
            panel.begin(completionHandler: { (result) in
                if (result == NSApplication.ModalResponse.OK && panel.url != nil) {
                    if #available(OSX 10.14, *) {
                        let fileMgt = FileManager(authorization: NSWorkspace.Authorization())
                        fileMgt.createFile(atPath: panel.url!.path, contents: nil, attributes: nil)
                        //var cvsData = NSMutableData.init(capacity: Constants.BUFFER_LINES)
                        var cvsData = Data(capacity: Constants.BUFFER_LINES)
                        let cvsFile = FileHandle(forWritingAtPath: panel.url!.path)
                        if (cvsFile != nil) {
                            var cvsStr = "#;Subnet ID;Range;Broadcast\n"
                            for index in (0...(self.ipsc!.maxSubnets() - 1)) {
                                let mask: UInt32 = UInt32(index) << (32 - self.ipsc!.maskBits)
                                let ipaddr = (IPSubnetCalc.numerize(ipAddress: self.ipsc!.subnetId())) | mask
                                let ipsc_tmp = IPSubnetCalc(ipAddress: IPSubnetCalc.digitize(ipAddress: ipaddr), maskbits: self.ipsc!.maskBits)
                                if (ipsc_tmp != nil) {
                                    cvsStr.append("\(index + 1);\(ipsc_tmp!.subnetId());\(ipsc_tmp!.subnetRange());\(ipsc_tmp!.subnetBroadcast())\n")
                                }
                            }
                            cvsData.append(cvsStr.data(using: String.Encoding.ascii)!)
                            cvsFile!.write(cvsData)
                            cvsFile!.synchronizeFile()
                            cvsFile!.closeFile()
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                        
                    }
                }
            )
            }
    }
    
    @IBAction func exportClipboard(_ sender: AnyObject)
    {
        if (ipsc != nil) {
            let pb: NSPasteboard = NSPasteboard.general
            pb.clearContents()
            let str = "Address Class Type: \(ipsc!.netClass())\nIP Address: \(ipsc!.ipv4Address)\nSubnet ID: \(ipsc!.subnetId())\nSubnet Mask: \(ipsc!.subnetMask())\nBroadcast: \(ipsc!.subnetBroadcast())\nIP Range: \(ipsc!.subnetRange())\nMask Bits: \(ipsc!.maskBits)\nSubnet Bits: \(ipsc!.subnetBits())\nMax Subnets: \(ipsc!.maxSubnets())\nMax Hosts / Subnet: \(ipsc!.maxHosts())\nAddress Hexa: \(ipsc!.hexaMap())\nBit Map: \(ipsc!.bitMap())\nBinary Map: \(ipsc!.binaryMap())\n"
            pb.setString(str, forType: NSPasteboard.PasteboardType.string)
        }
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
