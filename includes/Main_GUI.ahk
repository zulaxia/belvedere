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
	Gui, 1: Add, Button, x252 y382 w30 h30 gAddRule, +
	Gui, 1: Add, Button, x282 y382 w30 h30 gRemoveRule, -
	Gui, 1: Add, Button, x312 y382 h30 vEditRule gEditRule, Edit Rule
	Gui, 1: Add, Button, x436 y382 h30 vMoveUp gMoveUp, Move Up
	Gui, 1: Add, Button, x492 y382 h30 vMoveDown gMoveDown, Move Down
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
	
	Gui, 1: Tab, 3
	Gui, 1: Add, Text, x62 y62 w60 h20 , Sleeptime:
	Gui, 1: Add, Edit, x120 y60 w70 h20 Number vSleep, %Sleep%
	Gui, 1: Add, DropDownList, x190 y60 w65 vSleeptimeLength, %thisSleeptimeLength%
	;Gui, 1: Add, Text, x225 y62, (Time in milliseconds)
	Gui, 1: Add, Checkbox, x62 y102 vEnableLogging Checked%EnableLogging%, Enable logging for this log type:
	Gui, 1: Add, DropDownList, x232 y102 w60 vLogType, %thisLogTypes%
	Gui, 1: Add, Checkbox, x62 y132 vGrowlEnabled Checked%GrowlEnabled%, Enable support for Growl for Windows (you must restart %APPNAME% for this setting to be applied)
	Gui, 1: Add, Text, x70 y320, %APPNAME% will accept the following command line parameters and corresponding values at runtime:
	Gui, 1: Add, Text, x70 y340, %A_Space%%A_Space%%A_Space%-r <integer>%A_Tab%Specifies the number of times you would like %APPNAME% to run then exit quietly.
	Gui, 1: Add, Groupbox, x63 y300 w620 h70, Command Line Parameters
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

;Lists the rules on the right side of the screen for the actively 
; selected folder on the left side of the screen
ListRules:
	ActiveRule=
	Gui, 1:Default
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
	Gui, ListView, Rules

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

;Moves rules up in the rule list on the right side of the main GUI
; the order of the rules in this list is the order of precedence
; that the application will process them in
MoveUp:
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
	StringReplace RuleNames, RuleNames, %SelectedRule%, --
	StringReplace RuleNames, RuleNames, %PreviousRule%, %SelectedRule%
	StringReplace RuleNames, RuleNames, --, %PreviousRule%
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
MoveDown:
	; make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox,,Select Rule, Please select a rule to move down.
		return
	}

	SelectedRow := LV_GetNext(RowNumber)
	if (SelectedRow = LV_GetCount()) ;if last rule we can't move down any more
		return

	LV_GetText(SelectedRule, SelectedRow, 2)
	LV_GetText(NextRule, SelectedRow+1, 2)
	
	IniRead, RuleNames, rules.ini, %ActiveFolder%, RuleNames
	StringReplace RuleNames, RuleNames, %SelectedRule%, --
	StringReplace RuleNames, RuleNames, %NextRule%, %SelectedRule%
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
	FileSelectFolder, NewFolder,
	if (NewFolder = "")
		return

	SaveFolders(NewFolder, Folders)
return

;Run when the '-' button is clicked under the folder list
; responsible for deleting the selected folder and all rules
; associated with that folder
RemoveFolder:
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
	Gui, ListView, Folders
	LV_GetText(RemoveFolder, CurrentlySelected, 2)
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	success := LV_Delete()
	
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
	
	;Rewrite the rule names now that we have delete all of the 
	; ones associated with this folder
	IniWrite, %AllRuleNames%, rules.ini, Rules, AllRuleNames
	IniDelete, rules.ini, %RemoveFolder%
	Gosub, RefreshVars

	Loop, Parse, Folders, |
	{
		SplitPath, A_LoopField, FileName,,,,FileDrive
		;If no name is present we are assuming a root drive
		if (FileName = "")
			LV_Add(0, FileDrive, A_LoopField)
		else
			LV_Add(0, FileName, A_LoopField)
	}
	
	Log("Folder Removed: " ActiveFolder, "System")
	
	Gosub, ListRules
return

;Run when the '+' button is clicked under the rule list
; only the GUI creation of the rule process, saving is handled in
; SaveRule procedure below
AddRule:
	Skip=
	Edit := 0 ; this is a new rule, not a rule being edited
	LineNum=
	NumOfRules := 1
	
	;Get the currently selected folder, if any
	if (CurrentlySelected = "")
	{
		MsgBox,,Select Folder, You must select a folder to create a rule
		return
	}
	Gui, ListView, Folders
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	LV_GetText(FolderName, CurrentlySelected, 3)
	
	;Create a new 'Create a rule...' dialog box with base settings
	Gui, 2: Destroy
	Gui, 2: +owner1
	Gui, 2: +toolwindow
	Gui, 2: Add, Text, x52 y32 h20 vFolderPath, Folder: %ActiveFolder%
	Gui, 2: Add, Text, x32 y62 w60 h20 , Description:
	Gui, 2: Add, Edit, x92 y62 w250 h20 vRuleName , 
	Gui, 2: Add, Checkbox, x448 y30 vEnabled, Enabled
	Gui, 2: Add, Checkbox, x448 y50 vConfirmAction, Confirm Action
	Gui, 2: Add, Checkbox, x448 y70 vRecursive, Recursive
	Gui, 2: Add, Groupbox, x443 y10 w110 h80, Rule Options
	Gui, 2: Add, Text, x32 y92 w520 h20 , __________________________________________________________________________________________
	Gui, 2: Add, Text, x32 y122 w10 h20 , If
	Gui, 2: Add, DropDownList, x45 y120 w46 h20 r2 vMatches , ALL||ANY
	Gui, 2: Add, Text, x96 y122 w240 h20 , of the following conditions are met:
	Gui, 2: Add, DropDownList, x32 y152 w160 h20 r6 vGUISubject gSetVerbList , %AllSubjects%
	Gui, 2: Add, DropDownList, x202 y152 w160 h21 r6 vGUIVerb , %NameVerbs%
	Gui, 2: Add, Edit, x372 y152 w140 h20 vGUIObject , 
	Gui, 2: Add, DropDownList, x445 y152 vGUIUnits w60 ,
	GuiControl, 2: Hide, GUIUnits
	Gui, 2: Add, Button, vGUINewLine x515 y152 w20 h20 gNewLine , +
	Gui, 2: Add, Text, x32 y212 w260 h20 vConsequence , Do the following:
	Gui, 2: Add, DropDownList, x32 y242 w160 h20 vGUIAction gSetDestination r6 , %AllActions%
	Gui, 2: Add, Text, x202 y242 h20 w45 vActionTo , to folder:
	Gui, 2: Add, Edit, x248 y242 w190 h20 w200 vGUIDestination , 
	Gui, 2: Add, Button, x450 y242 gChooseFolder vGUIChooseFolder h20, ...
	Gui, 2: Add, Button, x515 y242 gChooseAction vGUIChooseAction h20, ...
	Gui, 2: Add, Checkbox, x482 y237 vOverwrite, Overwrite?
	Gui, 2: Add, Checkbox, x482 y252 vCompress, Compress?
	Gui, 2: Add, Button, x32 y302 w100 h30 vTestButton gTESTMatches, Test
	Gui, 2: Add, Button, x372 y302 w100 h30 vOKButton gSaveRule, OK
	Gui, 2: Add, Button, x482 y302 w100 h30 vCancelButton gGui2Close, Cancel
	
	Len := StrLen(ActiveFolder) - 60 
	if (Len > 0)
	{
		NewPath := RegExReplace(ActiveFolder, "^(\w+:|\\)(\\[^\\]+\\[^\\]+\\).*(\\[^\\]+\\[^\\]+)$", "$1$2...$3")
		GuiControl, 2: Text, FolderPath, Folder: %NewPath%
	}

	Gui, 2: Show, h348 w598, Create a rule...
	Gosub, RefreshVars
	Gosub, ListRules
Return

;Run when the 'Edit' button is clicked under the rule list
; only the GUI creation of the rule process and population with the 
; current rule settings, saving is handled in SaveRule procedure below
EditRule:
	Skip = 
	Edit := 1
	
	;make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox,,Select Rule, Please select a rule to edit.
		return
	}
	OldName = %ActiveRule%
	
	;find out how many conditions a rule has
	NumOfRules := 1
	Loop 
	{
		IniRead, MultiRule, rules.ini, %ActiveRule%, Subject%A_Index%
		if (MultiRule != "ERROR")
			NumOfRules++ 
		else
			break
	}

	;Retrieve the current main settings for the rule selected for editing
	IniRead, Folder, rules.ini, %ActiveRule%, Folder, %A_Space%
	IniRead, Action, rules.ini, %ActiveRule%, Action, %A_Space%
	IniRead, Destination, rules.ini, %ActiveRule%, Destination, %A_Space%
	IniRead, Overwrite, rules.ini, %ActiveRule%, Overwrite, 0
	IniRead, Compress, rules.ini, %ActiveRule%, Compress, 0
	IniRead, Matches, rules.ini, %ActiveRule%, Matches, %A_Space%
	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled, 0
	IniRead, ConfirmAction, rules.ini, %ActiveRule%, ConfirmAction, 0
	IniRead, Recursive, rules.ini, %ActiveRule%, Recursive, 0
	
	;Create the GUI and insert the current main settings for the rules selected
	Gui, 2: Destroy
	Gui, 2: +owner1
	Gui, 2: +toolwindow
	Gui, 2: Add, Text, x52 y32 h20 vFolderPath, Folder: %ActiveFolder%
	Gui, 2: Add, Text, x32 y62 w60 h20 , Description:
	Gui, 2: Add, Edit, x92 y62 w250 h20 vRuleName , %ActiveRule%
	Gui, 2: Add, Checkbox, x448 y30 Checked%Enabled% vEnabled, Enabled
	Gui, 2: Add, Checkbox, x448 y50 Checked%ConfirmAction% vConfirmAction, Confirm Action
	Gui, 2: Add, Checkbox, x448 y70 Checked%Recursive% vRecursive, Recursive
	Gui, 2: Add, Groupbox, x443 y10 w110 h80, Rule Options
	Gui, 2: Add, Text, x32 y92 w520 h20 , __________________________________________________________________________________________
	Gui, 2: Add, Text, x32 y122 w10 h20 , If
	StringReplace, thisMatchList, MatchList, %Matches%, %Matches%|
	Gui, 2: Add, DropDownList, x45 y120 w46 h20 r2 vMatches , %thisMatchList%
	Gui, 2: Add, Text, x96 y122 w240 h20 , of the following conditions are met:
	
	Len := StrLen(ActiveFolder) - 60 
	if (Len > 0)
	{
		NewPath := RegExReplace(ActiveFolder, "^(\w+:|\\)(\\[^\\]+\\[^\\]+\\).*(\\[^\\]+\\[^\\]+)$", "$1$2...$3")
		GuiControl, 2: Text, FolderPath, Folder: %NewPath%
	}
	
	; this loop creates the controls for all of the conditions in the rule
	height =
	LineNum =
	Loop
	{
		if ((A_Index-1) = NumOfRules)
			break

		if (A_Index = 1)
			RuleNum =
		else
			RuleNum := A_Index - 1

		IniRead, Subject%RuleNum%, rules.ini, %ActiveRule%, Subject%RuleNum%
		IniRead, Verb%RuleNum%, rules.ini, %ActiveRule%, Verb%RuleNum%
		IniRead, Object%RuleNum%, rules.ini, %ActiveRule%, Object%RuleNum%
		IniRead, Units%RuleNum%, rules.ini, %ActiveRule%, Units%RuleNum%
		if (LineNum = "")
		{
			LineNum := 0
			height := 152
		}
		else
		{
			height := (RuleNum * 30) + 152
		}
		
		; Set each control with the value of each rule
		defaultSubject = % Subject%RuleNum% "|"
		defaultVerb = % Verb%RuleNum% "|"
		defaultUnit = % Units%RuleNum% "|"
		StringReplace, RuleSubject, NoDefaultSubject, %defaultSubject%, %defaultSubject%|
		
		; verbs need to be set by subject b/c verbs change by subject
		if (defaultSubject = "Name|") or (defaultSubject = "Extension|")
			NoDefaultVerbs = %NoDefaultNameVerbs%
		else if (defaultSubject = "Size|")
			NoDefaultVerbs = %NoDefaultNumVerbs%
		else if (defaultSubject = "Date last modified|") or (defaultSubject = "Date last opened|") or (defaultSubject = "Date created|")
			NoDefaultVerbs = %NoDefaultDateVerbs%

		StringReplace, RuleVerb, NoDefaultVerbs, %defaultVerb%, %defaultVerb%|

		Gui, 2: Add, DropDownList, x32 y%height% w160 h20 r6 vGUISubject%RuleNum% gSetVerbList , %RuleSubject%
		Gui, 2: Add, DropDownList, x202 y%height% w160 h21 r6 vGUIVerb%RuleNum% , %RuleVerb%
		Gui, 2: Add, Edit, x372 y%height% w140 h20 vGUIObject%RuleNum% , % Object%RuleNum%
		
		;Change the GUI objects based on the subject of each line
		if (defaultSubject = "Size|")
		{
			NoDefaultUnits = %NoDefaultSizeUnits%
			GuiControl, 2: Move , GUIObject%RuleNum% , w70
			GuiControl, 2: +Number, GUIObject%RuleNum%
		}
		else if (defaultSubject = "Date last modified|") or (defaultSubject = "Date last opened|") or (defaultSubject = "Date created|")
		{
			NoDefaultUnits = %NoDefaultDateUnits%
			GuiControl, 2: Move , GUIObject%RuleNum% , w70
			GuiControl, 2: +Number, GUIObject%RuleNum%
		}

		StringReplace, RuleUnits, NoDefaultUnits, %defaultUnit%, %defaultUnit%|

		;Change the GUI objects based on the subject of each line
		Gui, 2: Add, DropDownList, x445 y%height% vGUIUnits%RuleNum% w60 , %RuleUnits%
		if (defaultSubject = "Name|") or (defaultSubject = "Extension|")
			GuiControl, 2: Hide, GUIUnits%RuleNum%

		Gui, 2: Add, Button, vGUINewLine%RuleNum% x515 y%height% w20 h20 gNewLine , +
		if (RuleNum != "")
			Gui, 2: Add, Button, vGUIRemLine%RuleNum% x535 y%height% w20 h20 gRemLine , -

		LineNum++
	}
	
	ActionHeight :=
	Gui, 2: Add, Text, x32 y212 w260 h20 vConsequence , Do the following:
	StringReplace, RuleAction, AllActionsNoDefault, %Action%, %Action%|

	Gui, 2: Add, DropDownList, x32 y242 w160 h20 vGUIAction gSetDestination r6 , %RuleAction%
	Gui, 2: Add, Text, x202 y242 h20 w45 vActionTo , to folder:
	Gui, 2: Add, Edit, x248 y242 w190 h20 w200 vGUIDestination , %Destination%
	Gui, 2: Add, Button, x450 y242 gChooseFolder vGUIChooseFolder h20, ...
	Gui, 2: Add, Button, x515 y242 gChooseAction vGUIChooseAction h20, ...
	Gui, 2: Add, Checkbox, x482 y237 vOverwrite Checked%Overwrite%, Overwrite?
	Gui, 2: Add, Checkbox, x482 y252 vCompress Checked%Compress%, Compress?
	FirstEdit := 1
	GUIAction = %Action%
	Gosub, SetDestination
	Gui, 2: Add, Button, x32 y302 w100 h30 vTestButton gTESTMatches, Test
	Gui, 2: Add, Button, x372 y302 w100 h30 vOKButton gSaveRule, OK
	Gui, 2: Add, Button, x482 y302 w100 h30 vCancelButton gGui2Close, Cancel

	GuiControl, 2: Move, Consequence , % "y" (NumOfRules-1) * 30 + 212
	GuiControl, 2: Move, GUIAction, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, ActionTo, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, GUIDestination, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, GUIChooseFolder,% "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, GUIChooseAction,% "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, Overwrite, % "y" (NumOfRules-1) * 30 + 237
	GuiControl, 2: Move, Compress, % "y" (NumOfRules-1) * 30 + 252
	GuiControl, 2: Move, TestButton, % "y" (NumOfRules-1) * 30 + 302
	GuiControl, 2: Move, OKButton, % "y" (NumOfRules-1) * 30 + 302
	GuiControl, 2: Move, CancelButton, % "y" (NumOfRules-1) * 30 + 302
	Gui, 2: Show, h348 w598, Edit Rule
	Gui, 2: Show, % "h" (NumOfRules-1) * 30 + 348
	Gosub, RefreshVars
	Gosub, ListRules
return

;Destroys the create/edit rule dialog when closed
Gui2Close:
	Gui, 2: Destroy
return

;Changes the options based upon what Subject is selected
SetVerbList:
	LaunchedBy = %A_GuiControl%
	StringRight, GUILineNum, LaunchedBy, 1
	if (GUILineNum = "t")
		GUILineNum =

	GuiControlGet, GUISubject%GUILineNum%, , GUISubject%GUILineNum%
	if (GUISubject%GUILineNum% = "Name") or (GUISubject%GUILineNum% = "Extension")
	{
		GuiControl, 2: ,GUIVerb%GUILineNum%,|%NameVerbs%
		GuiControl, 2: Hide, GUIUnits%GUILineNum%
		GuiControl, 2: Move , GUIObject%GUILineNum% , w140
		GuiControl, 2: -Number, GUIObject%RuleNum%
	}
	else if (GUISubject%GUILineNum% = "Size")
	{
		GuiControl, 2: ,GUIVerb%GUILineNum%,|%NumVerbs%
		GuiControl, 2: Move , GUIObject%GUILineNum% , w70
		GuiControl, 2: +Number, GUIObject%RuleNum%
		GuiControl, 2: ,GUIUnits%GUILineNum%,|%SizeUnits%
		GuiControl, 2: Show, GUIUnits%GUILineNum%
	}
	else if (GUISubject%GUILineNum% = "Date last modified") or (GUISubject%GUILineNum% = "Date last opened") or (GUISubject%GUILineNum% = "Date created")
	{
		GuiControl,,GUIVerb%GUILineNum%,|%DateVerbs%
		GuiControl, 2: Move , GUIObject%GUILineNum% , w70
		GuiControl, 2: +Number, GUIObject%RuleNum%
		GuiControl, 2: ,GUIUnits%GUILineNum%,|%DateUnits%
		GuiControl, 2: Show, GUIUnits%GUILineNum%
	}
return

;Run when the '+' button is clicked to the right of the subject
; this 'pushes' the bottom section down and adds a new subject entry
; to the screen
NewLine:
	if (LineNum = "")
		LineNum := 1

	height := (LineNum * 30) + 152
	Gui, 2: Add, DropDownList, x32 y%height% w160 h20 r6 vGUISubject%LineNum% gSetVerbList , %AllSubjects%
	Gui, 2: Add, DropDownList, x202 y%height% w160 h21 r6 vGUIVerb%LineNum% , %NameVerbs%
	Gui, 2: Add, Edit, x372 y%height% w140 h20 vGUIObject%LineNum% , 
	Gui, 2: Add, DropDownList, x445 y%height% vGUIUnits%LineNum% w60 ,
	GuiControl, 2: Hide, GUIUnits%LineNum%
	Gui, 2: Add, Button, vGUINewLine%LineNum% x515 y%height% w20 h20 gNewLine , + 
	Gui, 2: Add, Button, vGUIRemLine%LineNum% x535 y%height% w20 h20 gRemLine , - 

	; now extend the size of the window
	GuiControl, 2: Move, Consequence , % "y" LineNum * 30 + 212
	GuiControl, 2: Move, GUIAction, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, ActionTo, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, GUIDestination, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, GUIChooseFolder,% "y" LineNum * 30 + 242
	GuiControl, 2: Move, GUIChooseAction,% "y" LineNum * 30 + 242
	GuiControl, 2: Move, Overwrite, % "y" LineNum * 30 + 237
	GuiControl, 2: Move, Compress, % "y" LineNum * 30 + 252
	GuiControl, 2: Move, TestButton, % "y" LineNum * 30 + 302
	GuiControl, 2: Move, OKButton, % "y" LineNum * 30 + 302
	GuiControl, 2: Move, CancelButton, % "y" LineNum * 30 + 302
	Gui, 2: Show, % "h" LineNum * 30 + 348

	LineNum++
	NumOfRules++
return

;Run when the '-' button is clicked to the right of the subject
; this 'hides' the row selected, but it still exists in the code itself
; currently there is no function in AHK to 'destroy' gui elements, so we
; just hide them
RemLine:
	NumOfRules--
	LaunchedBy = %A_GuiControl%
	StringRight, GUILineNum, LaunchedBy, 1
	if (GUILineNum = "e")
		GUILineNum =

	Skip = %Skip%,%GUILineNum%
	GuiControl, 2: Hide, GUISubject%GUILineNum%
	GuiControl, 2: Hide, GUIVerb%GUILineNum%
	GuiControl, 2: Hide, GUIObject%GUILineNum%
	GuiControl, 2: Hide, GUIUnits%GUILineNum%
	GuiControl, 2: Hide, GUINewLine%GUILineNum%
	GuiControl, 2: Hide, GUIRemLine%GUILineNum%
	GuiControl, 2:, GUISubject%GUILineNum%, |
return

;Changes the options based upon what action is selected
SetDestination:
	if !FirstEdit
		GuiControlGet, GUIAction, , GUIAction

	FirstEdit := 0
	if (GUIAction = "Move file") or (GUIAction = "Copy file")
	{
		GuiControl, 2: Show, GUIDestination
		GuiControl, 2: Show, GUIChooseFolder
		GuiControl, 2: Move, GUIDestination, w200
		GuiControl, 2: Hide, GUIChooseAction
		GuiControl, 2: , ActionTo, to folder:
		GuiControl, 2: Show, ActionTo
		GuiControl, 2: Show, Overwrite
		GuiControl, 2: Show, Compress
	}
	else if (GUIAction = "Rename file")
	{
		GuiControl, 2: , ActionTo, to:
		GuiControl, 2: Show, ActionTo
		GuiControl, 2: Show, GUIDestination
		GuiControl, 2: Move, GUIDestination, w200
		GuiControl, 2: Hide, GUIChooseFolder
		GuiControl, 2: Hide, GUIChooseAction
		GuiControl, 2: Hide, Overwrite
		GuiControl, 2: Hide, Compress
	}
	else if (GUIAction = "Open file") or (GUIAction = "Delete file") or (GUIAction = "Send file to Recycle Bin") or (GUIAction = "Print file")
	{
		GuiControl, 2: Hide, ActionTo
		GuiControl, 2: Hide, GUIChooseFolder
		GuiControl, 2: Hide, GUIChooseAction
		GuiControl, 2: Hide, GUIDestination
		GuiControl, 2: Hide, Overwrite
		GuiControl, 2: Hide, Compress
	}
	else if (GUIAction = "Custom")
	{
		GuiControl, 2: , ActionTo, action:
		GuiControl, 2: Show, ActionTo
		GuiControl, 2: Show, GUIDestination
		GuiControl, 2: Move, GUIDestination, w265
		GuiControl, 2: Show, GUIChooseAction
		GuiControl, 2: Hide, GUIChooseFolder
		GuiControl, 2: Hide, Overwrite
		GuiControl, 2: Hide, Compress
	}
return

;Run when the '-' button is clicked under the rule list
; this is responsible for confirming and completing the actual
; delete from the ini file
RemoveRule:
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
	
	Gosub, RefreshVars
	Gosub, ListRules
return

;Run when the 'OK' button is pressed in either a new rule creation
; or a current rule is edited.  This is responsible for checking that the
; rule has proper form and then writes it to the ini file
SaveRule:
	Gui, 2: Submit, NoHide
	if (RuleName = "")
	{
		Msgbox,,Missing Description, You need to write a description for your rule.
		return
	}
	else if RuleName contains |
	{
		Msgbox,,Bad Description, Your description cannot contain the | (pipe) character
		return
	}

	StringReplace, RuleMatchList, AllRuleNames, |,`,,ALL
	if RuleName in %RuleMatchList%
	{
		if !Edit
		{
			Msgbox,,Duplicate Name, A rule with this name already exists. Please rename your rule.
 			return
		}
	}

	if (LineNum = "")
		LineNum := 1

	;Check the structure of the rule to make sure all the important stuff is populated
	Loop
	{
		if (A_Index > LineNum)
			break
		else
			CheckLine := A_Index - 1

		if (CheckLine = 0)
			CheckLine=

		if (GUIObject%CheckLine% = "")
		{
			if Checkline in %Skip%
			{
				;msgbox, you want to skip this one because %checkline% is in %skip%
			}
			else
			{
				Msgbox,,Missing Data, % "You're missing data in one of your " GUISubject%CheckLine% " rules."
				return
			}
		}
		if (GUIDestination = "")
		{
			if (GUIAction = "Move file") or (GUIAction = "Rename file") or (GUIAction = "Copy file")
			{
				Msgbox,,Missing Folder, % "You need to enter a destination folder for the " GUIAction " action."
				return
			}
			else if (GUIAction = "Custom")
			{
				Msgbox,,Missing Custom Action, % "You need to choose an action for the " GUIAction " action."
				return
			}
		}
		else
		{
			IfNotExist, %GUIDestination%
			{
				Msgbox,,Invalid Folder/Action, %GUIDestination% is not a real folder or action.
				return
			}
		}
	}
	
	;If in edit mode, we delete everything in the ini and then recreate it
	if Edit
	{
		IniDelete, rules.ini, %OldName%
		StringReplace, AllRuleNames, AllRuleNames, %OldName%|,,
		StringReplace, RuleNames, RuleNames, %OldName%|,,
	}
	
	Gui, 2: Destroy
	IniWrite, %RuleNames%%RuleName%|, rules.ini, %ActiveFolder%, RuleNames
	IniWrite, %AllRuleNames%%RuleName%|, rules.ini, Rules, AllRuleNames
	IniWrite, %ActiveFolder%\*, rules.ini, %RuleName%, Folder
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

		if (GUISubject%thisLine% != "")
		{
			if (thisLine = "")
				RuleNum =
			else if (RuleNum = "")
				RuleNum := 1
			else
				RuleNum++

			IniWrite, % GUISubject%thisLine%, rules.ini, %RuleName%, Subject%RuleNum%
			IniWrite, % GUIVerb%thisLine%, rules.ini, %RuleName%, Verb%RuleNum%
			IniWrite, % GUIObject%thisLine%, rules.ini, %RuleName%, Object%RuleNum%
			IniWrite, % GUIUnits%thisLine%, rules.ini, %RuleName%, Units%RuleNum%
		}
	}
	
	Log("Rule Saved: " RuleName, "System")
	
	Gosub, RefreshVars
	Gosub, ListRules
return

;Run when the '...' button is clicked to the right of the action section
; this is responsible displaying a selection box and posting it to the rule
; creation screen
ChooseFolder:
	FileSelectFolder, GUIDestination
	GuiControl, 2:, GUIDestination, %GUIDestination%
return

;Run when the '...' button is clicked to the right of the action section
; this is responsible displaying a selection box and posting it to the rule
; creation screen
ChooseAction:
	FileSelectFile, GUIDestination, 3, , Select Custom Action, Programs (*.exe; *.com; *.bat; *.cmd; *.pif; *.vbs)
	GuiControl, 2:, GUIDestination, %GUIDestination%
return

;Run when the 'Save Preferences' button is clicked on the Preferences tab
; writes the information to the ini file
SavePrefs:
	Gui, 1: Submit, NoHide
	SleepTime := Sleep
	SleeptimeLength := SleeptimeLength
	
	;Getting old values for enhanced logging prior to writing new ones
	IniRead, Old_Sleeptime, rules.ini, Preferences, Sleeptime
	IniRead, Old_SleeptimeLength, rules.ini, Preferences, SleeptimeLength
	IniRead, Old_GrowlEnabled, rules.ini, Preferences, GrowlEnabled
	
	IniWrite, %Sleep%, rules.ini, Preferences, Sleeptime
	IniWrite, %SleeptimeLength%, rules.ini, Preferences, SleeptimeLength
	IniWrite, %EnableLogging%, rules.ini, Preferences, EnableLogging
	IniWrite, %LogType%, rules.ini, Preferences, LogType
	IniWrite, %GrowlEnabled%, rules.ini, Preferences, GrowlEnabled
	
	if (EnableLogging = 1)
	{
		if(LogType = "")
		{
			MsgBox,,Missing Logging Type, Please select a logging type
			return
		}
		
		Log("Logging has been enabled with type: " . LogType, "System")
	}
	else if (EnableLogging = 0)
	{
		Log("Logging has been disabled", "System")
	}
	
	Log("Preferences have been saved", "System")
	
	if (Old_Sleeptime <> SleepTime or Old_SleeptimeLength <> SleeptimeLength)
		Log("Preferences - Sleeptime changed from ". Old_Sleeptime . " " . Old_SleeptimeLength . " to " . SleepTime . " " . SleeptimeLength , "System")
	
	if (Old_GrowlEnabled <> GrowlEnabled)
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
	
	if (Old_RBEmptyTimeValue <> RBEmptyTimeValue or Old_RBEmptyTimeLength <> RBEmptyTimeLength)
		Log("Recycle Bin - Sleeptime changed from ". Old_RBEmptyTimeValue . " " . Old_RBEmptyTimeLength . " to " . RBEmptyTimeValue . " " . RBEmptyTimeLength , "System")
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
	Gui, 1: Default
	Gui, 1: ListView, Folders
	LV_Delete()
	Loop, Parse, Folders, |
	{
		SplitPath, A_LoopField, FileName,,,,FileDrive
		;If no name is present we are assuming a root drive
		if (FileName = "")
			LV_Add(0, FileDrive, A_LoopField)
		else
			LV_Add(0, FileName, A_LoopField)
	}
	
	Log("Folder Added: " NewFolder, "System")
	Gosub, RefreshVars
	return
}
