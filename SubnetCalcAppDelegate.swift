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
    
    private var savedtabView: [NSTabViewItem]? //ex tab_tabView
    private var classless: Bool = false
    private var ipsc: IPSubnetCalc?
    
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
            /*
            tab_tabView = [tabView tabViewItems];
            [tabView removeTabViewItem: [tab_tabView objectAtIndex: 1]];
            [tabView removeTabViewItem: [tab_tabView objectAtIndex: 2]];
            [tabView removeTabViewItem: [tab_tabView objectAtIndex: 3]];
            */
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
            subnetBitsCombo.selectItem(withObjectValue: Int(ipsc!.subnetBits()))
            maskBitsCombo.selectItem(withObjectValue: ipsc!.maskBits);
            maxSubnetsCombo.selectItem(withObjectValue: Int(ipsc!.maxSubnets()))
            maxHostsBySubnetCombo.selectItem(withObjectValue: Int(ipsc!.maxHosts()))
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
            //[subnetsHostsView reloadData];
        }
    }

    private func doCIDR()
    {
        if (ipsc != nil) {
            //supernetRoute.stringValue = ipsc!.subnetId()
            supernetAddrRange.stringValue = ipsc!.subnetCIDRRange()
        }
    }
    
    private func doIPSubnetCalc()
    {
        let ipaddr: String
        let ipmask: String?
        
        if (addrField.stringValue.isEmpty) {
            addrField.stringValue = "10.0.0.0"
            ipaddr = "10.0.0.0"
            ipmask = nil
        }
        else {
            if (ipsc == nil) {
                (ipaddr, ipmask) = splitAddrMask(address: addrField.stringValue)
            }
            else {
                ipaddr = ipsc!.ipv4Address
                ipmask = String(ipsc!.maskBits)
            }
        }
        if (IPSubnetCalc.isValidIP(ipAddress: ipaddr, mask: ipmask) == true) {
            //print("IP Address: \(ipaddr) mask: \(ipmask)")
            if (ipmask == nil) {
                ipsc = IPSubnetCalc.init(ipaddr)
            }
            else {
                ipsc = IPSubnetCalc.init(ipAddress: ipaddr, maskbits: Int(ipmask!)!)
            }
            if (ipsc != nil) {
                if (tabView.numberOfTabViewItems != 4 && savedtabView != nil) {
                    tabView.addTabViewItem(savedtabView![1])
                    tabView.addTabViewItem(savedtabView![2])
                    tabView.addTabViewItem(savedtabView![3])
                }
                self.doAddressMap()
                self.doSubnet()
                self.doSubnetHost()
                self.doCIDR()
            }
        }
        else {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Bad IP Address"
            alert.alertStyle = NSAlert.Style.warning
            alert.informativeText = "Bad format"
            alert.runModal()
            return
        }
        /*
        NSRange                        range;
        NSMutableAttributedString   *astr;
        
        if([[addrField stringValue] length] == 0)
            [addrField setStringValue: NSLocalizedString(@"10.0.0.0", nil)];
        if ([self checkAddr: [addrField stringValue]])
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle: @"OK"];
            [alert setMessageText: @"Bad IP Address"];
            [alert setAlertStyle: NSAlertStyleWarning];
            [alert setInformativeText:@"Bad format"];
            if ([alert runModal] == NSAlertFirstButtonReturn)
            return;
        }
        if ([tabView numberOfTabViewItems] != 4)
        {
            [tabView addTabViewItem: [tab_tabView objectAtIndex:1]];
            [tabView addTabViewItem: [tab_tabView objectAtIndex:2]];
            [tabView addTabViewItem: [tab_tabView objectAtIndex:3]];
        }
        ipsc = [[IPSubnetCalc alloc] init];
        if (ipsc)
        {
            if ([tabViewClassLess state] == NSOnState)
            {
                [ipsc setClassless: YES];
            }
            else
            {
                [ipsc setClassless: NO];
            }
            range = [[addrField stringValue] rangeOfString:@"/"];
            if (range.location != NSNotFound)
            {
                mask = -1;
                mask <<= (32 - [[[addrField stringValue] substringFromIndex: range.location + 1] intValue]);
                [addrField setStringValue: [[addrField stringValue] substringToIndex: range.location]];
            }
            if (mask)
                [ipsc initAddressAndMask: [[addrField stringValue] cStringUsingEncoding: NSASCIIStringEncoding] mask: mask];
            else
                [ipsc initAddress: [[addrField stringValue] cStringUsingEncoding: NSASCIIStringEncoding]];
            [self initClassInfos: [ipsc networkClass]];
            [supernetRoute setStringValue: [ipsc supernetRoute: [[supernetMaskBitsCombo objectValueOfSelectedItem] intValue]]];
            [supernetAddrRange setStringValue: [ipsc supernetAddrRange: [[supernetMaskBitsCombo objectValueOfSelectedItem] intValue]]];
            astr = [[NSMutableAttributedString alloc] initWithString : [ipsc bitMap]];
            [classBitMap setAttributedStringValue: astr];
            [classBinaryMap setStringValue: [ipsc binMap]];
            [classHexaMap setStringValue: [ipsc hexMap]];
            [subnetBitsCombo selectItemWithObjectValue: [[ipsc subnetBits] stringValue]];
            [maskBitsCombo selectItemWithObjectValue: [[ipsc maskBits] stringValue]];
            [maxSubnetsCombo selectItemWithObjectValue: [[ipsc subnetMax] stringValue]];
            [maxHostsBySubnetCombo selectItemWithObjectValue: [[ipsc hostMax] stringValue]];
            if ([wildcard state] == NSOnState)
            {
                [subnetMaskCombo selectItemWithObjectValue: [IPSubnetCalc denumberize: ~([ipsc subnetMaskIntValue])]];
            }
            else
            {
                [subnetMaskCombo selectItemWithObjectValue: [ipsc subnetMask]];
            }
            [subnetId setStringValue: [ipsc subnetId]];
            [subnetHostAddrRange setStringValue: [ipsc subnetHostAddrRange]];
            [subnetBroadcast setStringValue: [ipsc subnetBroadcast]];
            [bitsOnSlide setStringValue: [[ipsc maskBits] stringValue]];
            [subnetBitsSlide setFloatValue: [[ipsc maskBits] floatValue]];
            [self doSupernetCalc: [ipsc maskBitsIntValue]];
            [self bitsOnSlidePos];
            [subnetsHostsView reloadData];
        }
         */
    }
    
    private func doSupernetCalc(maskBits: UInt)
    {
        
    }
    
    @IBAction func calc(_ sender: AnyObject)
    {
        if (ipsc != nil) {
            ipsc = nil
        }
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
                //return (ipsc!.subnetMax)
                return 0
            }
        }
        return 0
        /*
        if (ipsc)
        {
            if ([ipsc classless] == YES)
                return (pow(2, ([[ipsc maskBits] intValue] - NETWORK_BITS_MIN_CLASSLESS)));
            else
                return ([[ipsc subnetMax] intValue]);
        }
 */
    }
    
    //Display all subnets info in the TableView Subnet/Hosts
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?,
               row: Int) -> Any?
    {
        return (Any).self
    }
    
    
    @IBAction func subnetBitsSlide(_ sender: AnyObject)
    {
        
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
