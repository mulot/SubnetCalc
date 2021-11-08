//
//  SubnetCalcUITest.swift
//  SubnetCalcUITests
//
//  Created by Julien Mulot on 01/12/2020.
//

import XCTest

class SubnetCalcUITest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let subnetcalcWindow = XCUIApplication().windows["SubnetCalc"]
        let ipaddrfieldTextField = subnetcalcWindow.textFields["ipaddrfield"]
        
        subnetcalcWindow.tabs["IPv4"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeText("10.32.2.52/30\r")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetbitscombo"].value as! String, "22")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maskbitscombo"].value as! String, "30")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "255.255.255.252")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxsubnetcombo"].value as! String, "4194304")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxhostscombo"].value as! String, "2")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetrangetext"].value as! String, "10.32.2.53 - 10.32.2.54")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetidtext"].value as! String, "10.32.2.52")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetbroadcasttext"].value as! String, "10.32.2.55")
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class A: 1.0.0.0 - 126.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "nnnnnnnn.ssssssss.ssssssss.sssssshh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "00001010.00100000.00000010.00110100")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "0A.20.02.34")
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "30")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.255.255.252")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "4")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "2")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "10.32.2.52/30")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "10.32.2.52 - 10.32.2.55")
        
        subnetcalcWindow.tabs["IPv4"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("192.168.254.129/12\r")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetbitscombo"].value as! String, "0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maskbitscombo"].value as! String, "12")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "255.240.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxsubnetcombo"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxhostscombo"].value as! String, "1048574")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetrangetext"].value as! String, "192.160.0.1 - 192.175.255.254")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetidtext"].value as! String, "192.160.0.0")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetbroadcasttext"].value as! String, "192.175.255.255")
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class C: 192.0.0.0 - 223.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "nnnnnnnn.nnnnhhhh.hhhhhhhh.hhhhhhhh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "11000000.10101000.11111110.10000001")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "C0.A8.FE.81")
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "12")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.240.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "1048576")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "1048574")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "4096")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "192.160.0.0/12")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "192.160.0.0 - 192.175.255.255")
        
        subnetcalcWindow.tabs["IPv4"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("10.2.255.130/32\r")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetbitscombo"].value as! String, "24")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maskbitscombo"].value as! String, "32")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "255.255.255.255")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxsubnetcombo"].value as! String, "16777216")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxhostscombo"].value as! String, "0")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetrangetext"].value as! String, "10.2.255.130 - 10.2.255.130")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetidtext"].value as! String, "10.2.255.130")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetbroadcasttext"].value as! String, "10.2.255.130")
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class A: 1.0.0.0 - 126.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "nnnnnnnn.ssssssss.ssssssss.ssssssss")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "00001010.00000010.11111111.10000010")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "0A.02.FF.82")
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "32")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.255.255.255")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "10.2.255.130/32")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "10.2.255.130 - 10.2.255.130")

        subnetcalcWindow.tabs["IPv4"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("242.2.255.130/28\r")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetbitscombo"].value as! String, "0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maskbitscombo"].value as! String, "28")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "255.255.255.240")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxsubnetcombo"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxhostscombo"].value as! String, "14")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetrangetext"].value as! String, "242.2.255.129 - 242.2.255.142")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetidtext"].value as! String, "242.2.255.128")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetbroadcasttext"].value as! String, "242.2.255.143")
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class E/Reserved: 240.0.0.0 - 255.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "hhhhhhhh.hhhhhhhh.hhhhhhhh.hhhhhhhh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "11110010.00000010.11111111.10000010")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "F2.02.FF.82")
        subnetcalcWindow.checkBoxes["wildcardmask"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "0.0.0.15")
        subnetcalcWindow.checkBoxes["dottedipv4"].click()
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "11110010000000101111111110000010")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "F202FF82")
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "28")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.255.255.240")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "16")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "14")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "242.2.255.128/28")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "242.2.255.128 - 242.2.255.143")
        subnetcalcWindow.tabs["IPv4"].click()
        subnetcalcWindow.checkBoxes["wildcardmask"].click()
        subnetcalcWindow.checkBoxes["dottedipv4"].click()
        
        subnetcalcWindow.tabs["IPv4"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("172.16.242.132/8\r")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetbitscombo"].value as! String, "0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maskbitscombo"].value as! String, "8")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "255.0.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxsubnetcombo"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxhostscombo"].value as! String, "16777214")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetrangetext"].value as! String, "172.0.0.1 - 172.255.255.254")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetidtext"].value as! String, "172.0.0.0")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetbroadcasttext"].value as! String, "172.255.255.255")
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class B: 128.0.0.0 - 191.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "10101100.00010000.11110010.10000100")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "AC.10.F2.84")
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "8")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.0.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "16777216")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "16777214")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "256")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "172.0.0.0/8")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "172.0.0.0 - 172.255.255.255")
        
        subnetcalcWindow.menuButtons["exportbutton"].click()
        subnetcalcWindow.menuItems["exportClipboard:"].click()
        let pb: NSPasteboard = NSPasteboard.general
        let pbContent = pb.string(forType: NSPasteboard.PasteboardType.string)
        let validContent = "IPv4 Address Class Type: B\nIPv4 Address: 172.16.242.132\nIPv4 Subnet ID: 172.0.0.0\nIPv4 Subnet Mask: 255.0.0.0\nIPv4 Broadcast: 172.255.255.255\nIPv4 Address Range: 172.0.0.1 - 172.255.255.254\nIPv4 Mask Bits: 8\nIPv4 Subnet Bits: 0\nMax IPv4 Subnets: 1\nIPv4 Max Hosts / Subnet: 16777214\nIPv4 Address Hexa: AC.10.F2.84\nIPv4 Bit Map: nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh\nIPv4 Binary Map: 10101100.00010000.11110010.10000100\n\nIPv6 Address: 0:0:0:0:0:ffff:ac10:f284\nLong IPv6 Address: 0000:0000:0000:0000:0000:ffff:ac10:f284\nShort IPv6 Address: ::ffff:ac10:f284\nIPv6-to-IPv4: (\"172.16.242.132\", \"IPv4-Mapped\")\nIPv6 Mask Bits: 104\nIPv6 Max Hosts / Subnet: 16777216\nNetwork: ::ffff:ac00:0\nIPv6 Address Range: 0000:0000:0000:0000:0000:ffff:ac00:0000 - 0000:0000:0000:0000:0000:ffff:acff:ffff\nIPv6 Address Type: None\nIPv6 Address Hexa: 0x00000000000000000000ffffac10f284\nIPv6 Address Dotted Decimal: 0.0.0.0.0.0.0.0.0.0.255.255.172.16.242.132\nIP6.ARPA: 4.8.2.f.0.1.c.a.f.f.f.f.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa\n"
        XCTAssertEqual(pbContent,validContent)
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("2001:0db8:0000:85a3:0000:0000:ac1f:8001/127\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "2001:db8:0:85a3::ac1f:8001")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv4addrconvtext"].value as! String, "172.31.128.1")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["ipv6maskbitscombo"].value as! String, "127")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["ipv6maxsubnetscombo"].value as! String, "/127\t1 network")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["ipv6maxhostscombo"].value as! String, "2")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6networktext"].value as! String, "2001:db8:0:85a3::ac1f:8000")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6rangetext"].value as! String, "2001:0db8:0000:85a3:0000:0000:ac1f:8000 - 2001:0db8:0000:85a3:0000:0000:ac1f:8001")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6typetext"].value as! String, "None")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6hexatext"].value as! String, "0x20010db8000085a300000000ac1f8001")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6decimaltext"].value as! String, "32.1.13.184.0.0.133.163.0.0.0.0.172.31.128.1")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6arpatext"].value as! String, "1.0.0.8.f.1.c.a.0.0.0.0.0.0.0.0.3.a.5.8.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("2a07:2900:8077:ffb1:e0::4/126\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "2a07:2900:8077:ffb1:e0::4")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv4addrconvtext"].value as! String, "0.0.0.4")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["ipv6maskbitscombo"].value as! String, "126")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["ipv6maxsubnetscombo"].value as! String, "/126\t1 network")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["ipv6maxhostscombo"].value as! String, "4")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6networktext"].value as! String, "2a07:2900:8077:ffb1:e0::4")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6rangetext"].value as! String, "2a07:2900:8077:ffb1:00e0:0000:0000:0004 - 2a07:2900:8077:ffb1:00e0:0000:0000:0007")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6typetext"].value as! String, "None")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6hexatext"].value as! String, "0x2a0729008077ffb100e0000000000004")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6decimaltext"].value as! String, "42.7.41.0.128.119.255.177.0.224.0.0.0.0.0.4")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6arpatext"].value as! String, "4.0.0.0.0.0.0.0.0.0.0.0.0.e.0.0.1.b.f.f.7.7.0.8.0.0.9.2.7.0.a.2.ip6.arpa")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("2001:0000:0000:85a3:0000:0000:ac1f:0801\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "2001::85a3:0:0:ac1f:801")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("2001:0000:0000:85a3:0000:0000:ac1f:0000\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "2001::85a3:0:0:ac1f:0")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("2001:0db8:0000:85a3:0200:0000:ac1f:0000\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "2001:db8:0:85a3:200:0:ac1f:0")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("2001:0db8:0000:85a3:0200:0020:0000:0000\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "2001:db8:0:85a3:200:20::")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("0000:0000:0000:0000:0000:0000:0000:0001\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "::1")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("0000:0000:0000:0000:0000:0000:0000:0000\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "::")
        
        subnetcalcWindow.tabs["IPv6"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.typeKey("a", modifierFlags:.command)
        ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])
        ipaddrfieldTextField.typeText("0:0:0::\r")
        XCTAssertEqual(subnetcalcWindow.staticTexts["ipv6addrtext"].value as! String, "::")
 
        //ipaddrfieldTextField.typeKey(.delete, modifierFlags:[])

        //subnetcalcWindow.buttons["Calc"].click()
        ipaddrfieldTextField.typeKey("q", modifierFlags:.command)
    }

}
