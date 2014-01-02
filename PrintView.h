//
//  PrintView.h
//  SubnetCalc
//
//  Created by Julien Mulot on 02/02/11.
//  Copyright 2011 mulot.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrintView : NSView {
	NSTableView	*subnetsTable;
	int			entryPerPage; // how many entry per pages
	int			pages; //how many pages
	float		rectHeight; //how much vertical space
}

-initWithSubnet:(NSTableView *)table printInfo:(NSPrintInfo *)pi;
- (NSRect)rectForSubnet:(int)index;
@end
