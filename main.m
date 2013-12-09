//
//  main.m
//  PlistEdit
//
//  Created by administrator on 2/7/13.
//  Copyright 2013 1951FDG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASChooseApplicationController.h"
#import "ASChooseApplicationItem.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSApplication *sharedApplication = [NSApplication sharedApplication];
	
	CFArrayRef theArray = CFPreferencesCopyApplicationList(kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	
	if (theArray)
	{
		CFIndex i, c = CFArrayGetCount(theArray);
		
		if (c > 0)
		{
			CFMutableArrayRef marray = CFArrayCreateMutable(NULL, c, &kCFTypeArrayCallBacks);
			
			for (i = 0; i < c; i++)
			{
				CFTypeRef inBundleID = CFArrayGetValueAtIndex(theArray, i);
				
				if (inBundleID && CFGetTypeID(inBundleID) == CFStringGetTypeID())
				{
					CFURLRef outAppURL = NULL;
					
					if (LSFindApplicationForInfo(kLSUnknownCreator, inBundleID, NULL, NULL, &outAppURL) == noErr)
					{
						if (outAppURL)
						{
							CFBundleRef bundle = CFBundleCreate(NULL, outAppURL);
							
							if (bundle)
							{
								CFTypeRef result = NULL;
								
								CFDictionaryRef dict = CFBundleGetLocalInfoDictionary(bundle);
								
								if (dict)
								{
									result = CFDictionaryGetValue(dict, CFSTR("CFBundleName"));
								}
								
								dict = CFBundleGetInfoDictionary(bundle);
								
								if (dict)
								{
									ASChooseApplicationItem *arg1 = [ASChooseApplicationItem alloc];
									
									if (!result)
									{
										result = CFDictionaryGetValue(dict, CFSTR("CFBundleName"));
									}
									
									if (!result)
									{
										result = CFDictionaryGetValue(dict, CFSTR("CFBundleExecutable"));
									}
									
									if (result && CFGetTypeID(result) == CFStringGetTypeID())
									{
										arg1.name = (id)result;
									}
									
									result = CFDictionaryGetValue(dict, CFSTR("CFBundleShortVersionString"));
									
									if (!result)
									{
										result = CFDictionaryGetValue(dict, CFSTR("CFBundleVersion"));
									}
									
									if (result && CFGetTypeID(result) == CFStringGetTypeID())
									{
										arg1.version = (id)result;
									}
									else
									{
										arg1.version = @"—";
									}
									
									result = CFURLCopyFileSystemPath(outAppURL, kCFURLPOSIXPathStyle);
									
									if (result)
									{
										arg1.path = (id)result;
										arg1.icon = [[NSWorkspace sharedWorkspace] iconForFile:(id)result];
										
										CFRelease(result);
									}
									
									result = UTTypeCopyDescription(CFSTR("com.apple.application-bundle"));
									
									if (result)
									{
										arg1.kind = (id)result;
										
										CFRelease(result);
									}
									
									CFArrayAppendValue(marray, arg1);
									[arg1 release];
								}
								
								CFRelease(bundle);
							}
							
							CFRelease(outAppURL);
						}
					}
				}
			}
			
			if (CFArrayGetCount(marray) > 0)
			{
				ASChooseApplicationController *windowController = [[ASChooseApplicationController alloc] initWithWindowNibName:@"ChooseApplication"];
				[windowController setItems:(id)marray];
				[windowController setWindowFrameAutosaveName:@"Main Window"];
				
				[sharedApplication activateIgnoringOtherApps:YES];
				
				NSInteger runModal = [sharedApplication runModalForWindow:[windowController window]];
				
				if (runModal == NSAlertDefaultReturn)
				{
					ASChooseApplicationItem *anObject = [[windowController.arrayController selectedObjects] objectAtIndex:0];
					
					NSBundle *bundle = [NSBundle bundleWithPath:[anObject path]];
					
					if (bundle)
					{
						NSDictionary *dict = [bundle infoDictionary];
						
						if (dict)
						{
							id result = [dict objectForKey:@"CFBundleIdentifier"];
							
							if (result && [result isKindOfClass:[NSString class]])
							{
								NSString *fullPath = [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", [@"~" stringByExpandingTildeInPath], result];
								
								if (fullPath)
								{
									CFURLRef inURL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)fullPath, kCFURLPOSIXPathStyle, false);
									
									if (inURL)
									{
										FSRef ref1;
										OSStatus err = LSGetApplicationForURL(inURL, kLSRolesEditor, &ref1, NULL);
										
										if (err == noErr)
										{
											CFMutableArrayRef inURLs = CFArrayCreateMutable(NULL, 1, &kCFTypeArrayCallBacks);
											
											if (inURLs)
											{
												CFArrayAppendValue(inURLs, inURL);
												
												LSApplicationParameters appParams;
												appParams.version = 0;
												appParams.flags = kLSLaunchNoParams;
												appParams.application = &ref1;
												appParams.asyncLaunchRefCon = NULL;
												appParams.environment = NULL;
												appParams.argv = NULL;
												appParams.initialEvent = NULL;
												
												ProcessSerialNumber outPSN;
												err = LSOpenURLsWithRole(inURLs, kLSRolesEditor, NULL, &appParams, &outPSN, 1);
												
												if (err == noErr)
												{
													SetFrontProcess(&outPSN);
												}
												
												CFRelease(inURLs);
											}
										}
										
										if (err != noErr)
										{
											NSDictionary *userInfo = nil;
											const char *nullTerminatedCString = GetMacOSStatusCommentString(err);
											
											if (nullTerminatedCString)
											{
												NSString *firstObj = [[[NSString alloc] initWithUTF8String:nullTerminatedCString] autorelease];
												userInfo = [[[NSDictionary alloc] initWithObjects:&firstObj forKeys:&NSLocalizedRecoverySuggestionErrorKey count:1] autorelease];
											}
											
											NSError *error = [[[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:err userInfo:userInfo] autorelease];
											[[NSAlert alertWithError:error] runModal];
										}
										
										CFRelease(inURL);
									}
								}
							}
						}
					}
				}
				else if (runModal == NSAlertAlternateReturn)
				{
					NSOpenPanel *openPanel = [NSOpenPanel openPanel];
					[openPanel setTitle:[windowController.window title]];
					[openPanel setMessage:[windowController.prompt stringValue]];
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
					if (floor(kCFCoreFoundationVersionNumber) > 476.00)
					{
						[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"com.apple.application-bundle"]];
						
						runModal = [openPanel runModal];
					}
					else
					{
						runModal = [openPanel runModalForDirectory:nil file:nil types:[NSArray arrayWithObject:@"app"]];
					}
#else
					runModal = [openPanel runModalForDirectory:nil file:nil types:[NSArray arrayWithObject:@"app"]];
#endif
					if (runModal == NSAlertDefaultReturn)
					{
						id anObject = [[openPanel URLs] objectAtIndex:0];
						
						NSBundle *bundle = [NSBundle bundleWithPath:[anObject path]];
						
						if (bundle)
						{
							NSDictionary *dict = [bundle infoDictionary];
							
							if (dict)
							{
								id result = [dict objectForKey:@"CFBundleIdentifier"];
								
								if (result && [result isKindOfClass:[NSString class]])
								{
									NSString *fullPath = [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", [@"~" stringByExpandingTildeInPath], result];
									
									if (fullPath)
									{
										CFURLRef inURL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)fullPath, kCFURLPOSIXPathStyle, false);
										
										if (inURL)
										{
											FSRef ref1;
											OSStatus err = LSGetApplicationForURL(inURL, kLSRolesEditor, &ref1, NULL);
											
											if (err == noErr)
											{
												CFMutableArrayRef inURLs = CFArrayCreateMutable(NULL, 1, &kCFTypeArrayCallBacks);
												
												if (inURLs)
												{
													CFArrayAppendValue(inURLs, inURL);
													
													LSApplicationParameters appParams;
													appParams.version = 0;
													appParams.flags = kLSLaunchNoParams;
													appParams.application = &ref1;
													appParams.asyncLaunchRefCon = NULL;
													appParams.environment = NULL;
													appParams.argv = NULL;
													appParams.initialEvent = NULL;
													
													ProcessSerialNumber outPSN;
													err = LSOpenURLsWithRole(inURLs, kLSRolesEditor, NULL, &appParams, &outPSN, 1);
													
													if (err == noErr)
													{
														SetFrontProcess(&outPSN);
													}
													
													CFRelease(inURLs);
												}
											}
											
											if (err != noErr)
											{
												NSDictionary *userInfo = nil;
												const char *nullTerminatedCString = GetMacOSStatusCommentString(err);
												
												if (nullTerminatedCString)
												{
													NSString *firstObj = [[[NSString alloc] initWithUTF8String:nullTerminatedCString] autorelease];
													userInfo = [[[NSDictionary alloc] initWithObjects:&firstObj forKeys:&NSLocalizedRecoverySuggestionErrorKey count:1] autorelease];
												}
												
												NSError *error = [[[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:err userInfo:userInfo] autorelease];
												[[NSAlert alertWithError:error] runModal];
											}
											
											CFRelease(inURL);
										}
									}
								}
							}
						}
					}
				}
				
				[windowController release];
			}
			
			CFRelease(marray);
		}
		
		CFRelease(theArray);
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[pool drain];
	
    return 0;
}
