-- start_apps.applescript - prepare machine for work after reboot

-- author  : Chad Mayfield (chad@chd.my)
-- license : gplv3

-- change to desktop 2 [DOESN'T WORK]
--tell application "System Events"
--	key code 19 using {control down} -- control+2 is switch to Display Space 2
--end tell
--delay 2.0

-- open a couple of terminal windows with two tabs each
-- and run some commands to prepare workstation for work!
tell application "Terminal"
	-- open first window on right side of screen --
	set win to do script
	if not (exists window 1) then reopen
	set win's current settings to settings set "Dracula"
	activate
	
	try
		set position of window 1 to {350, 22}
		set size of window 1 to {600, 975} -- 84x57
		--set size of window 1 to {dtw / 2, dth - 800}
	end try
	
	-- do work here (on the right) --
	tell application "System Events" to keystroke "t" using {command down}
	delay 0.2
	do script "myip" in tab 1 of front window
	do script "cd ~/Code/myrepos/ && ./myrepos_status.sh" in tab 2 of front window
	--do script "some cmd" in tab 3 of front window	
end tell

tell application "Terminal"
	-- open second window on left side of screen --
	set win to do script
	if not (exists window 2) then reopen
	set win's current settings to settings set "Dracula"
	activate
	
	try
		set position of window 2 to {950, 22}
		set size of window 1 to {600, 975} -- 84x57
		--set size of window 2 to {dtw / 2, dth - 22}
	end try
	
	-- do work here (on the left) --
	tell application "System Events" to keystroke "t" using {command down}
	delay 0.2
	do script "uptime && w" in tab 1 of front window
	do script "cd ~/Code/ && ls" in tab 2 of front window
	--do script "some cmd" in tab 3 of front window
end tell

-- change to desktop 1 [DOESN'T WORK]
--tell application "System Events"
--	key code 18 using {control down} -- control+1 is switch to Display Space 1
--end tell
--delay 1.0

-- open Finder and then the Code directory
tell application "Finder"
	-- classic mac os syntax
	open alias "Macintosh HD:Users:chad:Code"
	-- or unix syntax
	--open POSIX file "~/Code"
end tell

-- create a new window (or reopen) with default settings
set p to "/Users/chad/Code"
tell application "Finder"
	reopen # if there are no open windows, open one
	activate
	set target of window 1 to (POSIX file p as text)
	--set bounds of front window to {0, 22, 450, 248}
	--or--
	--set position of window 1 to {0, 400}
	--set size of window 1 to {800, 500}
end tell

-- now open google chrome, if needed open tabs
tell application "Google Chrome"
	if it is running then
		quit
	else
		activate
		open location "https://github.com/chadmayfield"
		delay 1
		activate
		open location "https://startpage.com/"
		delay 1
		activate
	end if
end tell

-- finally open messages
tell application "Messages"
	activate
end tell


-- TODO
-- http://stackoverflow.com/a/2305588
--	tell application "System Events"
--	set x to application bindings of spaces preferences of expose preferences
--	set x to {|com.apple.messages|:2} & x  -- Have TextEdit appear in space 4
--	set application bindings of spaces preferences of expose preferences to x
-- end tell

-- http://stackoverflow.com/a/37305289
--tell application "System Events"
--	tell application "System Events" to key code 19 using control down
--key code 19 using {control down} -- control+2 is switch to Display Space 2
--end tell
--delay 1.0