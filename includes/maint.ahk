;This is used to check the structure of the ini file to make sure that we have
; what we expect to get.  It is run on-demand from the GUI or whenever a new configuration
; file is imported
VerifyConfig:
	Gui +OwnDialogs
	ChangeCount := 0

	;Read all the main sections and replace with defaults if not correct
	IniRead, Folders, rules.ini, Folders, Folders
	IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames
	IniRead, RBEnable, rules.ini, Preferences, RBEnable
	IniRead, RBEmpty, rules.ini, RecycleBin, RBEmpty
	IniRead, RBEmptyTimeValue, rules.ini, RecycleBin, RBEmptyTimeValue
	IniRead, RBEmptyTimeLength, rules.ini, RecycleBin, RBEmptyTimeLength
	IniRead, Sleeptime, rules.ini, Preferences, Sleeptime
	IniRead, SleeptimeLength, rules.ini, Preferences, SleeptimeLength
	IniRead, EnableLogging, rules.ini, Preferences, EnableLogging
	IniRead, LogType, rules.ini, Preferences, LogType
	IniRead, GrowlEnabled, rules.ini, Preferences, GrowlEnabled
	IniRead, TrayTipEnabled, rules.ini, Preferences, TrayTipEnabled
	IniRead, ConfirmExit, rules.ini, Preferences, ConfirmExit
	IniRead, Default_Enabled, rules.ini, Preferences, Default_Enabled
	IniRead, Default_ConfirmAction, rules.ini, Preferences, Default_ConfirmAction
	IniRead, Default_Recursive, rules.ini, Preferences, Default_Recursive
	
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
		IniWrite, 3, rules.ini, Preferences, Sleeptime
		ChangeCount++
	}

	if SleeptimeLength = ERROR
	{
		IniWrite, minutes, rules.ini, Preferences, SleeptimeLength
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
	
	if GrowlEnabled = ERROR
	{
		IniWrite, 0, rules.ini, Preferences, GrowlEnabled
		ChangeCount++
	}
	
	if TrayTipEnabled = ERROR
	{
		IniWrite, 0, rules.ini, Preferences, TrayTipEnabled
		ChangeCount++
	}
	
	;Default to yes if not there
	if ConfirmExit = ERROR
	{
		IniWrite, 1, rules.ini, Preferences, ConfirmExit
		ChangeCount++	
	}
	
	;Default to no if not there
	if Default_Enabled = ERROR
	{
		IniWrite, 0, rules.ini, Preferences, Default_Enabled
		ChangeCount++
	}
	
	;Default to no if not there
	if Default_ConfirmAction = ERROR
	{
		IniWrite, 0, rules.ini, Preferences, Default_ConfirmAction
		ChangeCount++
	}
	
	;Default to no if not there
	if Default_Recursive = ERROR
	{
		IniWrite, 0, rules.ini, Preferences, Default_Recursive
		ChangeCount++
	}
	
	Log("Completed configuration file verification; making " . ChangeCount . " corrections", "System")
	MsgBox, , Verification Complete, Your configuration file has been verified successfully!`n %ChangeCount% changes were made
Return
