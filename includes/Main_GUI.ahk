MANAGE:
	Gui, 1: Destroy
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
			SplitPath, A_LoopField, FileName
			LV_Add(0, FileName, A_LoopField)
		}
		LV_ModifyCol(1, 171)
		LV_ModifyCol(2, 0)
	}

	Gui, 1: Add, ListView, NoSortHdr x252 y52 w410 h310 vRules gSetActive, Enabled|Rules
	Gui, 1: Add, Button, x62 y382 w30 h30 gAddFolder, +
	Gui, 1: Add, Button, x92 y382 w30 h30 gRemoveFolder, -
	Gui, 1: Add, Button, x252 y382 w30 h30 gAddRule, +
	Gui, 1: Add, Button, x282 y382 w30 h30 gRemoveRule, -
	Gui, 1: Add, Button, x312 y382 h30 vEditRule gEditRule, Edit Rule
	Gui, 1: Add, Button, x620 y382 h30 vEnableButton gEnableButton, Enable
	; Generated using SmartGUI Creator 4.0
	
	;Items found on Second Tab
	IniRead, RBEnable, rules.ini, Preferences, RBEnable, 0
	IniRead, RBEmpty, rules.ini, RecycleBin, RBEmpty, 0
	IniRead, RBEmptyTimeValue, rules.ini, RecycleBin, RBEmptyTimeValue, %A_Space%
	IniRead, RBEmptyTimeLength, rules.ini, RecycleBin, RBEmptyTimeLength, %A_Space%
	StringReplace, thisEmptyTimeLength, NoDefaultDateUnits, %RBEmptyTimeLength%, %RBEmptyTimeLength%|
	
	Gui, 1: Tab, 2
	Gui, 1: Add, Checkbox, x62 y52 w585 vRBEnable gRBEnable Checked%RBEnable%, Allow %APPNAME% to manage my Recycle Bin
	Gui, 1: Add, Checkbox, x100 y100 vRBEmpty Checked%RBEmpty%, Empty my Recycle Bin every
	Gui, 1: Add, Edit, x255 y100 w70 vRBEmptyTimeValue Number, %RBEmptyTimeValue%
	Gui, 1: Add, DropDownList, x325 y100 w60 vRBEmptyTimeLength, %thisEmptyTimeLength%
	Gui, 1: Add, Button, x62 y382 h30 vRBSavePrefs gRBSavePrefs, Save Preferences
	
	GoSub, RBEnable ;Need to Enable/Disable the controls based on first checkbox
	
	;Items found on Third Tab
	IniRead, Sleep, rules.ini, Preferences, Sleeptime, 300000
	IniRead, EnableLogging, rules.ini, Preferences, EnableLogging, 0
	IniRead, LogType, rules.ini, Preferences, LogType, %A_Space%
	StringReplace, thisLogTypes, LogTypes, %LogType%, %LogType%|
	
	Gui, 1: Tab, 3
	Gui, 1: Add, Text, x62 y62 w60 h20 , Sleeptime:
	Gui, 1: Add, Edit, x120 y60 w100 h20 Number vSleep, %Sleep%
	Gui, 1: Add, Text, x225 y62, (Time in milliseconds)
	Gui, 1: Add, Checkbox, x62 y102 vEnableLogging Checked%EnableLogging%, Enable logging for this log type:
	Gui, 1: Add, DropDownList, x232 y102 w60 vLogType, %thisLogTypes%
	Gui, 1: Add, Button, x62 y382 h30 vSavePrefs gSavePrefs, Save Preferences
	Gui, 1: Add, Button, x580 y382 h30 vVerifyConfig gVerifyConfig, Verify Configuration
	
	;Status Bar with the various sections
	Gui, 1: Add, StatusBar
	SB_SetParts(650, 74)
	
	Gui, 1: Show, h463 w724, %APPNAME%
	GoSub, RefreshVars
Return

GuiClose:
	Gui, 1: Destroy
	Gui, 2: Destroy
return

ListRules:
	ActiveRule=
	Gui, 1:Default
	Gui, 1: ListView, Rules
	LV_Delete()
	if (A_EventInfo != 0)
	{
		;msgbox, %a_eventinfo%
		Gui, 1: ListView, Folders
		LV_GetText(ActiveFolder, A_EventInfo, 2)
		CurrentlySelected = %A_eventinfo%
	}

	IniRead, RuleNames, rules.ini, %ActiveFolder%, RuleNames, %A_Space%

	Gui, 1: ListView, Rules
	LV_Delete()
	ListRules := SubStr(RuleNames, 1, -1)
	;msgbox, %listrules%
	Loop, Parse, ListRules, |
	{
		IniRead, Enabled, rules.ini, %A_LoopField%, Enabled, 0

		if (Enabled = 1)
			LV_Add(0,"Yes", A_LoopField)
		else
			LV_Add(0,"No", A_LoopField)
	}
return

SetActive:
	Gui, ListView, Rules

	;Blank out ActiveRule if we get the column headings
	if (A_EventInfo = 0)
	{
		ActiveRule =
	}
	else 
	{
		LV_GetText(ActiveRule, A_EventInfo, 2)
	}
	
	;Change the button based on the selected rule's enable status
	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled, 0
	If (Enabled = 1)
	{
		GuiControl, 1:, EnableButton, Disable
	}
	else
	{
		GuiControl, 1:, EnableButton, Enable
	}
return

EnableButton:
	; make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox, Please select a rule to enable/disable.
		return
	}

	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled, 0
	If (Enabled = 1)
	{
		IniWrite, 0, rules.ini, %ActiveRule%, Enabled
	}
	else
	{
		IniWrite, 1, rules.ini, %ActiveRule%, Enabled
	}
	Gosub, ListRules
return

AddFolder:
	FileSelectFolder, NewFolder,
	if (NewFolder = "")
	{
		return
	}

	SaveFolders(NewFolder, Folders)
return

RemoveFolder:
	if (CurrentlySelected = "")
	{
		Msgbox, Select the folder you'd like to delete.
		return
	}
	MsgBox, 4, Delete Folder, Are you sure you would like to delete the folder "%ActiveFolder%" ?
	IfMsgBox No
		return
	Gui, 1: Default
	Gui, ListView, Folders
	LV_GetText(RemoveFolder, CurrentlySelected, 2)
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	success := LV_Delete()
	StringReplace, Folders, Folders, %RemoveFolder%|,,
	IniWrite, %Folders%, rules.ini, Folders, Folders
	IniRead, RuleNames, rules.ini, %RemoveFolder%, RuleNames
	Loop, Parse, RuleNames, |
	{
		if (A_LoopField != "")
		{
			StringReplace, AllRuleNames, AllRuleNames, %A_LoopField%|,,
			IniDelete, rules.ini, %A_LoopField%
		}
	}
	IniWrite, %AllRuleNames%, rules.ini, Rules, AllRuleNames
	IniDelete, rules.ini, %RemoveFolder%
	Gosub, RefreshVars

	;msgbox, %success%
	Loop, Parse, Folders, |
	{
		SplitPath, A_LoopField, FileName
		LV_Add(0, FileName, A_LoopField)
	}
	
	Log("Folder Removed: " CurrentlySelected, "System")
	
	Gosub, ListRules
return

AddRule:
	Skip=
	Edit := 0 ; this is a new rule, not a rule being edited
	LineNum=
	NumOfRules := 1
	if (CurrentlySelected = "")
	{
		MsgBox, You must select a folder to create a rule
		return
	}
	Gui, ListView, Folders
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	LV_GetText(FolderName, CurrentlySelected, 3)
	Gui, 2: Destroy
	Gui, 2: +owner1
	Gui, 2: +toolwindow
	Gui, 2: Add, Text, x52 y32 h20 , Folder: %ActiveFolder%
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
	Gui, 2: Add, Edit, x248 y242 w190 h20 vGUIDestination , 
	Gui, 2: Add, Button, x450 y242 gChooseFolder vGUIChooseFolder h20, ...
	Gui, 2: Add, Checkbox, x482 y242 vOverwrite, Overwrite?
	Gui, 2: Add, Button, x32 y302 w100 h30 vTestButton gTESTMatches, Test
	Gui, 2: Add, Button, x372 y302 w100 h30 vOKButton gSaveRule, OK
	Gui, 2: Add, Button, x482 y302 w100 h30 vCancelButton gGui2Close, Cancel
	; Generated using SmartGUI Creator 4.0
	Gui, 2: Show, h348 w598, Create a rule...
	Gosub, RefreshVars
	Gosub, ListRules
Return

EditRule:
	Skip = 
	Edit := 1
	
	;make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox, Please select a rule to edit.
		return
	}
	OldName = %ActiveRule%
	
	;find out how many conditions a rule has
	NumOfRules := 1
	Loop 
	{
		IniRead, MultiRule, rules.ini, %ActiveRule%, Subject%A_Index%
		if (MultiRule != "ERROR")
		{
			NumOfRules++ 
		}
		else
		{
			break
		}
	}
	;msgbox, %numofrules%
	
	;TK Start HERE to complete the editing rule features	
	;msgbox, %thisRule% has %Numofrules% rules
	IniRead, Folder, rules.ini, %ActiveRule%, Folder, %A_Space%
	IniRead, Action, rules.ini, %ActiveRule%, Action, %A_Space%
	IniRead, Destination, rules.ini, %ActiveRule%, Destination, %A_Space%
	IniRead, Overwrite, rules.ini, %ActiveRule%, Overwrite, 0
	IniRead, Matches, rules.ini, %ActiveRule%, Matches, %A_Space%
	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled, 0
	IniRead, ConfirmAction, rules.ini, %ActiveRule%, ConfirmAction, 0
	IniRead, Recursive, rules.ini, %ActiveRule%, Recursive, 0
	Gui, 2: Destroy
	Gui, 2: +owner1
	Gui, 2: +toolwindow
	Gui, 2: Add, Text, x52 y32 h20 , Folder: %ActiveFolder%
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
	
	; this loop creates the controls for all of the conditions in the rule
	height =
	LineNum =
	Loop
	{
		if ((A_Index-1) = NumOfRules)
		{
			break
		}
		if (A_Index = 1)
		{
			RuleNum =
		}
		else
		{
			RuleNum := A_Index - 1
		}
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
		;defaultObject = % Object%RuleNum% "|"
		defaultUnit = % Units%RuleNum% "|"
		StringReplace, RuleSubject, NoDefaultSubject, %defaultSubject%, %defaultSubject%|
		
		; verbs need to be set by subject b/c verbs change by subject
		;msgbox, %defaultSubject%
		if (defaultSubject = "Name|") or (defaultSubject = "Extension|")
		{
			NoDefaultVerbs = %NoDefaultNameVerbs%
		}
		else if (defaultSubject = "Size|")
		{
			NoDefaultVerbs = %NoDefaultNumVerbs%
		}
		else if (defaultSubject = "Date last modified|") or (defaultSubject = "Date last opened|") or (defaultSubject = "Date created|")
		{
			NoDefaultVerbs = %NoDefaultDateVerbs%
		}
		StringReplace, RuleVerb, NoDefaultVerbs, %defaultVerb%, %defaultVerb%|

		;msgbox, % subject%rulenum% " translates to " rulesubject
		Gui, 2: Add, DropDownList, x32 y%height% w160 h20 r6 vGUISubject%RuleNum% gSetVerbList , %RuleSubject%
		Gui, 2: Add, DropDownList, x202 y%height% w160 h21 r6 vGUIVerb%RuleNum% , %RuleVerb%
		Gui, 2: Add, Edit, x372 y%height% w140 h20 vGUIObject%RuleNum% , % Object%RuleNum%
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
		;msgbox, %defaultunit%
		StringReplace, RuleUnits, NoDefaultUnits, %defaultUnit%, %defaultUnit%|
		;msgbox, %ruleunits%
		Gui, 2: Add, DropDownList, x445 y%height% vGUIUnits%RuleNum% w60 , %RuleUnits%
		if (defaultSubject = "Name|") or (defaultSubject = "Extension|")
		{
			GuiControl, 2: Hide, GUIUnits%RuleNum%
		}
		Gui, 2: Add, Button, vGUINewLine%RuleNum% x515 y%height% w20 h20 gNewLine , +
		if (RuleNum != "")
		{
			Gui, 2: Add, Button, vGUIRemLine%RuleNum% x535 y%height% w20 h20 gRemLine , -
		}
		LineNum++
	}	
	ActionHeight :=
	Gui, 2: Add, Text, x32 y212 w260 h20 vConsequence , Do the following:
	StringReplace, RuleAction, AllActionsNoDefault, %Action%, %Action%|
	;msgbox, %RuleAction%
	Gui, 2: Add, DropDownList, x32 y242 w160 h20 vGUIAction gSetDestination r6 , %RuleAction%
	Gui, 2: Add, Text, x202 y242 h20 w45 vActionTo , to folder:
	Gui, 2: Add, Edit, x248 y242 w190 h20 vGUIDestination , %Destination%
	Gui, 2: Add, Button, x450 y242 gChooseFolder vGUIChooseFolder h20, ...
	Gui, 2: Add, Checkbox, x482 y242 vOverwrite Checked%Overwrite%, Overwrite?
	FirstEdit := 1
	GUIAction = %Action%
	Gosub, SetDestination
	Gui, 2: Add, Button, x32 y302 w100 h30 vTestButton gTESTMatches, Test
	Gui, 2: Add, Button, x372 y302 w100 h30 vOKButton gSaveRule, OK
	Gui, 2: Add, Button, x482 y302 w100 h30 vCancelButton gGui2Close, Cancel
	; Generated using SmartGUI Creator 4.0
	GuiControl, 2: Move, Consequence , % "y" (NumOfRules-1) * 30 + 212
	GuiControl, 2: Move, GUIAction, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, ActionTo, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, GUIDestination, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, GUIChooseFolder,% "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, Overwrite, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, TestButton, % "y" (NumOfRules-1) * 30 + 302
	GuiControl, 2: Move, OKButton, % "y" (NumOfRules-1) * 30 + 302
	GuiControl, 2: Move, CancelButton, % "y" (NumOfRules-1) * 30 + 302
	Gui, 2: Show, h348 w598, Create a rule...
	Gui, 2: Show, % "h" (NumOfRules-1) * 30 + 348
	Gosub, RefreshVars
	Gosub, ListRules
return

Gui2Close:
	Gui, 2: Destroy
return

SetVerbList:
	LaunchedBy = %A_GuiControl%
	StringRight, GUILineNum, LaunchedBy, 1
	if (GUILineNum = "t")
	{
		GUILineNum =
	}
	;Msgbox, %GUILineNum%
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
		;ControlMove, GUIObject,,,70,,
		GuiControl, 2: ,GUIUnits%GUILineNum%,|%SizeUnits%
		GuiControl, 2: Show, GUIUnits%GUILineNum%
	}
	else if (GUISubject%GUILineNum% = "Date last modified") or (GUISubject%GUILineNum% = "Date last opened") or (GUISubject%GUILineNum% = "Date created")
	{
		GuiControl,,GUIVerb%GUILineNum%,|%DateVerbs%
		GuiControl, 2: Move , GUIObject%GUILineNum% , w70
		GuiControl, 2: +Number, GUIObject%RuleNum%
		GuiControl, 2: ,GUIUnits%GUILineNum%,|%DateUnits%
		;GuiControl, 2: +r4, GUIUnits
		GuiControl, 2: Show, GUIUnits%GUILineNum%
	}
return

NewLine:
	;msgbox add a new line?!
	if (LineNum = "")
	{
		LineNum := 1
	}
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
	GuiControl, 2: Move, Overwrite, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, TestButton, % "y" LineNum * 30 + 302
	GuiControl, 2: Move, OKButton, % "y" LineNum * 30 + 302
	GuiControl, 2: Move, CancelButton, % "y" LineNum * 30 + 302
	Gui, 2: Show, % "h" LineNum * 30 + 348

	LineNum++
	NumOfRules++
return

RemLine:
	NumOfRules--
	LaunchedBy = %A_GuiControl%
	StringRight, GUILineNum, LaunchedBy, 1
	if (GUILineNum = "e")
	{
		GUILineNum =
	}
	Skip = %Skip%,%GUILineNum%
	;msgbox, %guilinenum% 
	GuiControl, 2: Hide, GUISubject%GUILineNum%
	GuiControl, 2: Hide, GUIVerb%GUILineNum%
	GuiControl, 2: Hide, GUIObject%GUILineNum%
	GuiControl, 2: Hide, GUIUnits%GUILineNum%
	GuiControl, 2: Hide, GUINewLine%GUILineNum%
	GuiControl, 2: Hide, GUIRemLine%GUILineNum%
	;GuiControl, 2: Hide, GUIUnits%GUILineNum%
	GuiControl, 2:, GUISubject%GUILineNum%, |
return

SetDestination:
	if !FirstEdit
	{
		GuiControlGet, GUIAction, , GUIAction
	}
	FirstEdit := 0
	if (GUIAction = "Move file") or (GUIAction = "Copy file")
	{
		GuiControl, 2: Show, GUIDestination
		GuiControl, 2: Show, GUIChooseFolder
		GuiControl, 2: , ActionTo, to folder:
		GuiControl, 2: Show, ActionTo
		GuiControl, 2: Show, Overwrite
	}
	else if (GUIAction = "Rename file")
	{
		GuiControl, 2: , ActionTo, to:
		GuiControl, 2: Show, ActionTo
		GuiControl, 2: Show, GUIDestination
		GuiControl, 2: Hide, GUIChooseFolder
		GuiControl, 2: Hide, Overwrite
	}
	else if (GUIAction = "Open file") or (GUIAction = "Delete file") or (GUIAction = "Send file to Recycle Bin")
	{
		GuiControl, 2: Hide, ActionTo
		GuiControl, 2: Hide, GUIChooseFolder
		GuiControl, 2: Hide, GUIDestination
		GuiControl, 2: Hide, Overwrite
	}
return

RemoveRule:
	;msgbox, %ActiveRule%
	if (ActiveRule = "")
	{
		MsgBox, Please select a rule to delete.
		return
	}
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

SaveRule:
	Gui, 2: Submit, NoHide
	;MsgBox, LineNum: %LineNum%
	if (RuleName = "")
	{
		Msgbox, You need to write a description for your rule.
		return
	}
	else if RuleName contains |
	{
		Msgbox, Your description cannot contain the | (pipe) character
		return
	}
	StringReplace, RuleMatchList, AllRuleNames, |,`,,ALL
	;msgbox, Edit: %Edit%
	if RuleName in %RuleMatchList%
	{
		if !Edit
		{
			Msgbox, A rule with this name already exists. Please rename your rule.
 			return
		}
	}

	if (LineNum = "")
	{
		LineNum := 1
	}
	Loop
	{
		if (A_Index > LineNum)
		{
			;msgbox, bigger
			break
		}
		else
		{
			CheckLine := A_Index - 1
		}
		if (CheckLine = 0)
		{
			CheckLine=
		}
		if (GUIObject%CheckLine% = "")
		{
			if Checkline in %Skip%
			{
				;msgbox, you want to skip this one because %checkline% is in %skip%
			}
			else
			{
				Msgbox, % "You're missing data in one of your " GUISubject%CheckLine% " rules."
				return
			}
		}
		if (GUIDestination = "")
		{
			if (GUIAction = "Move file") or (GUIAction = "Rename file") or (GUIAction = "Copy file")
			{
				Msgbox, % "You need to enter a destination folder for the " GUIAction " action."
				return
				; %
			}
		}
		else
		{
			IfNotExist, %GUIDestination%
			{
				Msgbox, %GUIDestination% is not a real folder.
				return
			}
		}
	}
	
	if Edit
	{
		IniDelete, rules.ini, %OldName%
		StringReplace, AllRuleNames, AllRuleNames, %OldName%|,,
		StringReplace, RuleNames, RuleNames, %OldName%|,,
		;msgbox, allrulenames: %allrulenames% - rulenames: %rulenames%
	}
	
	Gui, 2: Destroy
	;MsgBox, %LineNum%
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
	}
	
	;save the rest of the subject combos
	Loop
	{
		if (A_Index = 1)
		{
			thisLine =
		}
		else
		{
			thisLine := A_Index - 1
		}
		;msgbox, %thisline%
		if (A_Index > LineNum)
		{
			;msgbox, break
			break
		}
		;msgbox, % guisubject%thisline%
		if (GUISubject%thisLine% != "")
		{
			if (thisLine = "")
			{
				RuleNum =
				;msgbox, RuleNum = %rulenum%
			}
			else if (RuleNum = "")
			{
				RuleNum := 1
				;msgbox, RuleNum = %rulenum%
			}
			else
			{
				RuleNum++
				;msgbox, RuleNum = %rulenum%
			}
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

ChooseFolder:
	FileSelectFolder, GUIDestination
	GuiControl, 2:, GUIDestination, %GUIDestination%
return

SavePrefs:
	Gui, 1: Submit, NoHide
	SleepTime := Sleep
	IniWrite, %Sleep%, rules.ini, Preferences, Sleeptime
	IniWrite, %EnableLogging%, rules.ini, Preferences, EnableLogging
	IniWrite, %LogType%, rules.ini, Preferences, LogType
	if (EnableLogging = 1)
	{
		if(LogType = "")
		{
			MsgBox, Please select a logging type
			return
		}
		
		Log("Logging has been enabled with type: " . LogType, "System")
	}
	else if (EnableLogging = 0)
	{
		Log("Logging has been disabled", "System")
	}
	
	Log("Preferences have been saved", "System")
	MsgBox,,Saved Settings, Your settings have been saved.
return

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

	IniWrite, %RBEmpty%, rules.ini, RecycleBin, RBEmpty
	IniWrite, %RBEmptyTimeValue%, rules.ini, RecycleBin, RBEmptyTimeValue
	IniWrite, %RBEmptyTimeLength%, rules.ini, RecycleBin, RBEmptyTimeLength

	Log("Recycle Bin - Preferences have been saved", "System")
	MsgBox,,Saved Settings, Your settings have been saved.
return

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

#IfWinActive, Belvedere
~LButton::
	MouseGetPos,,,,ClickedControl
	;msgbox, %ClickedControl%
	if (ClickedControl = "SysListView321") or (ClickedControl = "SysListView322")
	{
		;msgbox, this one
		Sleep, 10
		Click 2
	}
return

RefreshVars:
	IniRead, Folders, rules.ini, Folders, Folders
	IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames
		
	ListFolders := SubStr(Folders, 1, -1)
	FolderCount :=
	Loop, Parse, ListFolders, |
	{
		FolderCount++
	}
	
	ListRules := SubStr(AllRuleNames, 1, -1)
	RuleCount :=
	Loop, Parse, ListRules, |
	{
		RuleCount++
	}
	SB_SetText(APPNAME . " is currently managing " . FolderCount . " folders with " . RuleCount .  " total rules" , 1)
return

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
		SplitPath, A_LoopField, FileName
		LV_Add(0, FileName, A_LoopField)
	}
	
	Log("Folder Added: " NewFolder, "System")
	Gosub, RefreshVars
	return
}
