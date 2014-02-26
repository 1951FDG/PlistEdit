//
//  ASChooseApplicationItem.m
//  PlistEdit
//
//  Created by administrator on 2/7/13.
//  Copyright 2013 1951FDG. All rights reserved.
//

#import "ASChooseApplicationItem.h"

@implementation ASChooseApplicationItem

@synthesize name;
@synthesize icon;
@synthesize kind;
@synthesize version;
@synthesize path;

- (void)dealloc
{
	[name release];
	[icon release];
	[kind release];
	[version release];
	[path release];

	[super dealloc];
}

@end
