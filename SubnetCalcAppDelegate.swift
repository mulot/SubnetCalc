//
//  SubnetCalcAppDelegate.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa

@main
class SubnetCalcAppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSTableViewDataSource {
    private enum Constants {
        static let defaultIP: String = "10.0.0.0"
        static let defaultIPv6Mask: String = "64"
        static let BUFFER_LINES:Int = 200000000
        static let NETWORK_BITS_MIN_CLASSLESS:Int = 1
        static let NETWORK_BITS_MIN:Int = 8
        static let NETWORK_BITS_MAX:Int = 32
    }
    
    //General UI elements
    @IBOutlet var window: NSWindow!
    @IBOutlet var addrField: NSTextField!
    @IBOutlet var exportButton: NSPopUpButton!
    @IBOutlet var tabView: NSTabView!
    @IBOutlet var darkModeMenu: NSMenuItem!
    @IBOutlet var NSApp: NSApplication!
    
    //IPv4 UI elements
    @IBOutlet var classBinaryMap: NSTextField!
    @IBOutlet var classBitMap: NSTextField!
    @IBOutlet var classHexaMap: NSTextField!
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
    @IBOutlet var subnetBitsSlide: NSSlider!
    @IBOutlet var bitsOnSlide: NSTextField!
    @IBOutlet var tabViewClassLess: NSButton!
    @IBOutlet var wildcard: NSButton!
    @IBOutlet var dotted: NSButton!
    
    //IPv6 UI elements
    @IBOutlet var ipv6Address: NSTextField!
    @IBOutlet var ipv6to4Address: NSTextField!
    @IBOutlet var ipv6maskBitsCombo: NSComboBox!
    @IBOutlet var ipv6SubnetsCombo: NSComboBox!
    @IBOutlet var ipv6maxHostsCombo: NSComboBox!
    @IBOutlet var ipv6Network: NSTextField!
    @IBOutlet var ipv6Range: NSTextField!
    @IBOutlet var ipv6Type: NSTextField!
    @IBOutlet var ipv6HexaID: NSTextField!
    @IBOutlet var ipv6Decimal: NSTextField!
    @IBOutlet var ipv6Arpa: NSTextField!
    @IBOutlet var ipv6Compact: NSButton!
    @IBOutlet var ipv6to4Box: NSBox!
    
    
    //Private global vars
    private var savedTabView: [NSTabViewItem]? //ex tab_tabView
    private var ipsc: IPSubnetCalc?
    
    
    //Private IPv4 functions
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
        classBitMap.stringValue = "nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh"
        classBinaryMap.stringValue = "00000001.00000000.00000000.00000000"
        classHexaMap.stringValue = "01.00.00.00"
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
            /*
            savedTabView = tabView.tabViewItems
            if (savedTabView != nil)
            {
                tabView.removeTabViewItem(savedTabView![1])
                tabView.removeTabViewItem(savedTabView![2])
                tabView.removeTabViewItem(savedTabView![3])
            }
             */
        }
        else if (c == "E")
        {
            classType.selectItem(at: 4)
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
            if (dotted.state == NSControl.StateValue.on) {
                classBitMap.stringValue = ipsc!.bitMap(dotted: true)
                classBinaryMap.stringValue = ipsc!.binaryMap(dotted: true)
                classHexaMap.stringValue = ipsc!.hexaMap(dotted: true)
            }
            else {
                classBitMap.stringValue = ipsc!.bitMap(dotted: false)
                classBinaryMap.stringValue = ipsc!.binaryMap(dotted: false)
                classHexaMap.stringValue = ipsc!.hexaMap(dotted: false)
            }
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
        var ipaddr: String
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
            addrField.stringValue = ipaddr
            if (IPSubnetCalc.isValidIPv6(ipAddress: ipaddr, mask: Int(ipmask ?? Constants.defaultIPv6Mask)) == true) {
                if (ipsc != nil) {
                    ipaddr = ipsc!.ipv4Address
                }
                if (ipmask != nil) {
                    if (Int(ipmask!)! >= (96 + 8)) {
                        ipmask = String(Int(ipmask!)! - 96)
                    }
                    else {
                        ipmask = "8"
                    }
                }
            }
            if (ipmask == nil && ipsc != nil) {
                ipmask = String(ipsc!.maskBits)
            }
        }
        if (IPSubnetCalc.isValidIP(ipAddress: ipaddr, mask: ipmask) == true) {
            //print("IP Address: \(ipaddr) mask: \(ipmask)")
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
                self.doIPv6()
            }
        }
        else {
            myAlert(message: "Bad IPv4 Address", info: "Bad format: \(ipaddr)/\(ipmask ?? "")")
            return
        }
    }
    
    //Private IPv6 functions
    private func initIPv6Tab() {
        var total = Decimal()
        var number: Decimal = 2
        
        for index in (1...128) {
            ipv6maskBitsCombo.addItem(withObjectValue: String(index))
        }
        for index in (0...127) {
            NSDecimalPower(&total, &number , index, NSDecimalNumber.RoundingMode.plain)
            ipv6maxHostsCombo.addItem(withObjectValue: total)
        }
    }
    
    private func doIPv6()
    {
        if (ipsc != nil) {
            var total = Decimal()
            var number: Decimal = 2
            var typeConv: String
            
            if (ipv6Compact.state == NSControl.StateValue.on) {
                ipv6Address.stringValue = ipsc!.compactAddressIPv6(ipAddress: ipsc!.ipv6Address)
                ipv6Network.stringValue = ipsc!.compactAddressIPv6(ipAddress: ipsc!.networkIPv6())
            }
            else {
                ipv6Address.stringValue = ipsc!.fullAddressIPv6(ipAddress: ipsc!.ipv6Address)
                ipv6Network.stringValue = ipsc!.fullAddressIPv6(ipAddress: ipsc!.networkIPv6())
            }
            (ipv6to4Address.stringValue, typeConv) = IPSubnetCalc.convertIPv6toIPv4(ipAddress: ipsc!.ipv6Address)
            ipv6to4Box.title = "IPv4 conversion" + " (\(typeConv))"
            ipv6maskBitsCombo.selectItem(withObjectValue: String(ipsc!.ipv6MaskBits))
            ipv6maxHostsCombo.selectItem(withObjectValue: ipsc!.totalIPAddrIPv6())
            ipv6Range.stringValue = ipsc!.networkRangeIPv6()
            ipv6Type.stringValue = ipsc!.resBlockIPv6() ?? "None"
            ipv6HexaID.stringValue = ipsc!.hexaIDIPv6()
            ipv6Decimal.stringValue = ipsc!.dottedDecimalIPv6()
            ipv6Arpa.stringValue = ipsc!.ip6ARPA()
            ipv6SubnetsCombo.removeAllItems()
            for index in (1...ipsc!.ipv6MaskBits).reversed() {
                NSDecimalPower(&total, &number , ipsc!.ipv6MaskBits - index, NSDecimalNumber.RoundingMode.plain)
                if (total == 1) {
                    ipv6SubnetsCombo.addItem(withObjectValue: "/\(index)\t\(total) network")
                }
                else {
                    ipv6SubnetsCombo.addItem(withObjectValue: "/\(index)\t\(total) networks")
                }
            }
            ipv6SubnetsCombo.selectItem(at: 0)
        }
    }
    
    private func doIPv6SubnetCalc()
    {
        var ipaddr: String
        var ipmask: String?
        
        (ipaddr, ipmask) = splitAddrMask(address: addrField.stringValue)
        addrField.stringValue = ipaddr
        if (IPSubnetCalc.isValidIP(ipAddress: ipaddr, mask: ipmask) == true) {
            if (ipsc != nil) {
                ipaddr = ipsc!.ipv6Address
                //print("doIPv6SubnetCalc ipaddr to ipv6 : \(ipsc!.ipv6Address)")
            }
        }
        if (ipmask == nil) {
            if (ipsc != nil) {
                ipmask = String(ipsc!.ipv6MaskBits)
                //print("doIPv6SubnetCalc ipmask ipv6 : \(ipsc!.ipv6MaskBits)")
            }
            else {
                ipmask = Constants.defaultIPv6Mask
            }
        }
        else if (Int(ipmask!) == nil) {
            myAlert(message: "Bad IPv6 mask", info: "Bad format: \(ipmask!)")
            return
        }
        if (IPSubnetCalc.isValidIPv6(ipAddress: ipaddr, mask: Int(ipmask!)) == true) {
            //print("IP Address: \(ipaddr) mask: \(ipmask)")
            ipsc = IPSubnetCalc(ipv6: ipaddr, maskbits: Int(ipmask!)!)
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
                self.doIPv6()
            }
        }
        else {
            myAlert(message: "Bad IPv6 Address", info: "Bad format: \(ipaddr)/\(ipmask ?? "")")
            return
        }
    }
    
    
    //IPv4 UI actions
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
            classBinaryMap.stringValue = "00000001.00000000.00000000.00000000"
            classHexaMap.stringValue = "01.00.00.00"
        }
        else if (sender.indexOfSelectedItem() == 1)
        {
            classBitMap.stringValue = "nnnnnnnn.nnnnnnnn.hhhhhhhh.hhhhhhhh"
            classBinaryMap.stringValue = "10000000.00000000.00000000.00000000"
            classHexaMap.stringValue = "80.00.00.00"
        }
        else if (sender.indexOfSelectedItem() == 2)
        {
            classBitMap.stringValue = "nnnnnnnn.nnnnnnnn.nnnnnnnn.hhhhhhhh"
            classBinaryMap.stringValue = "11000000.00000000.00000000.00000000"
            classHexaMap.stringValue = "C0.00.00.00"
        }
        else if (sender.indexOfSelectedItem() == 3)
        {
            /*
            savedTabView = tabView.tabViewItems
            if (savedTabView != nil)
            {
                tabView.removeTabViewItem(savedTabView![1])
                tabView.removeTabViewItem(savedTabView![2])
                tabView.removeTabViewItem(savedTabView![3])
            }
             */
            classBitMap.stringValue = "hhhhhhhh.hhhhhhhh.hhhhhhhh.hhhhhhhh"
            classBinaryMap.stringValue = "11100000.00000000.00000000.00000000"
            classHexaMap.stringValue = "E0.00.00.00"
        }
        else if (sender.indexOfSelectedItem() == 4)
        {
            /*
            savedTabView = tabView.tabViewItems
            if (savedTabView != nil)
            {
                tabView.removeTabViewItem(savedTabView![1])
                tabView.removeTabViewItem(savedTabView![2])
                tabView.removeTabViewItem(savedTabView![3])
            }
             */
            classBitMap.stringValue = "hhhhhhhh.hhhhhhhh.hhhhhhhh.hhhhhhhh"
            classBinaryMap.stringValue = "11110000.00000000.00000000.00000000"
            classHexaMap.stringValue = "F0.00.00.00"
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
            myAlert(message: "Bad Max Hosts", info: "Bad selection")
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
            myAlert(message: "Bad Max Subnets", info: "Bad selection")
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
            myAlert(message: "Bad Subnet Bits", info: "Bad selection")
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
                ipsc!.maskBits = IPSubnetCalc.maskBits(mask: ~mask)
            }
            else {
                ipsc!.maskBits = IPSubnetCalc.maskBits(mask: mask)
                //print("changeSubnetMask object value : \(str)")
            }
            self.doIPSubnetCalc()
        }
        else {
            myAlert(message: "Bad Subnet Mask", info: "Bad selection")
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
            myAlert(message: "Bad Mask Bits", info: "Bad selection")
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
            myAlert(message: "Bad CIDR Mask Bits", info: "Bad selection")
            return
        }
    }
    
    @IBAction func changeSupernetMask(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if let maskStr = sender.objectValueOfSelectedItem as? String {
            let mask:UInt32 = IPSubnetCalc.numerize(ipAddress: maskStr)
            let maskbits:Int = IPSubnetCalc.maskBits(mask: mask)
            let classType = ipsc!.netClass()
            var result: Int = -1
            
            if (classType == "A") {
                result = maskbits - 8
            }
            else if (classType == "B") {
                result = maskbits - 16
            }
            else if (classType == "C") {
                result = maskbits - 24
            }
            if (result >= 0) {
                ipsc!.maskBits = maskbits
                self.doIPSubnetCalc()
            }
            else {
                doCIDR(maskbits: maskbits)
            }
        }
        else {
            myAlert(message: "Bad CIDR Mask", info: "Bad selection")
            return
        }
    }
    
    @IBAction func changeSupernetMax(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.indexOfSelectedItem != -1) {
            let classType = ipsc!.netClass()
            var result: Int = -1
            
            if (classType == "A") {
                result = 8 - sender.indexOfSelectedItem
            }
            else if (classType == "B") {
                result = 16 - sender.indexOfSelectedItem
            }
            else if (classType == "C") {
                result = 24 - sender.indexOfSelectedItem
            }
            if (result > 0) {
                doCIDR(maskbits: result)
            }
            else {
                myAlert(message: "Bad Max Supernets", info: "Value too high")
                return
            }
        }
        else {
            myAlert(message: "Bad Max Supernets", info: "Bad selection")
            return
        }
    }
    
    @IBAction func changeSupernetMaxAddr(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.indexOfSelectedItem != -1) {
            if ((32 - sender.indexOfSelectedItem - 1) < 32) {
                doCIDR(maskbits: (32 - sender.indexOfSelectedItem - 1))
            }
            else {
                myAlert(message: "Bad Max Adresses", info: "Bad value")
                return
            }
        }
        else {
            myAlert(message: "Bad Max Adresses", info: "Bad selection")
            return
        }
    }
    
    @IBAction func changeSupernetMaxSubnets(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.indexOfSelectedItem != -1) {
            if ((32 - sender.indexOfSelectedItem) < 32) {
                doCIDR(maskbits: (32 - sender.indexOfSelectedItem))
            }
            else {
                myAlert(message: "Bad Max Subnets", info: "Bad value")
                return
            }
        }
        else {
            myAlert(message: "Bad Max Subnets", info: "Bad selection")
            return
        }
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
            let ipaddr: UInt32 = (((IPSubnetCalc.numerize(ipAddress: ipsc!.subnetId())) >> (32 - ipsc!.maskBits)) + UInt32(row)) << (32 - ipsc!.maskBits)
            let ipsc_tmp = IPSubnetCalc(ipAddress: IPSubnetCalc.digitize(ipAddress: ipaddr), maskbits: ipsc!.maskBits)
            //print("tableView Row: \(row) IP num : \(ipaddr) IP: \(IPSubnetCalc.digitize(ipAddress: ipaddr)) IP Subnet: \(ipsc_tmp!.subnetId())")
            if (tableColumn != nil && ipsc_tmp != nil) {
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
                self.doCIDR(maskbits: maskbits)
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
    
    @IBAction func changeDotted(_ sender: AnyObject)
    {
        self.doAddressMap()
    }
    
    //IPv6 UI actions
    @IBAction func changeIPv6Format(_ sender: AnyObject)
    {
        self.doIPv6()
    }
    
    @IBAction func changeIPv6MaskBits(_ sender: AnyObject)
    {
        //print("changeIPv6MaskBits")
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.objectValueOfSelectedItem as? String) != nil {
            ipsc!.ipv6MaskBits = sender.intValue
            self.doIPv6SubnetCalc()
        }
        else {
            myAlert(message: "Bad IPv6 Mask Bits", info: "Bad selection")
            return
        }
    }
    
    @IBAction func changeIPv6Subnets(_ sender: AnyObject)
    {
        if (ipsc == nil ) {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        ipsc!.ipv6MaskBits -= sender.indexOfSelectedItem()
        self.doIPv6SubnetCalc()
    }
    
    @IBAction func changeIPv6MaxHosts(_ sender: AnyObject)
    {
        if (ipsc == nil)
        {
            ipsc = IPSubnetCalc(Constants.defaultIP)
        }
        if (sender.indexOfSelectedItem != -1) {
            ipsc!.ipv6MaskBits = 128 - sender.indexOfSelectedItem()
            self.doIPv6SubnetCalc()
        }
        else {
            myAlert(message: "Bad Max Hosts", info: "Bad selection")
            return
        }
    }
    
    //General UI actions
    @IBAction func calc(_ sender: AnyObject)
    {
        if (addrField.stringValue.contains(":")) {
            self.doIPv6SubnetCalc()
            tabView.selectTabViewItem(at: 3)
        }
        else {
            self.doIPSubnetCalc()
            tabView.selectTabViewItem(at: 0)
        }
    }
    
    @IBAction func ipAddrEdit(_ sender: AnyObject)
    {
        self.calc(sender)
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
            let ipv4Info = "IPv4 Address Class Type: \(ipsc!.netClass())\nIPv4 Address: \(ipsc!.ipv4Address)\nIPv4 Subnet ID: \(ipsc!.subnetId())\nIPv4 Subnet Mask: \(ipsc!.subnetMask())\nIPv4 Broadcast: \(ipsc!.subnetBroadcast())\nIPv4 Address Range: \(ipsc!.subnetRange())\nIPv4 Mask Bits: \(ipsc!.maskBits)\nIPv4 Subnet Bits: \(ipsc!.subnetBits())\nMax IPv4 Subnets: \(ipsc!.maxSubnets())\nIPv4 Max Hosts / Subnet: \(ipsc!.maxHosts())\nIPv4 Address Hexa: \(ipsc!.hexaMap())\nIPv4 Bit Map: \(ipsc!.bitMap())\nIPv4 Binary Map: \(ipsc!.binaryMap())\n"
            let ipv6Info = "\nIPv6 Address: \(ipsc!.ipv6Address)\nLong IPv6 Address: \(ipsc!.fullAddressIPv6(ipAddress: ipsc!.ipv6Address))\nShort IPv6 Address: \(ipsc!.compactAddressIPv6(ipAddress: ipsc!.ipv6Address))\nIPv6-to-IPv4: \(IPSubnetCalc.convertIPv6toIPv4(ipAddress: ipsc!.ipv6Address))\nIPv6 Mask Bits: \(ipsc!.ipv6MaskBits)\nIPv6 Max Hosts / Subnet: \(ipsc!.totalIPAddrIPv6())\nNetwork: \(ipsc!.compactAddressIPv6(ipAddress: ipsc!.networkIPv6()))\nIPv6 Address Range: \(ipsc!.networkRangeIPv6())\nIPv6 Address Type: \(ipsc!.resBlockIPv6() ?? "None")\nIPv6 Address Hexa: \(ipsc!.hexaIDIPv6())\nIPv6 Address Dotted Decimal: \(ipsc!.dottedDecimalIPv6())\nIP6.ARPA: \(ipsc!.ip6ARPA())\n"
            pb.setString(ipv4Info + ipv6Info, forType: NSPasteboard.PasteboardType.string)
        }
    }
    
    @IBAction func darkMode(_ sender: AnyObject)
    {
        if #available(OSX 10.14, *) {
            if (darkModeMenu!.state == NSControl.StateValue.off) {
                NSApp.appearance = NSAppearance(named: NSAppearance.Name.darkAqua)
                darkModeMenu.state = NSControl.StateValue.on
            }
            else if (darkModeMenu!.state == NSControl.StateValue.on) {
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
        initSubnetsTab()
        initCIDRTab()
        initIPv6Tab()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
