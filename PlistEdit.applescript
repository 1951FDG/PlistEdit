-- PlistEdit.applescript
-- PlistEdit

--  Created by administrator on 21-03-11.
--  Copyright 2011 __MyCompanyName__. All rights reserved.

on idle theObject
	call method "terminate:"
end idle

on launched theObject
	try
		(path to preferences as string) & id of (choose application) & ".plist"
	on error
		call method "terminate:"
	end try
	tell application "Finder"
		try
			reveal result
			activate
			open selection
		end try
		get bounds of window of desktop
	end tell
	tell application "System Events"
		try
			set value of property list item "ChooseAppBounds" of property list file ((path to preferences as string) & "com.apple.applescript" & ".plist") to item 1 of result & " " & item 2 of result & " " & item 4 of result & " " & item 3 of result & " 260 160 110 610 1 2 3" as string
		end try
	end tell
	call method "terminate:"
end launched
