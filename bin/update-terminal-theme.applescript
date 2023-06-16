#!/usr/bin/env osascript
on run {name}
	tell application "Terminal"
		set default settings to settings set name
		set current settings of tabs of windows to settings set name
	end tell
end run
