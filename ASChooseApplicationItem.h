//
//  ASChooseApplicationItem.h
//  PlistEdit
//
//  Created by administrator on 2/7/13.
//  Copyright 2013 1951FDG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ASChooseApplicationItem : NSObject
{
    NSString *name;
	NSImage *icon;
	NSString *kind;
	NSString *version;
	NSString *path;
}

@property(retain) NSString *name;
@property(retain) NSImage *icon;
@property(retain) NSString *kind;
@property(retain) NSString *version;
@property(retain) NSString *path;
- (void)dealloc;

@end
