//
//  PrintView.m
//  SubnetCalc
//
//  Created by Julien Mulot on 02/02/11.
//  Copyright 2011 mulot.net. All rights reserved.
//

#import "PrintView.h"


@implementation PrintView

-initWithSubnet:(NSTableView *)table printInfo:(NSPrintInfo *)pi
{
	NSRect				frame;
	NSSize				paperSize;
	
	entryPerPage = 30;
	subnetsTable = [table retain];
	pages = [subnetsTable numberOfRows] / entryPerPage;
	if (([subnetsTable numberOfRows] % entryPerPage) != 0)
	{
		pages = pages + 1;
	}
	paperSize = [pi paperSize];
	frame.origin = NSMakePoint(0,0);
	frame.size.width = paperSize.width;
	frame.size.height = paperSize.height * pages;
	self = [super initWithFrame:frame];
	rectHeight = paperSize.height / entryPerPage;
	return self;
}

-(BOOL)knowsPageRange:(NSRange *)range;
{
	range->location = 1;
	range->length = pages;
	return YES;
}

-(NSRect)rectForSubnet:(int)index
{
	NSRect	result;
	NSRect	bounds;
	
	bounds = [self bounds];
	result.origin.x = bounds.origin.x;
	result.size.width = bounds.size.width;
	result.origin.y = NSMaxY(bounds) -((index + 1) * rectHeight);
	result.size.height = rectHeight;
	return (result);
}

-(NSRect)rectForPage:(NSInteger)pageNum
{
	NSRect	result;
	
	result.size.width = [self bounds].size.width;
	result.size.height = rectHeight * entryPerPage;
	result.origin.x = [self bounds].origin.x;
	result.origin.y	= NSMaxY([self bounds]) - (pageNum * result.size.height);
	return (result);
}

-(void)drawRect:(NSRect)rect
{
	int					i;
	NSRect				aRect;
	NSMutableDictionary	*attributes;
	NSString			*printString;
	
	attributes = [[NSMutableDictionary alloc] init];
	[attributes setObject:[NSFont fontWithName:@"Helvetica" size:14] forKey: NSFontAttributeName];
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	for (i = 1; i <= [subnetsTable numberOfRows]; i++)
	{
		aRect = [self rectForSubnet:i];
		if (NSIntersectsRect(aRect, rect))
		{
			aRect.origin.x = aRect.origin.x + 50;
			aRect.size.width = aRect.size.width - 400;
			//NSLog(@"PrintLine %d %@\n",i, [subnetsTable tableView:
			printString = [NSString stringWithFormat: @"%d %@ %@ %@",
						   i, @"toto", @"tata", @"titi"
						   ];
						   //[[Subnets objectAtIndex:i] stringValue]];
			[printString drawInRect:aRect withAttributes:attributes];
		}
	}
	[attributes release];
}

-(void)dealloc
{
	[super dealloc];
}

@end
