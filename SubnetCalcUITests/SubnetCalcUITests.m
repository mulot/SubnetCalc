//
//  SubnetCalcUITests.m
//  SubnetCalcUITests
//
//  Created by Julien Mulot on 18/11/2020.
//

#import <XCTest/XCTest.h>

@interface SubnetCalcUITests : XCTestCase

@end

@implementation SubnetCalcUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIElement *subnetcalcWindow = [[XCUIApplication alloc] init].windows[@"SubnetCalc"];
        
    XCUIElement *iptextfieldcellTextField = subnetcalcWindow.textFields[@"ipaddrfield"];
    [iptextfieldcellTextField click];
    [iptextfieldcellTextField typeText:@"10.32.2.52/30\r"];
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"subnetbitscombo"] value], @"22");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maskbitscombo"] value], @"30");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"subnetmaskcombo"] value], @"255.255.255.252");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maxsubnetcombo"] value], @"4194304");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maxhostscombo"] value], @"2");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetrangetext"] value], @"10.32.2.53 - 10.32.2.54");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetidtext"] value], @"10.32.2.52");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetbroadcasttext"] value], @"10.32.2.55");
    [subnetcalcWindow.tabs[@"CIDR"] click];
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaskbits"] value], @"30");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmask"] value], @"255.255.255.252");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxsubnets"] value], @"4");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxaddr"] value], @"2");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxsupernets"] value], @"1");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrnetwork"] value], @"10.32.2.52/30");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrrange"] value], @"10.32.2.52 - 10.32.2.55");
    [subnetcalcWindow.tabs[@"Address"] click];
    XCTAssertEqualObjects([subnetcalcWindow.popUpButtons[@"addrclasstypecell"] value], @"Class A : 1.0.0.0 - 126.255.255.255");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"classbitmap"] value], @"nnnnnnnn.ssssssss.ssssssss.sssssshh");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"binarymap"] value], @"00001010.00100000.00000010.00110100");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"hexamap"] value], @"0A.20.02.34");
    
    [iptextfieldcellTextField click];
    [iptextfieldcellTextField doubleClick];
    [iptextfieldcellTextField typeText:@"192.168.254.129/12\r"];
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"subnetbitscombo"] value], @"0");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maskbitscombo"] value], @"12");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"subnetmaskcombo"] value], @"255.240.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maxsubnetcombo"] value], @"1");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maxhostscombo"] value], @"1048574");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetrangetext"] value], @"192.160.0.1 - 192.175.255.254");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetidtext"] value], @"192.160.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetbroadcasttext"] value], @"192.175.255.255");
    [subnetcalcWindow.tabs[@"CIDR"] click];
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaskbits"] value], @"12");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmask"] value], @"255.240.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxsubnets"] value], @"1048576");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxaddr"] value], @"1048574");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxsupernets"] value], @"4096");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrnetwork"] value], @"192.160.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrrange"] value], @"192.160.0.0 - 192.175.255.255");
    [subnetcalcWindow.tabs[@"Address"] click];
    XCTAssertEqualObjects([subnetcalcWindow.popUpButtons[@"addrclasstypecell"] value], @"Class C : 192.0.0.0 - 223.255.255.255");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"classbitmap"] value], @"nnnnnnnn.nnnnhhhh.hhhhhhhh.hhhhhhhh");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"binarymap"] value], @"11000000.10101000.11111110.10000001");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"hexamap"] value], @"C0.A8.FE.81");
    
    [iptextfieldcellTextField click];
    [iptextfieldcellTextField doubleClick];
    [iptextfieldcellTextField typeText:@"172.16.242.132/8\r"];
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"subnetbitscombo"] value], @"0");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maskbitscombo"] value], @"8");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"subnetmaskcombo"] value], @"255.0.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maxsubnetcombo"] value], @"1");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"maxhostscombo"] value], @"16777214");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetrangetext"] value], @"172.0.0.1 - 172.255.255.254");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetidtext"] value], @"172.0.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"subnetbroadcasttext"] value], @"172.255.255.255");
    [subnetcalcWindow.tabs[@"CIDR"] click];
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaskbits"] value], @"8");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmask"] value], @"255.0.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxsubnets"] value], @"16777216");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxaddr"] value], @"16777214");
    XCTAssertEqualObjects([subnetcalcWindow.comboBoxes[@"cidrmaxsupernets"] value], @"256");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrnetwork"] value], @"172.0.0.0");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrrange"] value], @"172.0.0.0 - 172.255.255.255");
    [subnetcalcWindow.tabs[@"Address"] click];
    XCTAssertEqualObjects([subnetcalcWindow.popUpButtons[@"addrclasstypecell"] value], @"Class B : 128.0.0.0 - 191.255.255.255");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"classbitmap"] value], @"nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"binarymap"] value], @"10101100.00010000.11110010.10000100");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"hexamap"] value], @"AC.10.F2.84");
    
    
    [[subnetcalcWindow childrenMatchingType:XCUIElementTypeMenuButton].element click];
    [subnetcalcWindow/*@START_MENU_TOKEN@*/.menuItems[@"exportClipboard:"]/*[[".menuButtons",".menus",".menuItems[@\"Export Clipboard\"]",".menuItems[@\"exportClipboard:\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/ click];
    
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

    //XCTAssert([subnetcalcWindow.popUpButtons[@"addrclasstypecell"] exists]);
    //[subnetcalcWindow/*@START_MENU_TOKEN@*/.tabs[@"Subnets"]/*[[".tabGroups.tabs[@\"Subnets\"]",".tabs[@\"Subnets\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ click];
    [iptextfieldcellTextField typeKey:@"q" modifierFlags:XCUIKeyModifierCommand];
}

- (void)testLaunchPerformance {
    if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)) {
        // This measures how long it takes to launch your application.
        [self measureWithMetrics:@[[[XCTApplicationLaunchMetric alloc] init]] block:^{
            [[[XCUIApplication alloc] init] launch];
        }];
    }
}

@end
