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
        
        subnetcalcWindow.tabs["Subnets"].click()
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
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "30")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.255.255.252")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "4")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "2")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "10.32.2.52/30")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "10.32.2.52 - 10.32.2.55")
        subnetcalcWindow.tabs["Address"].click()
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class A : 1.0.0.0 - 126.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "nnnnnnnn.ssssssss.ssssssss.sssssshh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "00001010.00100000.00000010.00110100")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "0A.20.02.34")
        
        subnetcalcWindow.tabs["Subnets"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.doubleClick()
        ipaddrfieldTextField.typeText("192.168.254.129/12\r")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetbitscombo"].value as! String, "0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maskbitscombo"].value as! String, "12")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "255.240.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxsubnetcombo"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxhostscombo"].value as! String, "1048574")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetrangetext"].value as! String, "192.160.0.1 - 192.175.255.254")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetidtext"].value as! String, "192.160.0.0")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetbroadcasttext"].value as! String, "192.175.255.255")
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "12")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.240.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "1048576")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "1048574")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "4096")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "192.160.0.0/12")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "192.160.0.0 - 192.175.255.255")
        subnetcalcWindow.tabs["Address"].click()
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class C : 192.0.0.0 - 223.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "nnnnnnnn.nnnnhhhh.hhhhhhhh.hhhhhhhh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "11000000.10101000.11111110.10000001")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "C0.A8.FE.81")
        
        subnetcalcWindow.tabs["Subnets"].click()
        ipaddrfieldTextField.click()
        ipaddrfieldTextField.doubleClick()
        ipaddrfieldTextField.typeText("172.16.242.132/8\r")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetbitscombo"].value as! String, "0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maskbitscombo"].value as! String, "8")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["subnetmaskcombo"].value as! String, "255.0.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxsubnetcombo"].value as! String, "1")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["maxhostscombo"].value as! String, "16777214")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetrangetext"].value as! String, "172.0.0.1 - 172.255.255.254")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetidtext"].value as! String, "172.0.0.0")
        XCTAssertEqual(subnetcalcWindow.staticTexts["subnetbroadcasttext"].value as! String, "172.255.255.255")
        subnetcalcWindow.tabs["CIDR"].click()
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaskbits"].value as! String, "8")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmask"].value as! String, "255.0.0.0")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsubnets"].value as! String, "16777216")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxaddr"].value as! String, "16777214")
        XCTAssertEqual(subnetcalcWindow.comboBoxes["cidrmaxsupernets"].value as! String, "256")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrnetwork"].value as! String, "172.0.0.0/8")
        XCTAssertEqual(subnetcalcWindow.staticTexts["cidrrange"].value as! String, "172.0.0.0 - 172.255.255.255")
        subnetcalcWindow.tabs["Address"].click()
        XCTAssertEqual(subnetcalcWindow.popUpButtons["addrclasstypecell"].value as! String, "Class B : 128.0.0.0 - 191.255.255.255")
        XCTAssertEqual(subnetcalcWindow.staticTexts["classbitmap"].value as! String, "nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh")
        XCTAssertEqual(subnetcalcWindow.staticTexts["binarymap"].value as! String, "10101100.00010000.11110010.10000100")
        XCTAssertEqual(subnetcalcWindow.staticTexts["hexamap"].value as! String, "AC.10.F2.84")
        
        subnetcalcWindow.menuButtons["exportbutton"].click()
        subnetcalcWindow.menuItems["exportClipboard:"].click()
        let pb: NSPasteboard = NSPasteboard.general
        let pbContent = pb.string(forType: NSPasteboard.PasteboardType.string)
        let validContent = "Address Class Type: B\nIP Address: 172.16.242.132\nSubnet ID: 172.0.0.0\nSubnet Mask: 255.0.0.0\nBroadcast: 172.255.255.255\nIP Range: 172.0.0.1 - 172.255.255.254\nMask Bits: 8\nSubnet Bits: 0\nMax Subnets: 1\nMax Hosts / Subnet: 16777214\nAddress Hexa: AC.10.F2.84\nBit Map: nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh\nBinary Map: 10101100.00010000.11110010.10000100\n"
        XCTAssertEqual(pbContent,validContent)
        
        /*
         NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
         NSString *pastecontent = [pasteboard stringForType: NSPasteboardTypeString];
         NSString *validcontent = @"Address Class Type: B\n\
     IP Address: 172.16.242.132\n\
     Subnet ID: 172.0.0.0\n\
     Subnet Mask: 255.0.0.0\n\
     Broadcast: 172.255.255.255\n\
     IP Range: 172.0.0.1 - 172.255.255.254\n\
     Mask Bits: 8\n\
     Subnet Bits: 0\n\
     Max Subnets: 1\n\
     Max Hosts / Subnet : 16777214\n\
     Address Hexa: AC.10.F2.84\n\
     BitMap: nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh\n\
     BinMap: 10101100.00010000.11110010.10000100\n";
         XCTAssertEqualObjects(pastecontent, validcontent);
         */
        
        //subnetcalcWindow.buttons["Calc"].click()
        ipaddrfieldTextField.typeKey("q", modifierFlags:.command)
    }

}
