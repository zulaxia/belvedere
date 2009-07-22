;This is used to check the structure of the ini file to make sure that we have
; what we expect to get.  It is run on-demand from the GUI or whenever a new configuration
; file is imported
VerifyConfig:
	ChangeCount := 0

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
	IniRead, CaseSensitivity, rules.ini, Preferences, CaseSensitivity
	
	;Check each of the critical items, and if they are missing, create them
	; text of 'ERROR' denotes a missing tag
	
	if Folders = ERROR
	{
		IniWrite, %A_Space%, rules.ini, Folders, Folders
		ChangeCount++
	}
	
	if AllRuleNames = ERROR
	{
		IniWrite, %A_Space%, rules.ini, Rules, AllRuleNames
		ChangeCount++
	}
	
	;Disable RB info if not there
	if RBEnable = ERROR
	{
		IniWrite, 0, rules.ini, Preferences, RBEnable
		ChangeCount++
	}
	
	;Disable RB emptty if not there
	if RBEmpty = ERROR
	{
		IniWrite, 0, rules.ini, RecycleBin, RBEmpty
		ChangeCount++
	}
	
	;If this is missing we are going to disable RBEmpty just in case
	if RBEmptyTimeValue = ERROR
	{
		IniWrite, 0, rules.ini, RecycleBin, RBEmpty
		IniWrite, %A_Space%, rules.ini, RecycleBin, RBEmptyTimeValue
		ChangeCount++
	}
	
	;If this is missing we are going to disable RBEmpty just in case
	if RBEmptyTimeLength = ERROR
	{
		IniWrite, 0, rules.ini, RecycleBin, RBEmpty
		IniWrite, %A_Space%, rules.ini, RecycleBin, RBEmptyTimeLength
		ChangeCount++
	}
	
	;Default to 3 minutes if not there
	if Sleeptime = ERROR
	{
		IniWrite, 300000, rules.ini, Preferences, Sleeptime
		ChangeCount++
	}

	;Disable logging if missing the tag
	if EnableLogging = ERROR
	{
		IniWrite, 0, rules.ini, Preferences, EnableLogging
		ChangeCount++
	}

	if LogType = ERROR
	{
		;If logging is enabled, we default to System, otherwise we just create our blank tag
		IniRead, EnableLogging, rules.ini, Preferences, EnableLogging
		if (EnableLogging = 1)
			IniWrite, System, rules.ini, Preferences, LogType
		else
			IniWrite, %A_Space%, rules.ini, Preferences, LogType
		
		ChangeCount++
	}
	
	;Default to being case sensitive if not there
	if CaseSensitivity = ERROR
	{
		IniWrite, 1, rules.ini, Preferences, CaseSensitivity
		ChangeCount++
	}
	
	Log("Completed configuration file verification; making " . ChangeCount . " corrections", "System")
	MsgBox, , Verification Complete, Your configuration file has been verified successfully!
Return
