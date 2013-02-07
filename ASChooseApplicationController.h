//
//  ASChooseApplicationController.h
//  PlistEdit
//
//  Created by administrator on 2/7/13.
//  Copyright 2013 1951FDG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ASChooseApplicationController : NSWindowController
{
    NSArray *items;
    IBOutlet NSTextField *prompt;
    IBOutlet NSTableView *tableView;
    IBOutlet NSArrayController *arrayController;
}

@property(retain) NSArrayController *arrayController;
@property(retain) NSTableView *tableView;
@property(retain) NSTextField *prompt;
@property(retain) NSArray *items;
- (IBAction)confirm:(id)arg1;
- (IBAction)cancel:(id)arg1;
- (IBAction)browse:(id)arg1;
- (void)awakeFromNib;
- (void)dealloc;

@end
