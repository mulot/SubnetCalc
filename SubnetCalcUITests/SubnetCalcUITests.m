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
    self.continueAfterFailure = YES;

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
    
    XCUIElement *subnetcalcWindow = [[XCUIApplication alloc] init].windows[@"SubnetCalc"];
    
    XCUIElement *iptextfieldcellTextField = subnetcalcWindow.textFields[@"ipaddrfield"];
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
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrnetwork"] value], @"10.32.2.52");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"cidrrange"] value], @"10.32.2.52 - 10.32.2.55");
    [subnetcalcWindow.tabs[@"Address"] click];
    XCTAssertEqualObjects([subnetcalcWindow.popUpButtons[@"addrclasstypecell"] value], @"Class A : 1.0.0.0 - 126.255.255.255");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"classbitmap"] value], @"nnnnnnnn.ssssssss.ssssssss.sssssshh");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"binarymap"] value], @"00001010.00100000.00000010.00110100");
    XCTAssertEqualObjects([subnetcalcWindow.staticTexts[@"hexamap"] value], @"0A.20.02.34");
    

    //XCTAssert([subnetcalcWindow.popUpButtons[@"addrclasstypecell"] exists]);
    //[subnetcalcWindow/*@START_MENU_TOKEN@*/.tabs[@"Subnets"]/*[[".tabGroups.tabs[@\"Subnets\"]",".tabs[@\"Subnets\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ click];
    [iptextfieldcellTextField typeKey:@"q" modifierFlags:XCUIKeyModifierCommand];
    
    
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
