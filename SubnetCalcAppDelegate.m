//
//  SubnetCalcAppDelegate.m
//  SubnetCalc
//
//  Created by Julien Mulot on 04/01/11.
//  Copyright 2011 mulot.net. All rights reserved.
//

#import "SubnetCalcAppDelegate.h"
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation SubnetCalcAppDelegate

@synthesize window;

- (int)checkAddr:(NSString *)address
{
	NSRange			range;
	
	range = [address rangeOfString:@"/"];
	if (range.location != NSNotFound)
	{
		if (([[address substringFromIndex: range.location + 1] intValue] > 32) 
			|| ([[address substringFromIndex: range.location + 1] intValue] < 8))
			return (-1);
		if ([IPSubnetCalc numberize: [[address substringToIndex: range.location] cStringUsingEncoding: NSASCIIStringEncoding]] == -1)
			return (-1);
		[tabView selectTabViewItemAtIndex: 1];
	}
	else if ([IPSubnetCalc numberize: [address cStringUsingEncoding: NSASCIIStringEncoding]] == -1)
		return (-1);
	return (0);
}

- (void)initClassInfos:(NSString *)c
{
	unsigned int	tmp_mask;
	unsigned int	addr_nl;
	int				i;
	int				j = 0;
	
	if ([c isEqualToString: @"A"])
	{
		j = 1;
        [classType selectItemAtIndex: 0];
	}
    else if ([c isEqualToString: @"B"])
	{
		j = 2;
        [classType selectItemAtIndex: 1];
	}
    else if ([c isEqualToString: @"C"])
	{
		j = 3;
        [classType selectItemAtIndex: 2];
	}
	else if ([c isEqualToString: @"D"])
	{
        [classType selectItemAtIndex: 3];
		tab_tabView = [tabView tabViewItems];
		[tab_tabView retain];
		[tabView removeTabViewItem: [tab_tabView objectAtIndex: 1]];
		[tabView removeTabViewItem: [tab_tabView objectAtIndex: 2]];
		[tabView removeTabViewItem: [tab_tabView objectAtIndex: 3]];
	}
	if (j)
	{
		for (i = j; i <= 8 * j; i++)
			[supernetMaskBitsCombo addItemWithObjectValue: [NSString stringWithFormat: @"%d", i]];
		tmp_mask = -1;
		for (i = 32 - j; i >= (32 - 8 * j); i--)
		{
			addr_nl = htonl(tmp_mask << i);
			[supernetMaskCombo addItemWithObjectValue: [IPSubnetCalc denumberize: addr_nl]];
		}
		for (i = 0; i < 8 * j - j + 1; i++)
		{   
			tmp_mask = pow(2, i);
			[supernetMaxCombo addItemWithObjectValue: [NSString stringWithFormat: @"%u", tmp_mask]];
		}
		for (i = (32 - 8 * j); i < 32 - j + 1; i++)
		{   
			tmp_mask = pow(2, i) - 2;
			[supernetMaxAddr addItemWithObjectValue: [NSString stringWithFormat: @"%u", tmp_mask]];
		}
		[supernetMaxCombo selectItemAtIndex: 8 * (j - 1)];
		[supernetMaxAddr selectItemAtIndex: 8 * (j - 1)];
		[supernetMaskBitsCombo selectItemAtIndex: 8 - j];
		[supernetMaskCombo selectItemAtIndex: 8 - j];
	}
}

- (void)doIPSubnetCalc:(unsigned int)mask
{
	NSRange						range;
	NSMutableAttributedString   *astr;
	
	if ([self checkAddr: [addrField stringValue]])
		return;
	if ([tabView numberOfTabViewItems] != 4)
	{
		[tabView addTabViewItem: [tab_tabView objectAtIndex:1]];
		[tabView addTabViewItem: [tab_tabView objectAtIndex:2]];
		[tabView addTabViewItem: [tab_tabView objectAtIndex:3]];
		[tab_tabView release];
	}
	[supernetMaskBitsCombo removeAllItems];
	[supernetMaskCombo removeAllItems];
	[supernetMaxAddr removeAllItems];
	[supernetMaxCombo removeAllItems];
	if (ipsc)
		[ipsc release];	
    ipsc = [[IPSubnetCalc alloc] init];
	range = [[addrField stringValue] rangeOfString:@"/"];
	if (range.location != NSNotFound)
	{
		mask = -1;
		mask <<= (32 - [[[addrField stringValue] substringFromIndex: range.location + 1] intValue]);
		[addrField setStringValue: [[addrField stringValue] substringToIndex: range.location]];
	}
	if (mask)
		[ipsc initAddressAndMask: [[addrField stringValue] cStringUsingEncoding: NSASCIIStringEncoding]: mask];
	else
		[ipsc initAddress: [[addrField stringValue] cStringUsingEncoding: NSASCIIStringEncoding]];
	[self initClassInfos: [ipsc networkClass]];
   	[supernetRoute setStringValue: [ipsc supernetRoute: [[supernetMaskBitsCombo objectValueOfSelectedItem] intValue]]];
	[supernetAddrRange setStringValue: [ipsc supernetAddrRange: [[supernetMaskBitsCombo objectValueOfSelectedItem] intValue]]];
	astr = [[NSMutableAttributedString alloc] initWithString : [ipsc bitMap]];
	/*
	 if ([[ipsc maskBits] intValue] >= 24)
	 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 27)];
	 else if ([[ipsc maskBits] intValue] >= 16)
	 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 18)];
	 else
	 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 9)];
	 */
	[classBitMap setAttributedStringValue: astr];
	[astr release];
    [classBinaryMap setStringValue: [ipsc binMap]];
    [classHexaMap setStringValue: [ipsc hexMap]];
    [subnetBitsCombo selectItemWithObjectValue: [[ipsc subnetBits] stringValue]];
    [maskBitsCombo selectItemWithObjectValue: [[ipsc maskBits] stringValue]];
    [maxSubnetsCombo selectItemWithObjectValue: [[ipsc subnetMax] stringValue]];
    [maxHostsBySubnetCombo selectItemWithObjectValue: [[ipsc hostMax] stringValue]];
    [subnetMaskCombo selectItemWithObjectValue: [ipsc subnetMask]];
    [subnetId setStringValue: [ipsc subnetId]];
	[subnetHostAddrRange setStringValue: [ipsc subnetHostAddrRange]];
    [subnetBroadcast setStringValue: [ipsc subnetBroadcast]];
}


- (IBAction)calc:(id)sender
{
	[self doIPSubnetCalc:0];
}

- (IBAction)ipAddrEdit:(id)sender
{
	[self calc:nil];
}

- (IBAction)changeAddrClassType:(id)sender
{
	NSMutableAttributedString   *astr;
	
	if ([tabView numberOfTabViewItems] != 4)
	{
		[tabView addTabViewItem: [tab_tabView objectAtIndex:1]];
		[tabView addTabViewItem: [tab_tabView objectAtIndex:2]];
		[tabView addTabViewItem: [tab_tabView objectAtIndex:3]];
		[tab_tabView release];
	}
    if ([sender indexOfSelectedItem] == 0)
    {
		astr = [[NSMutableAttributedString alloc] initWithString : @"nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh"];
		/*
		 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 9)];
		 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(9, 26)];
		 */
		[classBitMap setAttributedStringValue: astr];
		[astr release];
        [classBinaryMap setStringValue: @"00000001000000000000000000000000"];
    }
    else if ([sender indexOfSelectedItem] == 1)
    {
		astr = [[NSMutableAttributedString alloc] initWithString : @"nnnnnnnn.nnnnnnnn.hhhhhhhh.hhhhhhhh"];
		/*
		 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 18)];
		 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(18, 17)];
		 */
		[classBitMap setAttributedStringValue: astr];
		[astr release];
        [classBinaryMap setStringValue: @"10000000000000000000000000000000"];
    }
    else if ([sender indexOfSelectedItem] == 2)
    {
		astr = [[NSMutableAttributedString alloc] initWithString : @"nnnnnnnn.nnnnnnnn.nnnnnnnn.hhhhhhhh"];
		/*
		 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 27)];
		 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(27, 8)];
		 */
		[classBitMap setAttributedStringValue: astr];
		[astr release];
        [classBinaryMap setStringValue: @"11000000000000000000000000000000"];
    }
	else if ([sender indexOfSelectedItem] == 3)
	{
		tab_tabView = [tabView tabViewItems];
		[tab_tabView retain];
		[tabView removeTabViewItem: [tab_tabView objectAtIndex: 1]];
		[tabView removeTabViewItem: [tab_tabView objectAtIndex: 2]];
		[tabView removeTabViewItem: [tab_tabView objectAtIndex: 3]];
	}
}

- (IBAction)changeMaxHosts:(id)sender
{
    unsigned int	mask = -1;
    
    [self doIPSubnetCalc:(mask << (2 + [sender indexOfSelectedItem]))];
}

- (IBAction)changeMaxSubnets:(id)sender
{
	unsigned int	mask = -1;
    
	[self doIPSubnetCalc: (mask << (32 - ([sender indexOfSelectedItem] + [ipsc netBits])))];
}

- (IBAction)changeSubnetBits:(id)sender
{
	unsigned int	mask = -1;
	
	[self doIPSubnetCalc: (mask << (32 - ([[sender objectValueOfSelectedItem] intValue] + [ipsc netBits])))];
}

- (IBAction)changeSubnetMask:(id)sender
{
    unsigned int	sin_addr;
    
    if ((inet_pton(AF_INET, [[sender objectValueOfSelectedItem] cStringUsingEncoding: NSASCIIStringEncoding], &sin_addr)) <= 0)
        exit(-1);
    [self doIPSubnetCalc: ntohl(sin_addr)];
}

- (IBAction)changeMaskBits:(id)sender
{
	unsigned int	mask = -1;
    
	[self doIPSubnetCalc:(mask << (32 - [[sender objectValueOfSelectedItem] intValue]))];
}

- (void)doSupernetCalc:(int)maskBits
{
	unsigned int	mask = -1;
	unsigned int	result = 0;
	
	[supernetMaskBitsCombo selectItemWithObjectValue: [NSString stringWithFormat: @"%d", maskBits]];
	[supernetMaskCombo selectItemWithObjectValue: [IPSubnetCalc denumberize: (mask << (32 - maskBits))]];
	if ([[ipsc networkClass] isEqualToString: @"A"])
		result = pow(2, 8 - maskBits);
	else if ([[ipsc networkClass] isEqualToString: @"B"])
		result = pow(2, 16 - maskBits);
	else if ([[ipsc networkClass] isEqualToString: @"C"])
		result = pow(2, 24 - maskBits);
	[supernetMaxCombo selectItemWithObjectValue: [NSString stringWithFormat: @"%u", result]];
	result = pow(2, 32 - maskBits) - 2;
	[supernetMaxAddr selectItemWithObjectValue: [NSString stringWithFormat: @"%u", result]];
	[supernetRoute setStringValue: [ipsc supernetRoute: maskBits]];
	[supernetAddrRange setStringValue: [ipsc supernetAddrRange: maskBits]];
}

- (IBAction)changeSupernetMaskBits:(id)sender
{
	[self doSupernetCalc: [[sender objectValueOfSelectedItem] intValue]];
}

- (IBAction)changeSupernetMask:(id)sender
{
	unsigned int	mask;
	
	mask = [IPSubnetCalc numberize: [[sender objectValueOfSelectedItem] cStringUsingEncoding: NSASCIIStringEncoding]];
	[self doSupernetCalc: [IPSubnetCalc countOnBits: mask]];
}

- (IBAction)changeSupernetMax:(id)sender
{
	if ([[ipsc networkClass] isEqualToString: @"A"])
		[self doSupernetCalc: 8 - [sender indexOfSelectedItem]];
	else if ([[ipsc networkClass] isEqualToString: @"B"])
		[self doSupernetCalc: 16 - [sender indexOfSelectedItem]];
	else if ([[ipsc networkClass] isEqualToString: @"C"])
		[self doSupernetCalc: 24 - [sender indexOfSelectedItem]];
}

- (IBAction)changeSupernetMaxAddr:(id)sender
{
	[self changeSupernetMax: sender];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return ([[ipsc subnetMax] intValue]);
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	IPSubnetCalc	*ipsc_tmp;
	unsigned int	mask;
	
	mask = rowIndex;
	mask <<= (32 - [ipsc maskBitsIntValue]);
    ipsc_tmp = [[IPSubnetCalc alloc] init];
	[ipsc_tmp initAddressAndMaskWithUnsignedInt:([ipsc netIdIntValue] | mask): [ipsc subnetMaskIntValue]];
	[ipsc_tmp autorelease];
	if ([[aTableColumn identifier] isEqualToString: @"numCol"])
		return ([NSNumber numberWithInt: rowIndex + 1]);
	if ([[aTableColumn identifier] isEqualToString: @"rangeCol"])
		return ([[ipsc_tmp subnetHostAddrRange] retain]);
	if ([[aTableColumn identifier] isEqualToString: @"subnetCol"])
		return ([ipsc_tmp subnetId]);
	if ([[aTableColumn identifier] isEqualToString: @"broadcastCol"])
		return ([ipsc_tmp subnetBroadcast]);
	return (nil);
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
}

- (void)windowWillClose:(NSNotification *)notif
{
	[NSApp terminate: self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	int							i;
    unsigned int				mask = -1;
    unsigned int				addr_nl;
	NSMutableAttributedString   *astr;
	
    for (i = 24; i > 1; i--)
    {
        addr_nl = (mask << i);
        [subnetMaskCombo addItemWithObjectValue: [IPSubnetCalc denumberize: addr_nl]];
    }
    for (i = 8; i < 31; i++)
        [maskBitsCombo addItemWithObjectValue: [NSString stringWithFormat: @"%d", i]];
    for (i = 0; i < 23; i++)
        [subnetBitsCombo addItemWithObjectValue: [NSString stringWithFormat: @"%d", i]];
    for (i = 2; i < 25; i++)
    {
        mask = (pow(2, i) - 2);
        [maxHostsBySubnetCombo addItemWithObjectValue: [NSString stringWithFormat: @"%u", mask]];
    }
    for (i = 0; i < 23; i++)
    {
        mask = (pow(2, i));
        [maxSubnetsCombo addItemWithObjectValue: [NSString stringWithFormat: @"%u", mask]];
    }
	astr = [[NSMutableAttributedString alloc] initWithString : @"nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh"];
	/*
	 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 9)];
	 [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(9, 26)];
	 */
	[classBitMap setAttributedStringValue: astr];
	[astr release];
    [subnetMaskCombo selectItemWithObjectValue: @"255.0.0.0"];
    [maskBitsCombo selectItemWithObjectValue: @"8"];
    [subnetBitsCombo selectItemWithObjectValue: @"0"];	
}

@end
