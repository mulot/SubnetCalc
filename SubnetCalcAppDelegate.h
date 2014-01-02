//
//  SubnetCalcAppDelegate.h
//  SubnetCalc
//
//  Created by Julien Mulot on 04/01/11.
//  Copyright 2011 mulot.net. All rights reserved.
//

#import "IPSubnetCalc.h"
#import <Cocoa/Cocoa.h>

@interface SubnetCalcAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet NSTextField *addrField;
    IBOutlet NSTextField *classBinaryMap;
    IBOutlet NSTextField *classBitMap;
    IBOutlet NSTextField *classHexaMap;
    IBOutlet NSPopUpButton *classType;
    IBOutlet NSComboBox *maskBitsCombo;
    IBOutlet NSComboBox *maxHostsBySubnetCombo;
    IBOutlet NSComboBox *maxSubnetsCombo;
    IBOutlet NSComboBox *subnetBitsCombo;
    IBOutlet NSTextField *subnetBroadcast;
    IBOutlet NSTextField *subnetHostAddrRange;
    IBOutlet NSTextField *subnetId;
    IBOutlet NSComboBox *subnetMaskCombo;
    IBOutlet NSTableView *subnetsHostsView;
	IBOutlet NSComboBox *supernetMaskBitsCombo;
	IBOutlet NSComboBox *supernetMaskCombo;
	IBOutlet NSComboBox *supernetMaxCombo;
	IBOutlet NSComboBox *supernetMaxAddr;
	IBOutlet NSTextField *supernetRoute;
	IBOutlet NSTextField *supernetAddrRange;
	IBOutlet NSTabView *tabView;	
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

- (void)doIPSubnetCalc:(unsigned int)mask;
- (void)doSupernetCalc:(int)maskBits;
- (void)initClassInfos:(NSString *)c;
- (int)checkAddr:(NSString *)address;
- (IBAction)calc:(id)sender;
- (IBAction)ipAddrEdit:(id)sender;
- (IBAction)changeAddrClassType:(id)sender;
- (IBAction)changeMaskBits:(id)sender;
- (IBAction)changeMaxHosts:(id)sender;
- (IBAction)changeMaxSubnets:(id)sender;
- (IBAction)changeSubnetBits:(id)sender;
- (IBAction)changeSubnetMask:(id)sender;
- (IBAction)changeSupernetMaskBits:(id)sender;
- (IBAction)changeSupernetMask:(id)sender;
- (IBAction)changeSupernetMax:(id)sender;
- (IBAction)changeSupernetMaxAddr:(id)sender;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex;
- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex;

IPSubnetCalc	*ipsc;
NSArray			*tab_tabView;

@end
