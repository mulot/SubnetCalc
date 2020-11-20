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

#define BUFFER_LINES        1000
#define NETWORK_BITS_MIN_CLASSLESS    1
#define NETWORK_BITS_MIN    8
#define NETWORK_BITS_MAX    32

@implementation SubnetCalcAppDelegate

@synthesize window;

- (int)checkAddr:(NSString *)address
{
    NSRange			range;
    
    if (address)
    {
        range = [address rangeOfString:@"/"];
        if (range.location != NSNotFound)
        {
            if (([[address substringFromIndex: range.location + 1] intValue] > NETWORK_BITS_MAX)
                || ([[address substringFromIndex: range.location + 1] intValue] < NETWORK_BITS_MIN))
                return (-1);
            if ([IPSubnetCalc numberize: [[address substringToIndex: range.location] cStringUsingEncoding: NSASCIIStringEncoding]] == -1)
                return (-1);
            [tabView selectTabViewItemAtIndex: 1];
        }
        else if ([IPSubnetCalc numberize: [address cStringUsingEncoding: NSASCIIStringEncoding]] == -1)
            return (-1);
    }
    else
    {
        return (-2);
    }
    return (0);
}

- (void)initClassInfos:(NSString *)c
{
    if ([c isEqualToString: @"A"])
    {
        [classType selectItemAtIndex: 0];
    }
    else if ([c isEqualToString: @"B"])
    {
        [classType selectItemAtIndex: 1];
    }
    else if ([c isEqualToString: @"C"])
    {
        [classType selectItemAtIndex: 2];
    }
    else if ([c isEqualToString: @"D"])
    {
        [classType selectItemAtIndex: 3];
        tab_tabView = [tabView tabViewItems];
        [tabView removeTabViewItem: [tab_tabView objectAtIndex: 1]];
        [tabView removeTabViewItem: [tab_tabView objectAtIndex: 2]];
        [tabView removeTabViewItem: [tab_tabView objectAtIndex: 3]];
    }
}

- (void)initCIDR
{
    unsigned int    tmp_mask;
    unsigned int    addr_nl;
    int             i;
    
    for (i = 1; i <= 30; i++)
        [supernetMaskBitsCombo addItemWithObjectValue: [NSString stringWithFormat: @"%d", i]];
    tmp_mask = -1;
    for (i = 31; i > 1; i--)
    {
        //addr_nl = htonl(tmp_mask << i);
        addr_nl = (tmp_mask << i);
        [supernetMaskCombo addItemWithObjectValue: [IPSubnetCalc denumberize: addr_nl]];
    }
    for (i = 0; i < 30; i++)
    {
        tmp_mask = pow(2, i);
        [supernetMaxCombo addItemWithObjectValue: [NSString stringWithFormat: @"%u", tmp_mask]];
    }
    for (i = 1; i < 32; i++)
    {
        tmp_mask = pow(2, i) - 2;
        [supernetMaxAddr addItemWithObjectValue: [NSString stringWithFormat: @"%u", tmp_mask]];
    }
    for (i = 0; i < 32; i++)
    {
        tmp_mask = (pow(2, i));
        [supernetMaxSubnetsCombo addItemWithObjectValue: [NSString stringWithFormat: @"%u", tmp_mask]];
    }
    /*
     [supernetMaxCombo selectItemAtIndex: 7];
     [supernetMaxAddr selectItemAtIndex: 23];
     [supernetMaskBitsCombo selectItemAtIndex: 7];
     [supernetMaskCombo selectItemAtIndex: 7];
     [supernetMaxSubnetsCombo selectItemAtIndex: 24];
     */
}

- (void)doIPSubnetCalc:(unsigned int)mask
{
    NSRange						range;
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
    /*
     [supernetMaskBitsCombo removeAllItems];
     [supernetMaskCombo removeAllItems];
     [supernetMaxAddr removeAllItems];
     [supernetMaxCombo removeAllItems];
     [supernetMaxSubnetsCombo removeAllItems];
     */
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
        /*
         if ([[ipsc maskBits] intValue] >= 24)
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 27)];
         else if ([[ipsc maskBits] intValue] >= 16)
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 18)];
         else
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 9)];
         */
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
}


- (IBAction)calc:(id)sender
{
    if (ipsc)
    {
        [self doIPSubnetCalc:[ipsc subnetMaskIntValue]];
    }
    else
    {
        [self doIPSubnetCalc:0];
    }
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
    }
    if ([sender indexOfSelectedItem] == 0)
    {
        astr = [[NSMutableAttributedString alloc] initWithString : NSLocalizedString(@"nnnnnnnn.hhhhhhhh.hhhhhhhh.hhhhhhhh", nil)];
        /*
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 9)];
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(9, 26)];
         */
        [classBitMap setAttributedStringValue: astr];
        [classBinaryMap setStringValue: NSLocalizedString(@"00000001000000000000000000000000", nil)];
    }
    else if ([sender indexOfSelectedItem] == 1)
    {
        astr = [[NSMutableAttributedString alloc] initWithString : NSLocalizedString(@"nnnnnnnn.nnnnnnnn.hhhhhhhh.hhhhhhhh", nil)];
        /*
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 18)];
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(18, 17)];
         */
        [classBitMap setAttributedStringValue: astr];
        [classBinaryMap setStringValue: NSLocalizedString(@"10000000000000000000000000000000", nil)];
    }
    else if ([sender indexOfSelectedItem] == 2)
    {
        astr = [[NSMutableAttributedString alloc] initWithString : NSLocalizedString(@"nnnnnnnn.nnnnnnnn.nnnnnnnn.hhhhhhhh", nil)];
        /*
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 27)];
         [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(27, 8)];
         */
        [classBitMap setAttributedStringValue: astr];
        [classBinaryMap setStringValue: NSLocalizedString(@"11000000000000000000000000000000", nil)];
    }
    else if ([sender indexOfSelectedItem] == 3)
    {
        tab_tabView = [tabView tabViewItems];
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
    
    if (ipsc)
        [self doIPSubnetCalc: (mask << (32 - ([sender indexOfSelectedItem] + [ipsc netBits])))];
    else
        [self doIPSubnetCalc: (mask << (32 - ([sender indexOfSelectedItem] + 8)))];
}

- (IBAction)changeSubnetBits:(id)sender
{
    unsigned int	mask = -1;
    
    if (ipsc)
        [self doIPSubnetCalc: (mask << (32 - ([[sender objectValueOfSelectedItem] intValue] + [ipsc netBits])))];
    else
        [self doIPSubnetCalc: (mask << (32 - ([[sender objectValueOfSelectedItem] intValue] + 8)))];
}

- (IBAction)changeSubnetMask:(id)sender
{
    unsigned int	sin_addr;
    
    if ((inet_pton(AF_INET, [[sender objectValueOfSelectedItem] cStringUsingEncoding: NSASCIIStringEncoding]?:"0", &sin_addr )) <= 0)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle: @"OK"];
        [alert setMessageText: @"Bad Subnet Mask"];
        [alert setAlertStyle: NSAlertStyleWarning];
        [alert setInformativeText:@"Bad format"];
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            if (ipsc)
            {
                if ([wildcard state] == NSOnState)
                {
                    [subnetMaskCombo selectItemWithObjectValue: [IPSubnetCalc denumberize: ~([ipsc subnetMaskIntValue])]];
                }
                else
                {
                    [subnetMaskCombo selectItemWithObjectValue: [ipsc subnetMask]];
                }
            }
        }
    }
    else {
        if ([wildcard state] == NSOnState)
        {
            sin_addr = ~sin_addr;
            [self doIPSubnetCalc: ntohl(sin_addr)];
        }
        else
        {
            [self doIPSubnetCalc: ntohl(sin_addr)];
        }
    }
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
    
    if (maskBits >=0 && maskBits <= 32 && ipsc)
    {
        [supernetMaskBitsCombo selectItemWithObjectValue: [NSString stringWithFormat: @"%d", maskBits]];
        //[supernetMaskCombo selectItemWithObjectValue: [IPSubnetCalc denumberize: (mask << ((8 - maskBits)) & 0x000000FF)]];
        [supernetMaskCombo selectItemWithObjectValue: [IPSubnetCalc denumberize: (mask << (32 - maskBits))]];
        if ([[ipsc networkClass] isEqualToString: @"A"])
            result = pow(2, 8 - maskBits);
        else if ([[ipsc networkClass] isEqualToString: @"B"])
            result = pow(2, 16 - maskBits);
        else if ([[ipsc networkClass] isEqualToString: @"C"])
            result = pow(2, 24 - maskBits);
        if (result > 0)
            [supernetMaxCombo selectItemWithObjectValue: [NSString stringWithFormat: @"%u", result]];
        else
            [supernetMaxCombo selectItemWithObjectValue: @"1"];
        result = pow(2, 32 - maskBits) - 2;
        [supernetMaxAddr selectItemWithObjectValue: [NSString stringWithFormat: @"%u", result]];
        [supernetRoute setStringValue: [ipsc supernetRoute: maskBits]];
        [supernetAddrRange setStringValue: [ipsc supernetAddrRange: maskBits]];
        result = pow(2, 32 - maskBits);
        [supernetMaxSubnetsCombo selectItemWithObjectValue: [NSString stringWithFormat: @"%u", result]];
    }
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
    if (ipsc)
    {
        if ([[ipsc networkClass] isEqualToString: @"A"])
            [self doSupernetCalc: 8 - (int)[sender indexOfSelectedItem]];
        else if ([[ipsc networkClass] isEqualToString: @"B"])
            [self doSupernetCalc: 16 - (int)[sender indexOfSelectedItem]];
        else if ([[ipsc networkClass] isEqualToString: @"C"])
            [self doSupernetCalc: 24 - (int)[sender indexOfSelectedItem]];
    }
}

- (IBAction)changeSupernetMaxAddr:(id)sender
{
    [self changeSupernetMax: sender];
}

- (IBAction)changeSupernetMaxSubnets:(id)sender
{
    [self doSupernetCalc: (32 - (int)[sender indexOfSelectedItem])];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (ipsc)
    {
        if ([ipsc classless] == YES)
            return (pow(2, ([[ipsc maskBits] intValue] - NETWORK_BITS_MIN_CLASSLESS)));
        else
            return ([[ipsc subnetMax] intValue]);
    }
    return 0;
}

//Display all subnets info in the TableView Subnet/Hosts
- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex
{
    IPSubnetCalc	*ipsc_tmp;
    unsigned int	mask;
    
    ipsc_tmp = [[IPSubnetCalc alloc] init];
    if (ipsc_tmp && ipsc)
    {
        mask = rowIndex;
        mask <<= (32 - [ipsc maskBitsIntValue]);
        [ipsc_tmp initAddressAndMaskWithUnsignedInt:([ipsc netIdIntValue] | mask) mask: [ipsc subnetMaskIntValue]];
        if ([[aTableColumn identifier] isEqualToString: @"numCol"])
            return ([NSNumber numberWithInt: rowIndex + 1]);
        else if ([[aTableColumn identifier] isEqualToString: @"rangeCol"])
            return ([ipsc_tmp subnetHostAddrRange]);
        else if ([[aTableColumn identifier] isEqualToString: @"subnetCol"])
            return ([ipsc_tmp subnetId]);
        else if ([[aTableColumn identifier] isEqualToString: @"broadcastCol"])
            return ([ipsc_tmp subnetBroadcast]);
    }
    return (nil);
}

- (void)printAllSubnets
{
    IPSubnetCalc    *ipsc_tmp;
    unsigned int    mask;
    unsigned int    i;
    
    if (ipsc)
    {
        for (i = 0; i < [[ipsc subnetMax] unsignedIntValue]; i++)
        {
            mask = i;
            mask <<= (32 - [ipsc maskBitsIntValue]);
            ipsc_tmp = [[IPSubnetCalc alloc] init];
            [ipsc_tmp initAddressAndMaskWithUnsignedInt:([ipsc netIdIntValue] | mask) mask: [ipsc subnetMaskIntValue]];
            NSLog(@"# : %d", i + 1);
            NSLog(@"Subnet ID : %@", [ipsc_tmp subnetId]);
            NSLog(@"IP Range : %@", [ipsc_tmp subnetHostAddrRange]);
            NSLog(@"Broadcast : %@", [ipsc_tmp subnetBroadcast]);
        }
    }
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(int)rowIndex
{
}

- (void)bitsOnSlidePos
{
    NSRect			coordLabel, coordSlider;
    
    coordLabel = [bitsOnSlide frame];
    coordSlider = [subnetBitsSlide frame];
    coordLabel.origin.x = coordSlider.origin.x - (coordLabel.size.width / 2) + ([subnetBitsSlide knobThickness] / 2) + (((coordSlider.size.width - ([subnetBitsSlide knobThickness] / 2)) / [subnetBitsSlide numberOfTickMarks]) * ([subnetBitsSlide floatValue] - 1.0));
    //NSLog(@"slide x : %f label width : %f slide knob : %f slide width : %f n tick marks : %d slide value : %f x coord %f", coordSlider.origin.x, coordLabel.size.width, [subnetBitsSlide knobThickness], coordSlider.size.width, (int)[subnetBitsSlide numberOfTickMarks], [subnetBitsSlide floatValue], coordLabel.origin.x);
    [bitsOnSlide setFrame: coordLabel];
    
}

- (IBAction)subnetBitsSlide:(id)sender
{
    unsigned int	mask = -1;
    
    [self doIPSubnetCalc:(mask << (32 - [sender intValue]))];
    [subnetsHostsView reloadData];
}

- (IBAction)changeTableViewClass:(id)sender
{
    if ([tabViewClassLess state] == NSOnState)
    {
        if (ipsc)
            [ipsc setClassless: YES];
    }
    else
    {
        if (ipsc)
            [ipsc setClassless: NO];
    }
    [subnetsHostsView reloadData];
}

- (IBAction)changeWildcard:(id)sender
{
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
}


- (IBAction)exportCSV:(id)sender
{
    NSSavePanel	*panel;
    
    if (ipsc)
    {
        panel = [NSSavePanel savePanel];
        [panel setAllowedFileTypes:[NSArray arrayWithObject: @"csv"]];
        [panel beginWithCompletionHandler: ^(NSModalResponse result){
            if (result == NSFileHandlingPanelOKButton)
            {
                NSString				*str_csv;
                unsigned int			i;
                unsigned                mask;
                NSMutableData           *data_cvs;
                NSFileHandle			*file_cvs;
                NSFileManager			*file_mgt;
                IPSubnetCalc            *ipsc_tmp;
                unsigned int            netId;
                unsigned int            subnetMask;
                unsigned int            maskBits;
                unsigned int            subnetMax;
                
                if ((file_mgt = [[NSFileManager alloc] init]))
                {
                    [file_mgt createFileAtPath:[[panel URL] path] contents:nil attributes:nil];
                }
                data_cvs = [NSMutableData dataWithCapacity: 200000000];
                file_cvs = [NSFileHandle fileHandleForWritingAtPath: [[panel URL] path]];
                if (file_cvs && data_cvs)
                {
                    netId = [ipsc netIdIntValue];
                    subnetMask = [ipsc subnetMaskIntValue];
                    maskBits = [ipsc maskBitsIntValue];
                    subnetMax = [[ipsc subnetMax] unsignedIntValue];
                    //[self printAllSubnets];
                    str_csv = @"#;Subnet ID;Range;Broadcast\n";
                    [data_cvs appendData: [str_csv dataUsingEncoding: NSASCIIStringEncoding]];
                    @autoreleasepool {
                        for (i = 0; i < subnetMax; i++)
                        {
                            mask = i;
                            mask <<= (32 - maskBits);
                            if ((ipsc_tmp = [[IPSubnetCalc alloc] init]))
                            {
                                [ipsc_tmp initAddressAndMaskWithUnsignedInt: (netId | mask) mask: subnetMask];
                                if ((str_csv = [[NSString alloc] initWithFormat:@"%d;%@;%@;%@\n", i + 1, [ipsc_tmp subnetId], [ipsc_tmp subnetHostAddrRange], [ipsc_tmp subnetBroadcast]]))
                                {
                                    [data_cvs appendData: [str_csv dataUsingEncoding: NSASCIIStringEncoding]];
                                }
                            }
                        }
                        [file_cvs writeData: data_cvs];
                        [file_cvs synchronizeFile];
                        [file_cvs closeFile];
                    }
                }
            }
        }];
    }
}

- (IBAction)exportClipboard:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSString    *str;
    
    [pb clearContents];
    str = [[NSString alloc] init];
    if (ipsc)
    {
        str = [str stringByAppendingFormat: @"Address Class Type: %@\nIP Address: %@\nSubnet ID: %@\nSubnet Mask: %@\nBroadcast: %@\nIP Range: %@\nMask Bits: %@\nSubnet Bits: %@\nMax Subnets: %@\nMax Hosts / Subnet : %@\nAddress Hexa: %@\nBitMap: %@\nBinMap: %@\n", [ipsc networkClass], [IPSubnetCalc denumberize:[ipsc hostAddrIntValue]], [ipsc subnetId], [ipsc subnetMask], [ipsc subnetBroadcast], [ipsc subnetHostAddrRange], [[ipsc maskBits] stringValue], [[ipsc subnetBits] stringValue], [[ipsc subnetMax] stringValue], [[ipsc hostMax] stringValue], [ipsc hexMap], [ipsc bitMap], [ipsc binMap]];
        [pb setString: str forType:NSStringPboardType];
    }
}

- (IBAction)darkMode:(id)sender
{
    if (@available(macOS 10.14, *)) {
        if ([darkModeMenu state] == NSControlStateValueOff)
        {
            NSApp.appearance = [NSAppearance appearanceNamed: NSAppearanceNameDarkAqua];
            [darkModeMenu setState: NSControlStateValueOn];
        }
        else if ([darkModeMenu state] == NSControlStateValueOn)
        {
            NSApp.appearance = nil;
            [darkModeMenu setState: NSControlStateValueOff];
        }
    }
}

-(NSString *)URLEncode:(NSString *)url
{
    NSString	*url_encoded;
    
    if (url)
    {
        url_encoded = [[NSString alloc] initWithString: url];
        url_encoded = [url_encoded stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
        url_encoded = [url_encoded stringByReplacingOccurrencesOfString: @"\n" withString: @"%0D"];
        url_encoded = [url_encoded stringByReplacingOccurrencesOfString: @"/" withString: @"%2F"];
    }
    return (url_encoded);
}

- (void)windowDidResize:(NSNotification *)notification
{
    [self bitsOnSlidePos];
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
        if ([wildcard state] == NSOnState)
        {
            [subnetMaskCombo addItemWithObjectValue: [IPSubnetCalc denumberize: ~addr_nl]];
        }
        else
        {
            [subnetMaskCombo addItemWithObjectValue: [IPSubnetCalc denumberize: addr_nl]];
        }
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
    [subnetMaskCombo selectItemWithObjectValue: @"255.0.0.0"];
    [maskBitsCombo selectItemWithObjectValue: @"8"];
    [subnetBitsCombo selectItemWithObjectValue: @"0"];
    //NSApp.appearance = [NSAppearance appearanceNamed: NSAppearanceNameAqua];
    [self initCIDR];
}

@end
