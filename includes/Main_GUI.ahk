;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows
; Author:         Adam Pash <adam.pash@gmail.com>
; Contributor:	  Matthew Shorts <mshorts@gmail.com>
;
; Script Name:	  Main_GUI
;
; This script is the main gui portion of the application.  It also has all the logic
;  to create, edit, and delete folders and their assigned rules 
;
; Some portions Generated using SmartGUI Creator 4.0 

;This is the main GUI screen with the tabs, menu options, and status bar
;  This window is always identified by Gui, 1
MANAGE:
	Gui, 1: Destroy
	Gui, 1: +OwnDialogs
	Gui, 1: Add, Tab2, w700 h425 vTabs , Folders|Recycle Bin|Preferences
	Gui, 1: Menu, MenuBar
	
	;Items found of First Tab
	Gui, 1: Tab, 1
	Gui, 1: Add, ListView, NoSortHdr x62 y52 w175 h310 vFolders gListRules,Folders|Path
	ListFolders := SubStr(Folders, 1, -1)
	if (ListFolders != "ERROR")
	{
		Loop, Parse, ListFolders, |
		{
			SplitPath, A_LoopField, FileName,,,,FileDrive
			;If no name is present we are assuming a root drive
			if (FileName = "")
				LV_Add(0, FileDrive, A_LoopField)
			else
				LV_Add(0, FileName, A_LoopField)
		}
		LV_ModifyCol(1, 171)
		LV_ModifyCol(2, 0)
	}

	Gui, 1: Add, ListView, NoSortHdr x252 y82 w410 h280 vRules gSetActive, Enabled|Rules
	Gui, 1: Add, Text, x252 y55, Folder:
	Gui, 1: Add, Text, x290 y55 w410 vFolderPath,
	Gui, 1: Add, Button, x62 y382 w30 h30 gAddFolder, +
	Gui, 1: Add, Button, x92 y382 w30 h30 gRemoveFolder, -
	Gui, 1: Add, Button, x30 y185 h30 vMoveUpFolder gMoveUpFolder, /\
	Gui, 1: Add, Button, x30 y215 h30 vMoveDownFolder gMoveDownFolder, \/
	Gui, 1: Add, Button, x252 y382 w30 h30 gAddRule, +
	Gui, 1: Add, Button, x282 y382 w30 h30 gRemoveRule, -
	Gui, 1: Add, Button, x312 y382 h30 vEditRule gEditRule, Edit Rule
	Gui, 1: Add, Button, x675 y185 h30 vMoveUpRule gMoveUpRule, /\
	Gui, 1: Add, Button, x675 y215 h30 vMoveDownRule gMoveDownRule, \/
	Gui, 1: Add, Button, x620 y382 h30 vEnableButton gEnableButton, Enable
	
	;Items found on Second Tab
	IniRead, RBEnable, rules.ini, Preferences, RBEnable, 0
	IniRead, RBEmpty, rules.ini, RecycleBin, RBEmpty, 0
	IniRead, RBEmptyTimeValue, rules.ini, RecycleBin, RBEmptyTimeValue, %A_Space%
	IniRead, RBEmptyTimeLength, rules.ini, RecycleBin, RBEmptyTimeLength, %A_Space%
	StringReplace, thisEmptyTimeLength, NoDefaultDateUnits, %RBEmptyTimeLength%, %RBEmptyTimeLength%|
	
	IniRead, RBLastEmpty, rules.ini, RecycleBin, RBLastEmpty, 0
	if RBLastEmpty
		FormatTime, DT, %RBLastEmpty%
	else
		DT := 
	
	Gui, 1: Tab, 2
	Gui, 1: Add, Checkbox, x62 y52 w585 vRBEnable gRBEnable Checked%RBEnable%, Allow %APPNAME% to manage my Recycle Bin
	Gui, 1: Add, Checkbox, x100 y100 vRBEmpty Checked%RBEmpty%, Empty my Recycle Bin every
	Gui, 1: Add, Edit, x255 y100 w70 vRBEmptyTimeValue Number, %RBEmptyTimeValue%
	Gui, 1: Add, DropDownList, x325 y100 w65 vRBEmptyTimeLength, %thisEmptyTimeLength%
	Gui, 1: Add, Text, x400 y100 vRBLastEmpty, Last Empty:  %DT%
	Gui, 1: Add, Button, x62 y382 h30 vRBSavePrefs gRBSavePrefs, Save Preferences
	
	GoSub, RBEnable ;Need to Enable/Disable the controls based on first checkbox
	
	;Items found on Third Tab
	IniRead, Sleep, rules.ini, Preferences, Sleeptime, 3
	IniRead, SleepLength, rules.ini, Preferences, SleeptimeLength, minutes
	StringReplace, thisSleeptimeLength, NoDefaultDateUnits, %SleepLength%, %SleepLength%|
	IniRead, EnableLogging, rules.ini, Preferences, EnableLogging, 0
	IniRead, LogType, rules.ini, Preferences, LogType, %A_Space%
	StringReplace, thisLogTypes, LogTypes, %LogType%, %LogType%|
	IniRead, GrowlEnabled, rules.ini, Preferences, GrowlEnabled, 0
	IniRead, TrayTipEnabled, rules.ini, Preferences, TrayTipEnabled, 0
	IniRead, ConfirmExit, rules.ini, Preferences, ConfirmExit, 1
	IniRead, Default_Enabled, rules.ini, Preferences, Default_Enabled, 0
	IniRead, Default_ConfirmAction, rules.ini, Preferences, Default_ConfirmAction, 0
	IniRead, Default_Recursive, rules.ini, Preferences, Default_Recursive, 0
	
	Gui, 1: Tab, 3
	Gui, 1: Add, Groupbox, x63 y40 w620 h70, System Options
	Gui, 1: Add, Text, x70 y60 w60 h20 , Sleeptime:
	Gui, 1: Add, Edit, x130 y58 w70 h20 Number vSleep, %Sleep%
	Gui, 1: Add, DropDownList, x200 y58 w65 vSleeptimeLength, %thisSleeptimeLength%
	Gui, 1: Add, Checkbox, x70 y90 vConfirmExit Checked%ConfirmExit%, Show confirmation dialog on exit
	Gui, 1: Add, Groupbox, x63 y120 w620 h95, Logging/Alert Options
	Gui, 1: Add, Checkbox, x70 y140 vEnableLogging Checked%EnableLogging%, Enable logging for this log type:
	Gui, 1: Add, DropDownList, x240 y138 w60 vLogType, %thisLogTypes%
	Gui, 1: Add, Checkbox, x70 y165 vGrowlEnabled Checked%GrowlEnabled%, Enable support for Growl for Windows (you must restart %APPNAME% for this setting to be applied)
	Gui, 1: Add, Checkbox, x70 y190 vTrayTipEnabled Checked%TrayTipEnabled%, Enable support for Windows Tray Tips (yellow pop-up bubble)
	Gui, 1: Add, Groupbox, x63 y222 w620 h70, Default Rule Options
	Gui, 1: Add, Text, x70 y242, The checked state of the following parameters will be the default for newly created rules:
	Gui, 1: Add, Checkbox, x70 y262 w70 h20 vDefault_Enabled Checked%Default_Enabled%, Enabled
	Gui, 1: Add, Checkbox, x140 y262 w95 h20 vDefault_ConfirmAction Checked%Default_ConfirmAction%, Confirm Action
	Gui, 1: Add, Checkbox, x235 y262 w100 h20 vDefault_Recursive Checked%Default_Recursive%, Recursive
	Gui, 1: Add, Groupbox, x63 y300 w620 h70, Command Line Parameters
	Gui, 1: Add, Text, x70 y320, %APPNAME% will accept the following command line parameters and corresponding values at runtime:
	Gui, 1: Add, Text, x70 y340, %A_Space%%A_Space%%A_Space%-r <integer>%A_Tab%Specifies the number of times you would like %APPNAME% to run then exit quietly.
	Gui, 1: Add, Button, x62 y382 h30 vSavePrefs gSavePrefs, Save Preferences
	Gui, 1: Add, Button, x580 y382 h30 vVerifyConfig gVerifyConfig, Verify Configuration
	
	;Status Bar with the various sections
	Gui, 1: Add, StatusBar
	SB_SetParts(650, 74)

	Gui, 1: Show, h463 w724, %APPNAME%
	GoSub, RefreshVars
Return

;Handles the closure of the screens
; Gui, 1 - Main tabbed interface
; Gui, 2 - Rule create/edit screen
GuiClose:
	Gui, 1: Destroy
	Gui, 2: Destroy
return

;Lists the folders on the left side of the screen
ListFolders:
	ActiveFolder=
	Gui, 1: Default
	Gui, 1: ListView, Folders
	LV_Delete()
	
	IniRead, Folders, rules.ini, Folders, Folders
	ListFolders := SubStr(Folders, 1, -1)
	Loop, Parse, ListFolders, |
	{
		SplitPath, A_LoopField, FileName,,,,FileDrive
		;If no name is present we are assuming a root drive
		if (FileName = "")
			LV_Add(0, FileDrive, A_LoopField)
		else
			LV_Add(0, FileName, A_LoopField)
	}
return

;Lists the rules on the right side of the screen for the actively 
; selected folder on the left side of the screen
ListRules:
	ActiveRule=
	Gui, 1: Default
	Gui, 1: ListView, Rules
	LV_Delete()
	if (A_EventInfo != 0)
	{
		Gui, 1: ListView, Folders
		LV_GetText(ActiveFolder, A_EventInfo, 2)
		CurrentlySelected = %A_eventinfo%

		Len := StrLen(ActiveFolder) - 70 
		if (Len <= 0)
		{
			GuiControl, 1: Text, FolderPath, %ActiveFolder%
		}
		else
		{
			NewPath := RegExReplace(ActiveFolder, "^(\w+:|\\)(\\[^\\]+\\[^\\]+\\).*(\\[^\\]+\\[^\\]+)$", "$1$2...$3")
			GuiControl, 1: Text, FolderPath, %NewPath%
		}
	}

	;Retrieves the rules for the actively selected folder and displays them
	; in the rule list on the right side, along with their enabled state
	IniRead, RuleNames, rules.ini, %ActiveFolder%, RuleNames, %A_Space%
	Gui, 1: ListView, Rules
	LV_Delete()
	ListRules := SubStr(RuleNames, 1, -1)
	Loop, Parse, ListRules, |
	{
		IniRead, Enabled, rules.ini, %A_LoopField%, Enabled, 0
		if (Enabled = 1)
			LV_Add(0,"Yes", A_LoopField)
		else
			LV_Add(0,"No", A_LoopField)
	}
	
	GoSub, RefreshVars
return

;Determines the actively selected rule on the right side
; also toggles the enable/disable button dependant on the state
; of the actively selected rule
SetActive:
	Gui, 1: ListView, Rules

	;Blank out ActiveRule if we get the column headings
	if (A_EventInfo = 0)
		ActiveRule =
	else 
		LV_GetText(ActiveRule, A_EventInfo, 2)

	;Change the button based on the selected rule's enable status
	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled, 0
	If (Enabled = 1)
		GuiControl, 1:, EnableButton, Disable
	else
		GuiControl, 1:, EnableButton, Enable
return

;Moves folder up in the folder list on the left side of the main GUI
; the order of the folder in this list is the order of precedence
; that the application will process them in
MoveUpFolder:
	Gui, 1: +OwnDialogs
	Gui, 1: ListView, Folders
	; make sure a folder is selected
	if (ActiveFolder = "")
	{
		MsgBox,,Select Folder, Please select a folder to move up.
		return
	}
	
	SelectedRow := LV_GetNext(RowNumber)
	if (SelectedRow = 1) ;if first folder we can't move up any more
		return
	
	LV_GetText(SelectedFolder, SelectedRow, 2)
	LV_GetText(PreviousFolder, SelectedRow-1, 2)
	
	;Taking the previous folder, replacing with a temp value and then 
	; replacing with the new folder then writing to the file
	IniRead, Folders, rules.ini, Folders, Folders
	StringReplace Folders, Folders, |%SelectedFolder%|, |--|
	
	if (SelectedRow = 2)
		Folders := RegExReplace(Folders, "^\Q" . PreviousFolder . "\E\|", SelectedFolder . "|")
	else
		StringReplace Folders, Folders, |%PreviousFolder%|, |%SelectedFolder%|
		
	StringReplace Folders, Folders, |--|, |%PreviousFolder%|
	IniWrite, %Folders%, rules.ini, Folders, Folders

	;Refresh the list then restore focus and select so that you can
	; continue to press the button
	Gosub, ListFolders
	LV_Modify(SelectedRow-1, "Select")
	GuiControl, 1: Focus, Folders
	ActiveFolder := SelectedFolder ;overridden because ListFolders zeros it out
return

;Moves folder down in the folder list on the left side of the main GUI
; the order of the folder in this list is the order of precedence
; that the application will process them in
MoveDownFolder:
	Gui, 1: +OwnDialogs
	Gui, 1: ListView, Folders
	
	; make sure a folder is selected
	if (ActiveFolder = "")
	{
		MsgBox,,Select Folder, Please select a folder to move down.
		return
	}

	SelectedRow := LV_GetNext(RowNumber)
	if (SelectedRow = LV_GetCount() or SelectedRow = 0) ;if last or only folder we can't move down any more
		return

	LV_GetText(SelectedFolder, SelectedRow, 2)
	LV_GetText(NextFolder, SelectedRow+1, 2)
	
	;Taking the next folder, replacing with a temp value and then 
	; replacing with the new folder then writing to the file
	IniRead, Folders, rules.ini, Folders, Folders
	
	if (SelectedRow = 1)
		Folders := RegExReplace(Folders, "^\Q" . SelectedFolder . "\E\|", "--|")
	else
		StringReplace Folders, Folders, |%SelectedFolder%|, |--|
	
	StringReplace Folders, Folders, |%NextFolder%|, |%SelectedFolder%|
	StringReplace Folders, Folders, --, %NextFolder%
	IniWrite, %Folders%, rules.ini, Folders, Folders

	;Refresh the list then restore focus and select so that you can
	; continue to press the button
	Gosub, ListFolders
	LV_Modify(SelectedRow+1, "Select")
	GuiControl, 1: Focus, Folders
	ActiveFolder := SelectedFolder ;overridden because ListFolders zeros it out
return

;Moves rules up in the rule list on the right side of the main GUI
; the order of the rules in this list is the order of precedence
; that the application will process them in
MoveUpRule:
	Gui, 1: +OwnDialogs
	Gui, 1: ListView, Rules
	; make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox,,Select Rule, Please select a rule to move up.
		return
	}
	
	SelectedRow := LV_GetNext(RowNumber)
	if (SelectedRow = 1) ;if first rule we can't move up any more
		return
	
	LV_GetText(SelectedRule, SelectedRow, 2)
	LV_GetText(PreviousRule, SelectedRow-1, 2)
	
	;Taking the previous rule, replacing with a temp value and then 
	; replacing with the new rule then writing to the file
	IniRead, RuleNames, rules.ini, %ActiveFolder%, RuleNames
	StringReplace RuleNames, RuleNames, |%SelectedRule%|, |--|
	
	if (SelectedRow = 2)
		RuleNames := RegExReplace(RuleNames, "^\Q" . PreviousRule . "\E\|", SelectedRule . "|")
	else
		StringReplace RuleNames, RuleNames, |%PreviousRule%|, |%SelectedRule%|
	
	StringReplace RuleNames, RuleNames, |--|, |%PreviousRule%|
	IniWrite, %RuleNames%, rules.ini, %ActiveFolder%, RuleNames

	;Refresh the list then restore focus and select so that you can
	; continue to press the button
	Gosub, ListRules
	LV_Modify(SelectedRow-1, "Select")
	GuiControl, 1: Focus, Rules
	ActiveRule := SelectedRule ;overridden because ListRules zeros it out
return

;Moves rules down in the rule list on the right side of the main GUI
; the order of the rules in this list is the order of precedence
; that the application will process them in
MoveDownRule:
	Gui, 1: +OwnDialogs
	Gui, 1: ListView, Rules
	
	; make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox,,Select Rule, Please select a rule to move down.
		return
	}

	SelectedRow := LV_GetNext(RowNumber)
	if (SelectedRow = LV_GetCount() or SelectedRow = 0) ;if last or only rule we can't move down any more
		return

	LV_GetText(SelectedRule, SelectedRow, 2)
	LV_GetText(NextRule, SelectedRow+1, 2)
	
	IniRead, RuleNames, rules.ini, %ActiveFolder%, RuleNames
	
	if (SelectedRow = 1)
		RuleNames := RegExReplace(RuleNames, "^\Q" . SelectedRule . "\E\|", "--|")
	else
		StringReplace RuleNames, RuleNames, |%SelectedRule%|, |--|
	
	StringReplace RuleNames, RuleNames, |%NextRule%|, |%SelectedRule%|
	StringReplace RuleNames, RuleNames, --, %NextRule%
	IniWrite, %RuleNames%, rules.ini, %ActiveFolder%, RuleNames

	;Refresh the list then restore focus and select so that you can
	; continue to press the button
	Gosub, ListRules
	LV_Modify(SelectedRow+1, "Select")
	GuiControl, 1: Focus, Rules
	ActiveRule := SelectedRule ;overridden because ListRules zeros it out
return

;Toggles the active state of the selected rule and saves it to the ini
EnableButton:
	Gui, 1: +OwnDialogs
	; make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox,,Select Rule, Please select a rule to enable/disable.
		return
	}

	;Toggle the enabled setting in the ini file
	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled, 0
	If (Enabled = 1)
		IniWrite, 0, rules.ini, %ActiveRule%, Enabled
	else
		IniWrite, 1, rules.ini, %ActiveRule%, Enabled

	Gosub, ListRules
return

;Run when the '+' button is clicked under the folder list
; responsible for showing a selection dialog and saving the folder
AddFolder:
	Gui, 1: +OwnDialogs
	FileSelectFolder, NewFolder, , 3, Please select a folder for %APPNAME% to monitor
	if (NewFolder = "")
		return

	SaveFolders(NewFolder, Folders)
return

;Run when the '-' button is clicked under the folder list
; responsible for deleting the selected folder and all rules
; associated with that folder
RemoveFolder:
	Gui, 1: +OwnDialogs
	if (CurrentlySelected = "")
	{
		Msgbox,,Select Folder, Select the folder you'd like to delete.
		return
	}
	
	;Confirm the delete, if no then we jump out of here
	MsgBox, 4, Delete Folder, Are you sure you would like to delete the folder "%ActiveFolder%" ?
	IfMsgBox No
		return
	
	;Get the currently selected folder and delete from the screen
	Gui, 1: Default
	Gui, 1: ListView, Folders
	LV_GetText(RemoveFolder, CurrentlySelected, 2)
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	
	;Delete the selected folder from above from the ini file list
	StringReplace, Folders, Folders, %RemoveFolder%|,,
	IniWrite, %Folders%, rules.ini, Folders, Folders
	
	;Delete all the rules associated with the selected folder from above
	IniRead, RuleNames, rules.ini, %RemoveFolder%, RuleNames
	Loop, Parse, RuleNames, |
	{
		if (A_LoopField != "")
		{
			StringReplace, AllRuleNames, AllRuleNames, %A_LoopField%|,,
			IniDelete, rules.ini, %A_LoopField%
		}
	}
	
	;Clean-up GUI when folder is removed
	GuiControl, 1: Text, FolderPath, %A_Space%
	
	;Rewrite the rule names now that we have delete all of the 
	; ones associated with this folder
	IniWrite, %AllRuleNames%, rules.ini, Rules, AllRuleNames
	IniDelete, rules.ini, %RemoveFolder%
	Gosub, RefreshVars
	Gosub, ListFolders
	
	Log("Folder Removed: " ActiveFolder, "System")
	Notify("Folder Removed: " ActiveFolder, "System")
	WinNotify("Folder Removed: " ActiveFolder, "System")
	
	Gosub, ListRules
return

;Run when the '-' button is clicked under the rule list
; this is responsible for confirming and completing the actual
; delete from the ini file
RemoveRule:
	Gui, 1: +OwnDialogs
	if (ActiveRule = "")
	{
		MsgBox,,Select Rule, Please select a rule to delete.
		return
	}
	
	;Confirm the delete, and if yes, remove from the screen and ini file
	MsgBox, 4, Delete Rule, Are you sure you would like to delete the rule "%ActiveRule%" ?
	IfMsgBox No
		return
	StringReplace, RuleNames, RuleNames, %ActiveRule%|,,
	Iniwrite, %RuleNames%, rules.ini, %ActiveFolder%, RuleNames
	StringReplace, AllRuleNames, AllRuleNames, %ActiveRule%|,,
	Iniwrite, %AllRuleNames%, rules.ini, Rules, AllRulenames
	Inidelete, rules.ini, %ActiveRule%
	
	Log("Rule Removed: " ActiveRule, "System")
	Notify("Rule Removed: " ActiveRule, "System")
	WinNotify("Rule Removed: " ActiveRule, "System")
	
	Gosub, RefreshVars
	Gosub, ListRules
return

;Run when the 'Save Preferences' button is clicked on the Preferences tab
; writes the information to the ini file
SavePrefs:
	Gui, 1: +OwnDialogs
	Gui, 1: Submit, NoHide
	SleepTime := Sleep
	SleeptimeLength := SleeptimeLength
	
	;Getting old values for enhanced logging prior to writing new ones
	IniRead, Old_EnableLogging, rules.ini, Preferences, EnableLogging
	IniRead, Old_Sleeptime, rules.ini, Preferences, Sleeptime
	IniRead, Old_SleeptimeLength, rules.ini, Preferences, SleeptimeLength
	IniRead, Old_GrowlEnabled, rules.ini, Preferences, GrowlEnabled
	IniRead, Old_TrayTipEnabled, rules.ini, Preferences, TrayTipEnabled

	
	IniWrite, %Sleep%, rules.ini, Preferences, Sleeptime
	IniWrite, %SleeptimeLength%, rules.ini, Preferences, SleeptimeLength
	IniWrite, %EnableLogging%, rules.ini, Preferences, EnableLogging
	IniWrite, %LogType%, rules.ini, Preferences, LogType
	IniWrite, %GrowlEnabled%, rules.ini, Preferences, GrowlEnabled
	IniWrite, %TrayTipEnabled%, rules.ini, Preferences, TrayTipEnabled
	IniWrite, %ConfirmExit%, rules.ini, Preferences, ConfirmExit
	IniWrite, %Default_Enabled%, rules.ini, Preferences, Default_Enabled
	IniWrite, %Default_ConfirmAction%, rules.ini, Preferences, Default_ConfirmAction
	IniWrite, %Default_Recursive%, rules.ini, Preferences, Default_Recursive
	
	if (EnableLogging <> Old_EnableLogging)
	{
		if (EnableLogging = 1)
		{
			if(LogType = "")
			{
				MsgBox,,Missing Logging Type, Please select a logging type
				return
			}
			
			Log("Logging has been enabled with type: " . LogType, "System")
			Notify("Logging has been enabled with type: " . LogType, "System")
			WinNotify("Logging has been enabled with type: " . LogType, "System")
		}
		else if (EnableLogging = 0)
		{
			Log("Logging has been disabled", "System")
			Notify("Logging has been disabled", "System")
			WinNotify("Logging has been disabled", "System")
		}
	}
	
	Log("Preferences have been saved", "System")
	Notify("Preferences have been saved", "System")
	WinNotify("Preferences have been saved", "System")
	
	if (Old_Sleeptime <> SleepTime or Old_SleeptimeLength <> SleeptimeLength)
	{
		Log("Preferences - Sleeptime changed from ". Old_Sleeptime . " " . Old_SleeptimeLength . " to " . SleepTime . " " . SleeptimeLength , "System")
		Notify("Preferences - Sleeptime changed from ". Old_Sleeptime . " " . Old_SleeptimeLength . " to " . SleepTime . " " . SleeptimeLength , "System")
		WinNotify("Preferences - Sleeptime changed from ". Old_Sleeptime . " " . Old_SleeptimeLength . " to " . SleepTime . " " . SleeptimeLength , "System")
	}
	
	if (Old_GrowlEnabled <> GrowlEnabled or Old_TrayTipEnabled <> TrayTipEnabled)
	{
		MsgBox, 4, Restart?, You must restart %APPNAME% for your new setting to take effect.`nWould you like to restart now?
		IfMsgBox No
			return
		
		GoSub, Restart
	}
	
	MsgBox,,Saved Settings, Your settings have been saved.
return

;Run when the 'Save Preferences' button is clicked on the Recycle Bin tab
; writes the information to the ini file
RBSavePrefs:
	Gui, 1: +OwnDialogs
	Gui, 1: Submit, NoHide
	IniWrite, %RBEnable%, rules.ini, Preferences, RBEnable

	;Check to see if all boxes are filled properly
	if( RBEnable = 1 )
	{	
		;Check Recycle Bin Empty values are chosen if section is enabled
		if (RBEmpty = 1)
		{
			if (RBEmptyTimeValue = "")
			{
				MsgBox,,Missing Empty Time, Please insert a time value to empty the Recycle Bin
				return
			}
			else if (RBEmptyTimeLength = "")
			{
				MsgBox,,Missing Empty Time Length, Please select a time value length to empty the Recycle Bin
				return
			}
		}
	}

	;Get Old values before writing new ones
	IniRead, Old_RBEmptyTimeValue, rules.ini, RecycleBin, RBEmptyTimeValue, 0
	IniRead, Old_RBEmptyTimeLength, rules.ini, RecycleBin, RBEmptyTimeLength, %A_Space%
	
	IniWrite, %RBEmpty%, rules.ini, RecycleBin, RBEmpty
	IniWrite, %RBEmptyTimeValue%, rules.ini, RecycleBin, RBEmptyTimeValue
	IniWrite, %RBEmptyTimeLength%, rules.ini, RecycleBin, RBEmptyTimeLength
	IniWrite, %A_Now%, rules.ini, RecycleBin, RBLastEmpty

	Log("Recycle Bin - Preferences have been saved", "System")
	Notify("Recycle Bin - Preferences have been saved", "System")
	WinNotify("Recycle Bin - Preferences have been saved", "System")
	
	if (Old_RBEmptyTimeValue <> RBEmptyTimeValue or Old_RBEmptyTimeLength <> RBEmptyTimeLength)
	{
		Log("Recycle Bin - Sleeptime changed from ". Old_RBEmptyTimeValue . " " . Old_RBEmptyTimeLength . " to " . RBEmptyTimeValue . " " . RBEmptyTimeLength , "System")
		Notify("Recycle Bin - Sleeptime changed from ". Old_RBEmptyTimeValue . " " . Old_RBEmptyTimeLength . " to " . RBEmptyTimeValue . " " . RBEmptyTimeLength , "System")
		WinNotify("Recycle Bin - Sleeptime changed from ". Old_RBEmptyTimeValue . " " . Old_RBEmptyTimeLength . " to " . RBEmptyTimeValue . " " . RBEmptyTimeLength , "System")
	}
	MsgBox,,Saved Settings, Your settings have been saved.
return

;Run when the first check box is clicked on the Recycle Bin tab
; enables all the other GUI options on the page; was added as a precautionary function
RBEnable:
	Gui, 1: Submit, NoHide
	
	if (RBEnable = 1)
	{
		GuiControl, 1: Enable, RBEmpty
		GuiControl, 1: Enable, RBEmptyTimeValue
		GuiControl, 1: Enable, RBEmptyTimeLength
	}
	else
	{
		GuiControl, 1: Disable, RBEmpty
		GuiControl, 1: Disable, RBEmptyTimeValue
		GuiControl, 1: Disable, RBEmptyTimeLength
	}
return

;Essentially this issues a double-click behind the scenes whenever a folder (SysListView321)
; or rule (SysListView322) is single clicked by the user.  This allows us to have it selected
; rather than just clicked upon
#IfWinActive, Belvedere
~LButton::
	MouseGetPos,,,,ClickedControl
	if (ClickedControl = "SysListView321") or (ClickedControl = "SysListView322")
	{
		Sleep, 10
		Click 2
	}
return

;A quick routine to update the master Folder list and rule names as well as the status bar
RefreshVars:
	IniRead, Folders, rules.ini, Folders, Folders
	IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames
		
	ListFolders := SubStr(Folders, 1, -1)
	FolderCount := 0
	Loop, Parse, ListFolders, |
	{
		FolderCount++
	}
	
	ListRules := SubStr(AllRuleNames, 1, -1)
	RuleCount := 0
	Loop, Parse, ListRules, |
	{
		RuleCount++
	}
	
	SB_SetText(APPNAME . " is currently managing " . FolderCount . " folders with " . RuleCount .  " total rules" , 1)
return

;Responsible for handling a folder that is drag-and-dropped over the folders list
; you can drag both a file or a folder and it will confirm the addition of the folder
; only works on the folder list for the time being
GuiDropFiles:
	Gui, 1: +OwnDialogs
	;Only accept DnD in the folders list box
	if A_GuiControl = Folders
	{
		StringSplit, F, A_GuiEvent, `n
		SplitPath, F1, , NewFolder
		MsgBox, 4, Add Folder, Would you like to add the following folder to your folder list?`n %NewFolder%
		IfMsgBox Yes
			SaveFolders(NewFolder, Folders)
	}
Return

;Response for handling the right click event and displaying of the context menu
; used right now for the context menu for all the rules
GuiContextMenu:
	;Only displaying for the Rules section right now
	if (A_GuiControl = "Rules" and A_EventInfo != 0)
	{
	
		Gui, 1: ListView, Folders
		FocusedRowNumber := LV_GetNext(0, "F")
		LV_GetText(FolderName, FocusedRowNumber, 2)
		
		Menu, ContextMenu, UseErrorLevel ;allows us to try to delete the menu, even if it doesn't exist, by surpressing hard stop
		Menu, CopySubmenu, DeleteAll
		Menu, MoveSubmenu, DeleteAll
		
		ListFolders := SubStr(Folders, 1, -1)
		Loop, Parse, ListFolders, |
		{
			if (A_LoopField != FolderName)
			{
				Menu, CopySubmenu, Add, %A_LoopField%, CopyRule
				Menu, MoveSubmenu, Add, %A_LoopField%, MoveRule
			}
		}

		Menu, ContextMenu, Add, Copy to, :CopySubmenu
		Menu, ContextMenu, Add, Move to, :MoveSubmenu		
		Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
	}
Return

;Reponsible for copying a rule from one folder to another
CopyRule:
	;Getting the selected rule
	Gui, 1: ListView, Rules
	FocusedRowNumber := LV_GetNext(0, "F")
	LV_GetText(RuleName, FocusedRowNumber, 2)
	
	;getting the current folder
	Gui, 1: ListView, Folders
	FocusedRowNumber := LV_GetNext(0, "F")
	LV_GetText(FolderName, FocusedRowNumber, 2)
	
	;Retrieve the current main settings for the rule selected for editing
	IniRead, Folder, rules.ini, %RuleName%, Folder, %A_Space%
	IniRead, Action, rules.ini, %RuleName%, Action, %A_Space%
	IniRead, Destination, rules.ini, %RuleName%, Destination, %A_Space%
	IniRead, Overwrite, rules.ini, %RuleName%, Overwrite, 0
	IniRead, Compress, rules.ini, %RuleName%, Compress, 0
	IniRead, Matches, rules.ini, %RuleName%, Matches, %A_Space%
	IniRead, Enabled, rules.ini, %RuleName%, Enabled, 0
	IniRead, ConfirmAction, rules.ini, %RuleName%, ConfirmAction, 0
	IniRead, Recursive, rules.ini, %RuleName%, Recursive, 0
	
	LineNum =
	Loop
	{
		if ((A_Index-1) = NumOfRules)
			break

		if (A_Index = 1)
			RuleNum =
		else
			RuleNum := A_Index - 1

		IniRead, Subject%RuleNum%, rules.ini, %RuleName%, Subject%RuleNum%
		IniRead, Verb%RuleNum%, rules.ini, %RuleName%, Verb%RuleNum%
		IniRead, Object%RuleNum%, rules.ini, %RuleName%, Object%RuleNum%
		IniRead, Units%RuleNum%, rules.ini, %RuleName%, Units%RuleNum%

		if (LineNum = "")
			LineNum := 0
		
		LineNum++
	}
	
	StringReplace, RuleMatchList, AllRuleNames, |,`,,ALL
	Loop
	{
		if RuleName in %RuleMatchList%
		{
			RegExMatch(RuleName, "^(.*)\s(\((\d+)\))$", Match)
			
			if (Match3 != "")
			{
				Match3++
				RuleName = %Match1% (%Match3%)
			}
			else
			{
				RuleName = %RuleName% (1)
			}
		}
		else
		{
			break
		}
	}
	
	IniWrite, %RuleName%|, rules.ini, %A_ThisMenuItem%, RuleNames
	IniWrite, %AllRuleNames%%RuleName%|, rules.ini, Rules, AllRuleNames
	IniWrite, %A_ThisMenuItem%\*, rules.ini, %RuleName%, Folder
	IniWrite, %Enabled%, rules.ini, %RuleName%, Enabled
	IniWrite, %ConfirmAction%, rules.ini, %RuleName%, ConfirmAction
	IniWrite, %Recursive%, rules.ini, %RuleName%, Recursive
	IniWrite, %Matches%, rules.ini, %RuleName%, Matches
	IniWrite, %GUIAction%, rules.ini, %RuleName%, Action
	
	;only need to write these tags if they need a destination
	if  (GUIAction != "Send file to Recycle Bin") and (GUIAction != "Delete file")
	{
		IniWrite, %GUIDestination%, rules.ini, %RuleName%, Destination
		IniWrite, %Overwrite%, rules.ini, %RuleName%, Overwrite
		IniWrite, %Compress%, rules.ini, %RuleName%, Compress
	}
	
	;save the rest of the subject combos
	Loop
	{
		if (A_Index = 1)
			thisLine =
		else
			thisLine := A_Index - 1

		if (A_Index > LineNum)
			break

		if (Subject%thisLine% != "")
		{
			if (thisLine = "")
				RuleNum =
			else if (RuleNum = "")
				RuleNum := 1
			else
				RuleNum++

			IniWrite, % Subject%thisLine%, rules.ini, %RuleName%, Subject%RuleNum%
			IniWrite, % Verb%thisLine%, rules.ini, %RuleName%, Verb%RuleNum%
			IniWrite, % Object%thisLine%, rules.ini, %RuleName%, Object%RuleNum%
			IniWrite, % Units%thisLine%, rules.ini, %RuleName%, Units%RuleNum%
		}
	}
Return

;Reponsible for moving a rule from one folder to another
MoveRule:
	;Getting the selected rule
	Gui, 1: ListView, Rules
	FocusedRowNumber := LV_GetNext(0, "F")
	LV_GetText(RuleName, FocusedRowNumber, 2)
	
	;getting the current folder
	Gui, 1: ListView, Folders
	FocusedRowNumber := LV_GetNext(0, "F")
	LV_GetText(FolderName, FocusedRowNumber, 2)

	;deleting from the current folder
	IniRead, RuleNames, rules.ini, %FolderName%, RuleNames
	StringReplace, RuleNames, RuleNames, %RuleName%|,,
	IniWrite, %RuleNames%, rules.ini, %FolderName%, RuleNames
	
	;creating in the new folder
	IniRead, RuleNames, rules.ini, %A_ThisMenuItem%, RuleNames
	IniWrite, %RuleNames%%RuleName%|, rules.ini, %A_ThisMenuItem%, RuleNames
	
	;updating rule's own folder path
	IniWrite, %A_ThisMenuItem%\*, rules.ini, %RuleName%, Folder
	
	;Refresh the list then restore focus and select so that you can
	; continue to press the button
	Gosub, ListRules
	LV_Modify(SelectedRow-1, "Select")
	GuiControl, 1: Focus, Rules
	ActiveRule := SelectedRule ;overridden because ListRules zeros it out
Return

;Responsible for checking for duplicate folders and saving the newly added folder to the ini file
SaveFolders(NewFolder, Folders)
{
	StringReplace, FoldersMatchList, Folders, |,`,,ALL
	if NewFolder in %FoldersMatchList%
	{
		Msgbox, ,Duplicate Folder, A folder with this name already exists. Please choose a new folder.
 		return
	}
	
	Folders = %Folders%%NewFolder%|
	IniWrite, %Folders%, rules.ini, Folders, Folders
	IniWrite, %A_Space%, rules.ini, %NewFolder%, RuleNames
	Gui, 1: Default
	Gui, 1: ListView, Folders
	
	Log("Folder Added: " NewFolder, "System")
	Notify("Folder Added: " NewFolder, "System")
	WinNotify("Folder Added: " NewFolder, "System")
	Gosub, ListFolders
	Gosub, RefreshVars
	return
}
