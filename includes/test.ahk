TESTMatches:
	matchFiles =
	Gui, 2: Submit, NoHide
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
	if (LineNum = "")
	{
		LineNum := 1
	}
	
	; set variables to the active folder and match type (ALL OR ANY) 
	; for testing below
	Folder = %ActiveFolder%\*
	Matches = %Matches%
	
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
			
			; set the test variables for rules
			Subject%thisLine% = % GUISubject%RuleNum%
			Verb%thisLine% = % GUIVerb%RuleNum%
			Object%thisLine% = % GUIObject%RuleNum%
			Units%thisLine% = % GUIUnits%RuleNum%
			
			;msgbox, % subject%thisLine%
			;msgbox, %folder%
			;msgbox, %matches%
			;msgbox % object%thisLine%
		}
	}
	
	; Now loop through the folder to test for matches
	Loop %Folder%, 0, %Recursive%
	{
		Loop
		{
			if ((A_Index - 1) = NumOfRules)
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
			;msgbox, % subject subject1 subject2
			file = %A_LoopFileLongPath%
			;MsgBox, %file%
			fileName = %A_LoopFileName%
			;msgbox, % subject%rulenum%
			; Below determines the subject of the comparison
			if (Subject%RuleNum% = "Name")
			{
				thisSubject := getName(file)
				;msgbox, name %file%
			}
			else if (Subject%RuleNum% = "Extension")
			{
				thisSubject := getExtension(file)
				;Msgbox, extension: %thissubject%
			}
			else if (Subject%RuleNum% = "Size")
			{
				thisSubject := getSize(file)
				;msgbox, size %thissubject%
			}
			else if (Subject%RuleNum% = "Date last modified")
			{
				thisSubject := getDateLastModified(file)
			}
			else if (Subject%RuleNum% = "Date last opened")
			{
				thisSubject := getDateLastOpened(file)
			}
			else if (Subject%RuleNum% = "Date created")
			{
				thisSubject := getDateCreated(file)
			}
			else
			{
				MsgBox, Subject does not have a match
				;msgbox, % subject %rulenum%
			}
			
			testUnits = % Units%RuleNum%
			; Below determines the comparison verb
			if (Verb%RuleNum% = "contains")
			{
				result%RuleNum% := contains(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "does not contain")
			{
				result%RuleNum% := !(contains(thisSubject, Object%RuleNum%))
			}
			else if (Verb%RuleNum% = "is")
			{
				result%RuleNum% := isEqual(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "matches one of")
			{
				result%RuleNum% := isOneOf(thisSubject, Object%RuleNum%)
				;msgbox, % result%rulenum% . "is rule" . rulenum
			}
			else if (Verb%RuleNum% = "does not match one of")
			{
				result%RuleNum% := !(isOneOf(thisSubject, Object%RuleNum%))
				;msgbox, % result%rulenum% . "is rule" . rulenum
			}
			else if (Verb%RuleNum% = "is less than")
			{
				result%RuleNum% := isLessThan(thisSubject, Object%RuleNum%)
				;msgbox, % result%rulenum%
			}
			else if (Verb%RuleNum% = "is greater than")
			{
				result%RuleNum% := isGreaterThan(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "is not")
			{
				result%RuleNum% := !(isEqual(thisSubject, Object%RuleNum%))
			}
			else if (Verb%RuleNum% = "is in the last")
			{
				result%RuleNum% := isInTheLast(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "is not in the last")
			{
				result%RuleNum% := !(isInTheLast(thisSubject, Object%RuleNum%))
			}
		}
		; Below evaluates result and takes action
		Loop
		{
			;msgbox, %a_index%
			if (NumOfRules < A_Index)
			{
				;msgbox, over
				break
			}
			if (A_Index = 1)
			{
				RuleNum=
			}
			else
			{
				RuleNum := A_Index - 1
			}
			;msgbox, % result%rulenum% . "is rule " . rulenum
			if (Matches = "ALL")
			{
				if (result%RuleNum% = 0)
				{
					result := 0
					break
				}
				else
				{
					result := 1
					continue
				}
			}
			else if (Matches = "ANY")
			{
				if (result%RuleNum% = 1)
				{
					result := 1
					;msgbox, 1
					break
				}
				else
				{
					result := 0
					continue
				}
			}
		}
		;msgbox, %result%
		;Msgbox, result is %result%
		if result
		{
			;Msgbox, match %fileName%
			matchFiles = %fileName%, %matchFiles%
		}
	}
	
	if (matchFiles != "")
	{
		Msgbox,,%APPNAME% Test Matches, This rule matches the following file(s): `n %matchFiles%
	}
	else
	{
		Msgbox,,%APPNAME% Test Matches, No matches were found
	}
return