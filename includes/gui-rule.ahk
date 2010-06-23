;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows
; Author:         Adam Pash <adam.pash@gmail.com>
; Contributor:	  Matthew Shorts <mshorts@gmail.com>
;
; Script Name:	  gui-rule.ahk
;
; This script is the rule gui portion of the application.  It also has all the logic
;  to create and edit rules and their corresponding characteristics
;
; Some portions Generated using SmartGUI Creator 4.0 

;This is the rule GUI screen with the rule name, subjects and verbs
;  This window is always identified by Gui, 2

;Run when the '+' button is clicked under the rule list
; only the GUI creation of the rule process, saving is handled in
; SaveRule procedure below
AddRule:
	Gui, 1: +OwnDialogs
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
	Gui, 1: ListView, Folders
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	LV_GetText(FolderName, CurrentlySelected, 3)
	
	IniRead, Default_Enabled, rules.ini, Preferences, Default_Enabled, 0
	IniRead, Default_ConfirmAction, rules.ini, Preferences, Default_ConfirmAction, 0
	IniRead, Default_Recursive, rules.ini, Preferences, Default_Recursive, 0
	
	;Create a new 'Create a rule...' dialog box with base settings
	Gui, 2: Destroy
	Gui, 2: +owner1
	Gui, 2: +toolwindow
	Gui, 2: Add, Text, x52 y32 h20 vFolderPath, Folder: %ActiveFolder%
	Gui, 2: Add, Text, x32 y62 w60 h20 , Description:
	Gui, 2: Add, Edit, x92 y62 w250 h20 vRuleName , 
	Gui, 2: Add, Checkbox, x448 y30 vEnabled Checked%Default_Enabled%, Enabled
	Gui, 2: Add, Checkbox, x448 y50 vConfirmAction Checked%Default_ConfirmAction%, Confirm Action
	Gui, 2: Add, Checkbox, x448 y70 vRecursive Checked%Default_Recursive%, Recursive
	Gui, 2: Add, Groupbox, x443 y10 w110 h80, Rule Options
	Gui, 2: Add, Text, x32 y92 w520 h20 , __________________________________________________________________________________________
	Gui, 2: Add, Text, x32 y122 w10 h20 , If
	Gui, 2: Add, DropDownList, x45 y120 w46 h20 r2 vMatches , ALL||ANY
	Gui, 2: Add, Text, x96 y122 w240 h20 , of the following conditions are met:
	Gui, 2: Add, DropDownList, x32 y152 w160 h20 r6 vGUISubject gSetVerbList , %AllSubjects%
	Gui, 2: Add, DropDownList, x202 y152 w160 h21 r8 vGUIVerb , %NameVerbs%
	Gui, 2: Add, Edit, x372 y152 w140 h20 vGUIObject , 
	Gui, 2: Add, DropDownList, x445 y152 vGUIUnits w60 ,
	GuiControl, 2: Hide, GUIUnits
	Gui, 2: Add, Button, vGUINewLine x515 y152 w20 h20 gNewLine , +
	Gui, 2: Add, Text, x32 y202 vExclusions, Exclude files with any of these attributes:
	Gui, 2: Add, Checkbox, x248 y202 vAttribReadOnly, Read Only
	Gui, 2: Add, Checkbox, x328 y202 vAttribHidden, Hidden
	Gui, 2: Add, Checkbox, x388 y202 vAttribSystem, System
	Gui, 2: Add, Text, x32 y222 w260 h20 vConsequence , Do the following:
	Gui, 2: Add, DropDownList, x32 y242 w160 h20 r10 vGUIAction gSetDestination , %AllActions%
	Gui, 2: Add, Text, x202 y242 h20 w45 vActionTo , to folder:
	Gui, 2: Add, Edit, x248 y242 w190 h20 w200 vGUIDestination , 
	Gui, 2: Add, Button, x450 y242 gChooseFolder vGUIChooseFolder h20, ...
	Gui, 2: Add, Button, x515 y242 gChooseAction vGUIChooseAction h20, ...
	GuiControl, 2: Hide, GUIChooseAction
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

	Gui, 1: +Disabled
	Gui, 2: Show, h348 w598, Create a rule...
	Gosub, RefreshVars
	Gosub, ListRules
Return

;Run when the 'Edit' button is clicked under the rule list
; only the GUI creation of the rule process and population with the 
; current rule settings, saving is handled in SaveRule procedure below
EditRule:
	Gui, 1: +OwnDialogs
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
	IniRead, AttribReadOnly, rules.ini, %ActiveRule%, AttribReadOnly, 0
	IniRead, AttribHidden, rules.ini, %ActiveRule%, AttribHidden, 0
	IniRead, AttribSystem, rules.ini, %ActiveRule%, AttribSystem, 0
	
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
		Gui, 2: Add, DropDownList, x202 y%height% w160 h21 r8 vGUIVerb%RuleNum% , %RuleVerb%
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
	Gui, 2: Add, Text, x32 y202 vExclusions, Exclude files with any of these attributes:
	Gui, 2: Add, Checkbox, x248 y202 Checked%AttribReadOnly% vAttribReadOnly, Read Only
	Gui, 2: Add, Checkbox, x328 y202 Checked%AttribHidden% vAttribHidden, Hidden
	Gui, 2: Add, Checkbox, x388 y202 Checked%AttribSystem% vAttribSystem, System
	Gui, 2: Add, Text, x32 y222 w260 h20 vConsequence , Do the following:
	StringReplace, RuleAction, AllActionsNoDefault, %Action%, %Action%|

	Gui, 2: Add, DropDownList, x32 y242 w160 h20 r10 vGUIAction gSetDestination , %RuleAction%
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

	GuiControl, 2: Move, Exclusions,  % "y" (NumOfRules-1) * 30 + 202
	GuiControl, 2: Move, AttribReadOnly,  % "y" (NumOfRules-1) * 30 + 202
	GuiControl, 2: Move, AttribHidden,  % "y" (NumOfRules-1) * 30 + 202
	GuiControl, 2: Move, AttribSystem,  % "y" (NumOfRules-1) * 30 + 202
	GuiControl, 2: Move, Consequence , % "y" (NumOfRules-1) * 30 + 222
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
	
	Gui, 1: +Disabled
	Gui, 2: Show, h348 w598, Edit Rule
	Gui, 2: Show, % "h" (NumOfRules-1) * 30 + 348
	Gosub, RefreshVars
	Gosub, ListRules
return

;Destroys the create/edit rule dialog when closed
Gui2Close:
	Gui, 1: -Disabled
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
	Gui, 2: Add, DropDownList, x202 y%height% w160 h21 r8 vGUIVerb%LineNum% , %NameVerbs%
	Gui, 2: Add, Edit, x372 y%height% w140 h20 vGUIObject%LineNum% , 
	Gui, 2: Add, DropDownList, x445 y%height% vGUIUnits%LineNum% w60 ,
	GuiControl, 2: Hide, GUIUnits%LineNum%
	Gui, 2: Add, Button, vGUINewLine%LineNum% x515 y%height% w20 h20 gNewLine , + 
	Gui, 2: Add, Button, vGUIRemLine%LineNum% x535 y%height% w20 h20 gRemLine , - 

	; now extend the size of the window
	GuiControl, 2: MoveDraw, Exclusions,  % "y" LineNum * 30 + 202
	GuiControl, 2: MoveDraw, AttribReadOnly,  % "y" LineNum * 30 + 202
	GuiControl, 2: MoveDraw, AttribHidden,  % "y" LineNum * 30 + 202
	GuiControl, 2: MoveDraw, AttribSystem,  % "y" LineNum * 30 + 202
	GuiControl, 2: MoveDraw, Consequence , % "y" LineNum * 30 + 222
	GuiControl, 2: MoveDraw, GUIAction, % "y" LineNum * 30 + 242
	GuiControl, 2: MoveDraw, ActionTo, % "y" LineNum * 30 + 242
	GuiControl, 2: MoveDraw, GUIDestination, % "y" LineNum * 30 + 242
	GuiControl, 2: MoveDraw, GUIChooseFolder,% "y" LineNum * 30 + 242
	GuiControl, 2: MoveDraw, GUIChooseAction,% "y" LineNum * 30 + 242
	GuiControl, 2: MoveDraw, Overwrite, % "y" LineNum * 30 + 237
	GuiControl, 2: MoveDraw, Compress, % "y" LineNum * 30 + 252
	GuiControl, 2: MoveDraw, TestButton, % "y" LineNum * 30 + 302
	GuiControl, 2: MoveDraw, OKButton, % "y" LineNum * 30 + 302
	GuiControl, 2: MoveDraw, CancelButton, % "y" LineNum * 30 + 302
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
	if (GUIAction = "Move file") or (GUIAction = "Copy file") or (GuiAction = "Move file & leave shortcut")
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
	Loop
	{
		;If we didnt' change rule name, no need to check for matches
		if (RuleName == OldName)
			break
		
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
			if Checkline not in %Skip%
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
		else if (GUIAction != "Rename file")
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
	
	Gui, 1: -Disabled
	Gui, 2: Destroy
	IniWrite, %RuleNames%%RuleName%|, rules.ini, %ActiveFolder%, RuleNames
	IniWrite, %AllRuleNames%%RuleName%|, rules.ini, Rules, AllRuleNames
	IniWrite, %ActiveFolder%\*, rules.ini, %RuleName%, Folder
	IniWrite, %Enabled%, rules.ini, %RuleName%, Enabled
	IniWrite, %ConfirmAction%, rules.ini, %RuleName%, ConfirmAction
	IniWrite, %Recursive%, rules.ini, %RuleName%, Recursive
	IniWrite, %Matches%, rules.ini, %RuleName%, Matches
	IniWrite, %GUIAction%, rules.ini, %RuleName%, Action
	IniWrite, %AttribReadOnly%, rules.ini, %RuleName%, AttribReadOnly
	IniWrite, %AttribHidden%, rules.ini, %RuleName%, AttribHidden
	IniWrite, %AttribSystem%, rules.ini, %RuleName%, AttribSystem
	
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
	Notify("Rule Saved: " RuleName, "System")
	
	Gosub, RefreshVars
	Gosub, ListRules
return

;Run when the '...' button is clicked to the right of the action section
; this is responsible displaying a selection box and posting it to the rule
; creation screen
ChooseFolder:
	Gui, 2: +OwnDialogs
	IniRead, LastFolder, rules.ini, Preferences, LastFolder, %A_Desktop%
	FileSelectFolder, GUIDestination, %LastFolder%, 3, Please select a destination
	GuiControl, 2:, GUIDestination, %GUIDestination%
	if (GUIDestination != "")
	{
		NewLastFolder := A_Desktop " *" GUIDestination
		IniWrite, %NewLastFolder%, rules.ini, Preferences, LastFolder
	}
return

;Run when the '...' button is clicked to the right of the action section
; this is responsible displaying a selection box and posting it to the rule
; creation screen
ChooseAction:
	Gui, 2: +OwnDialogs
	FileSelectFile, GUIDestination, 3, , Select Custom Action, Programs (*.exe; *.com; *.bat; *.cmd; *.pif; *.vbs)
	GuiControl, 2:, GUIDestination, %GUIDestination%
return
