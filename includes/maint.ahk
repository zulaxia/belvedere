VerifyConfig:
	;Read all the main sections and replace with defaults if not correct
	IniRead, Folders, rules.ini, Folders, Folders
	IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames
	IniRead, RBEnable, rules.ini, Preferences, RBEnable
	IniRead, RBEmpty, rules.ini, RecycleBin, RBEmpty
	IniRead, RBEmptyTimeValue, rules.ini, RecycleBin, RBEmptyTimeValue
	IniRead, RBEmptyTimeLength, rules.ini, RecycleBin, RBEmptyTimeLength
	IniRead, Sleeptime, rules.ini, Preferences, Sleeptime
	IniRead, EnableLogging, rules.ini, Preferences, EnableLogging
	IniRead, LogType, rules.ini, Preferences, LogType
	
	;Check each of the critical items, and if they are missing, create them
	; text of 'ERROR' denotes a missing tag
	
	if Folders = ERROR
		IniWrite, %A_Space%, rules.ini, Folders, Folders
	
	if AllRuleNames = ERROR
		IniWrite, %A_Space%, rules.ini, Rules, AllRuleNames
	
	;Disable RB info if not there
	if RBEnable = ERROR
		IniWrite, 0, rules.ini, Preferences, RBEnable
	
	;Disable RB emptty if not there
	if RBEmpty = ERROR
		IniWrite, 0, rules.ini, RecycleBin, RBEmpty
	
	;If this is missing we are going to disable RBEmpty just in case
	if RBEmptyTimeValue = ERROR
	{
		IniWrite, 0, rules.ini, RecycleBin, RBEmpty
		IniWrite, %A_Space%, rules.ini, RecycleBin, RBEmptyTimeValue
	}
	
	;If this is missing we are going to disable RBEmpty just in case
	if RBEmptyTimeLength = ERROR
	{
		IniWrite, 0, rules.ini, RecycleBin, RBEmpty
		IniWrite, %A_Space%, rules.ini, RecycleBin, RBEmptyTimeLength
	}
	
	;Default to 3 minutes if not there
	if Sleeptime = ERROR
		IniWrite, 300000, rules.ini, Preferences, Sleeptime

	;Disable logging if missing the tag
	if EnableLogging = ERROR
		IniWrite, 0, rules.ini, Preferences, EnableLogging

	if LogType = ERROR
	{
		;If logging is enabled, we default to System, otherwise we just create our blank tag
		IniRead, EnableLogging, rules.ini, Preferences, EnableLogging
		if (EnableLogging = 1)
			IniWrite, System, rules.ini, Preferences, LogType
		else
			IniWrite, %A_Space%, rules.ini, Preferences, LogType
	}
	
	Log("Completed configuration file verification", "System")
	MsgBox, Your configuration file has been verified successfully!
Return