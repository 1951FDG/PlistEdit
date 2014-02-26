//
//  ASChooseApplicationController.m
//  PlistEdit
//
//  Created by administrator on 2/7/13.
//  Copyright 2013 1951FDG. All rights reserved.
//

#import "ASChooseApplicationController.h"

@implementation ASChooseApplicationController

@synthesize items;
@synthesize prompt;
@synthesize tableView;
@synthesize arrayController;

- (void)confirm:(id)arg1
{
	[self close];
	[NSApp stopModalWithCode:NSAlertDefaultReturn];
}

- (void)cancel:(id)arg1
{
	[self close];
	[NSApp stopModalWithCode:NSAlertOtherReturn];
}

- (void)browse:(id)arg1
{
	[self close];
	[NSApp stopModalWithCode:NSAlertAlternateReturn];
}

- (void)awakeFromNib
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
	if (floor(kCFCoreFoundationVersionNumber) > kCFCoreFoundationVersionNumber10_5)
	{
		[arrayController setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease]]];
	}
	else
	{
		[arrayController setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease]]];
	}

#else
	[arrayController setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease]]];
#endif
}

- (void)dealloc
{
	[items release];
	[prompt release];
	[tableView release];
	[arrayController release];

	[super dealloc];
}

@end
