;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows
; Author:         Adam Pash <adam.pash@gmail.com>
;
; Script Function:
;	Automated file manager
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
StringCaseSense, On
SetFormat, float, 0.2
GoSub, SetVars
GoSub, TRAYMENU
GoSub, MENUBAR
Gosub, BuildINI
SetTimer, emptyRB, Off
IniRead, Folders, rules.ini, Folders, Folders, %A_Space%
IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames, %A_Space%
IniRead, SleepTime, rules.ini, Preferences, SleepTime, 300000
IniRead, EnableLogging, rules.ini, Preferences, EnableLogging, 0
IniRead, LogType, rules.ini, Preferences, LogType, %A_Space%

Log("Starting " . APPNAME . " " . Version, "System")

;main execution loop
Loop
{
	;msgbox, running
	;Loops through all the rule names for execution
	Loop, Parse, AllRuleNames, |
	{
		thisRule = %A_LoopField%
		;msgbox, %thisrule%
		NumOfRules := 1
		;Loops to determine number of subjects within a rule
		Loop
		{
			IniRead, MultiRule, rules.ini, %thisRule%, Subject%A_Index%
			if (MultiRule != "ERROR")
			{
				NumOfRules++ 
			}
			else
			{
				break
			}
		}
		if (thisRule = "ERROR") or (thisRule = "")
		{
			continue
		}
		;msgbox, %thisRule% has %Numofrules% rules
		IniRead, Folder, rules.ini, %thisRule%, Folder, %A_Space%
		IniRead, Enabled, rules.ini, %thisRule%, Enabled, 0
		IniRead, ConfirmAction, rules.ini, %thisRule%, ConfirmAction, 0
		IniRead, Recursive, rules.ini, %thisRule%, Recursive, 0
		IniRead, Action, rules.ini, %thisRule%, Action, %A_Space%
		IniRead, Destination, rules.ini, %thisRule%, Destination, %A_Space%
		IniRead, Matches, rules.ini, %thisRule%, Matches, %A_Space%
		
		;If rule is not enabled, just skip over it
		if (Enabled = 0)
		{
			continue
		}
		;MsgBox, %thisRule% is currently running
		;Loop to read the subjects, verbs and objects for the list defined
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
			IniRead, Subject%RuleNum%, rules.ini, %thisRule%, Subject%RuleNum%
			IniRead, Verb%RuleNum%, rules.ini, %thisRule%, Verb%RuleNum%
			IniRead, Object%RuleNum%, rules.ini, %thisRule%, Object%RuleNum%
		}
		;msgbox, %subject%, %subject1%, %subject2%
		if (Destination != "")
		{
			IniRead, Overwrite, rules.ini, %thisRule%, Overwrite, 0
		}
		
		;Msgbox, %Subject% %Verb% %Object% %Action% %ConfirmAction% %Recursive%

		;Loop through all of the folder contents
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
				;Subject1 = Fart
				;msgbox, % subject%rulenum%
				; Below determines the subject of the comparison
				if (Subject%RuleNum% = "Name")
				{
					thisSubject := getName(file)
					;msgbox, %thisSubject%
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
					;msgbox, % result%rulenum% . "is rule" . rulenum
					;if result%RuleNum%
					{
						;msgbox, true for %thissubject% and %object%
					}
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
					result%RuleNum% := !isInTheLast(thisSubject, Object%RuleNum%)
					;msgbox, % result%RuleNum%
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
			;Msgbox, result is %result%
			if result
			{
				if (ConfirmAction = 1)
				{
					MsgBox, 4, Action Confirmation, Are you sure you want to %Action% %fileName% because of rule %thisRule%?
					IfMsgBox No
						continue
				}
				
				Log("======================================", "Action")
				Log("Action taken: " . Action, "Action")
				Log("File: " . file, "Action")
				
				if (Action = "Move file") or (Action = "Rename file")
				{
					move(file, Destination, Overwrite)
					Log("Destination: " . Destination, "Action")
					if errorCheck
					{
						errorCheck := 0
						break
					}
				}
				else if (Action = "Send file to Recycle Bin")
				{
					recycle(file)
				}
				else if (Action = "Delete file")
				{
					;msgbox, delete it!
					delete(file)
				}
				else if (Action = "Copy file")
				{
					copy(file, Destination, Overwrite)
					Log("Destination: " . Destination, "Action")
					if errorCheck
					{
						errorCheck := 0
						break
					}
				}
				else if (Action = "Open file")
				{
					Run, %file%
				}
				else
				{
					Msgbox, You've detemerined no action to take.
				}
				
				Log("======================================", "Action")
			}
			else
			{
				;msgbox, no match
			}	
			StringCaseSense, On
		}
	}
	
	;Now that we've done the rules, time to handle to Recycle Bin (if enabled)
	IniRead, RBEnable, rules.ini, Preferences, RBEnable, 0
	if (RBEnable = 1)
	{	
		;Empty the RB on set intervals if enabled
		IniRead, RBEmpty, rules.ini, RecycleBin, RBEmpty, 0
		if (RBEmpty = 1)
		{
			IniRead, RBEmptyTimeValue, rules.ini, RecycleBin, RBEmptyTimeValue, %A_Space%
			IniRead, RBEmptyTimeLength, rules.ini, RecycleBin, RBEmptyTimeLength,  %A_Space%
			period :=
			
			if (RBEmptyTimeLength = "minutes")
			{
				period := RBEmptyTimeValue * 60000
			}
			else if (RBEmptyTimeLength = "hours")
			{
				period := RBEmptyTimeValue * 3600000
			}
			else if (RBEmptyTimeLength = "days")
			{
				period := RBEmptyTimeValue * 86400000
			}
			else if (RBEmptyTimeLength = "weeks")
			{
				period := RBEmptyTimeValue * 604800000
			}
			
			;Only update the timer if there is a new value
			;This keeps it from getting reset
			if (oldperiod != period)
			{
				SetTimer, emptyRB, %period%
				Log("Recycle Bin - Sleeptime changed from ". oldperiod . " to " . period, "System")
				oldperiod := period
			}
		}
		else
		{
			SetTimer, emptyRB, Off
			Log("Recycle Bin - empty interval has been disabled", "System")
		}
	}

	Sleep, %SleepTime%
}

emptyRB:
	FileRecycleEmpty
	Log("Recycle Bin - Interval Empty", "Action")
return

SetVars:
	APPNAME = Belvedere
	Version = 0.4
	AllSubjects = Name||Extension|Size|Date last modified|Date last opened|Date created|
	NoDefaultSubject = Name|Extension|Size|Date last modified|Date last opened|Date created|
	NameVerbs = is||is not|matches one of|does not match one of|contains|does not contain|
	NoDefaultNameVerbs = is|is not|matches one of|does not match one of|contains|does not contain|
	NumVerbs =	is||is not|is greater than|is less than|
	NoDefaultNumVerbs = is|is not|is greater than|is less than|
	DateVerbs = is in the last||is not in the last| ; removed is||is not| for now... needs more work implementing
	NoDefaultDateVerbs = is in the last|is not in the last|
	AllActions = Move file||Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|
	AllActionsNoDefault = Move file|Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|
	SizeUnits = MB||KB
	NoDefaultSizeUnits = MB|KB|
	DateUnits = minutes||hours|days|weeks
	NoDefaultDateUnits = minutes|hours|days|weeks|
	MatchList = ALL|ANY|
	DeleteApproach = Oldest First|Youngest First|Largest First|Smallest First
	LogTypes = System|Actions|Both
	IfNotExist,resources
	{
		FileCreateDir,resources
	}
	FileInstall, resources\belvedere.ico, resources\belvedere.ico
	FileInstall, resources\belvederename.png, resources\belvederename.png
	FileInstall, resources\both.png, resources\both.png
	Menu, TRAY, Icon, resources\belvedere.ico,,1
	BelvederePNG = resources\both.png
	LogFile = %A_ScriptDir%\event.log
return

BuildINI:
	IfNotExist, rules.ini
	{
		IniWrite,%A_Space%,rules.ini, Folders, Folders
		IniWrite,%A_Space%,rules.ini, Rules, AllRuleNames
		IniWrite,300000,rules.ini, Preferences, Sleeptime
		IniWrite,0,rules.ini, Preferences, RBEnable
		IniWrite,0,rules.ini, Preferences, EnableLogging
		IniWrite,%A_Space%,rules.ini, Preferences, LogType
	}
return

TRAYMENU:
	Menu,TRAY,NoStandard 
	Menu,TRAY,DeleteAll 
	Menu, TRAY, Add, &Manage, MANAGE
	Menu, TRAY, Default, &Manage
	Menu,TRAY,Add,&Preferences,PREFS
	Menu,TRAY,Add
	Menu, TRAY, Add, &Pause, PAUSE
	Menu,TRAY,Add,&About...,ABOUT
	Menu,TRAY,Add,E&xit,EXIT
	Menu,Tray,Tip,%APPNAME% %Version%
Return

MENUBAR:
	Menu, FileMenu, Add,&Pause, PAUSE
	Menu, FileMenu, Add
	Menu, FileMenu, Add, Backup Settings..., BACKUP
	Menu, FileMenu, Add, Import Settings..., IMPORT
	Menu, FileMenu, Add
	Menu, FileMenu, Add, Veiw Log..., VIEWLOG
	Menu, FileMenu, Add
	Menu, FileMenu, Add,E&xit,EXIT
	Menu, HelpMenu, Add, &Help, HELP
	Menu, HelpMenu, Add,&About %APPNAME%,ABOUT
	Menu, MenuBar, Add, &File, :FileMenu
	Menu, MenuBar, Add, &Help, :HelpMenu
Return

PREFS:
	GoSub MANAGE
	GuiControl, 1: Choose, Tabs, 3
return

PAUSE:
	if (A_IsPaused = 1)
	{
		Log(APPNAME . " has resumed from being paused", "System")
		Menu, TRAY, Icon, resources\belvedere.ico
	}
	else
	{
		Log(APPNAME . " has been paused", "System")
		Menu, TRAY, Icon, resources\belvedere-paused.ico
	}
	
	Menu, TRAY, ToggleCheck, &Pause
	Menu, FileMenu, ToggleCheck, &Pause
	Pause, Toggle
return

BACKUP:
	FileSelectFile, BackupFile, S, ,Backup %APPNAME% Settings, 
	if (BackupFile = "")
	{	
		return
	}
	
	IfExist %BackupFile%
	{
		MsgBox, 4, Overwrite, A file with the same name already exists.`nWould you like to overwrite the existing file?
		IfMsgBox No
		{
			MsgBox,,Backup, Your settings were not backed up
			return
		}
	}
	
	FileCopy, %A_ScriptDir%\rules.ini, %BackupFile%, 1
	if ErrorLevel
		MsgBox,,Backup Error, Backup was not completed!
	else
		MsgBox,,Backup Success, Backup has completed successfully!
Return

IMPORT:
	FileSelectFile, ImportFile, , , Import %APPNAME% Settings,
	if (ImportFile = "")
	{
		return
	}
	
	IniRead, Folders, %ImportFile%, Folders, Folders, %A_Space%
	IniRead, AllRuleNames, %ImportFile%, Rules, AllRuleNames, %A_Space%
	if (Folders = "" or AllRuleNames = "")
	{
		MsgBox,,Import Error, The file you are attempting to import is not a %APPNAME% rules file!
		return
	}

	MsgBox, 4, WARNING, This will overwrite your current rule set!`nAre you sure you would like to proceed?
	IfMsgBox No
		return
	
	FileCopy, %ImportFile%, %A_ScriptDir%\rules.ini, 1
	if ErrorLevel
		MsgBox,,Import Error, Rules import was not completed!
	else
		MsgBox,,Import Success, Rules import was completed successfully!
	
	GoSub, VerifyConfig
Return

VIEWLOG:
	Gui, 5: Destroy
	Gui, 5: Add, Edit, h425 w600 vLogView ReadOnly
	Gui, 5: Add, Button, x10 y440 h30 vRefreshLog gRefreshLog, Refresh
	Gui, 5: Add, Button, x280 y440 h30 vClearLog gClearLog, Clear Log
	Gui, 5: Add, Button, x545 y440 h30 vSaveLog gSaveLog, Save Log...
	GoSub, RefreshLog
	Gui, 5: Show, auto, %APPNAME% Log
Return

RefreshLog:
	FileRead, FileContents, %A_ScriptDir%\event.log
	GuiControl, 5: , LogView, %FileContents%
Return

ClearLog:
	MsgBox, 4, Clear Log?, Are you sure you would like to clear the application log?
	IfMsgBox No
		return
	FileDelete, %A_ScriptDir%\event.log
	GoSub, RefreshLog
Return

SaveLog:
	FileSelectFile, BackupFile, S, ,Save %APPNAME% Log, 
	if (BackupFile = "")
	{	
		return
	}
	
	IfExist %BackupFile%
	{
		MsgBox, 4, Overwrite, A file with the same name already exists.`nWould you like to overwrite the existing file?
		IfMsgBox No
		{
			MsgBox,,Backup, Your log was not saved
			return
		}
	}
	
	FileCopy, %A_ScriptDir%\rules.ini, %BackupFile%, 1
	if ErrorLevel
		MsgBox,,Save Error, Log Save was not completed!
	else
		MsgBox,,Save Success, Log Save has completed successfully!
Return

HELP:
	Run, "resources\Belvedere Help.chm"
return

HOMEPAGE:
	Run, http://lifehacker.com/341950/
return

WCHOMEPAGE:
	Run, http://what-cheer.com/
return

ABOUT:
	Gui,4: Destroy
	Gui,4: +owner
	Gui,4: Add,Picture,x45 y0,%BelvederePNG%
	Gui,4: font, s8, Courier New
	Gui,4: Add, Text,x275 y235,%Version%
	Gui,4: font, s9, Arial 
	Gui,4: Add,Text,x10 y250 Center,Belvedere is an automated file managment application`nthat performs actions on files based on user-defined criteria.`n`nBelvedere is written by Adam Pash and distributed`nby Lifehacker under the GNU Public License.`nFor details on how to use Belvedere, check out the
	Gui,4:Font,underline bold
	Gui,4:Add,Text,cBlue gHELP Center x115 y350, %APPNAME% Help Text
	Gui,4: font, norm
	Gui,4:Add,Text, Center x165 y367, or
	Gui,4:Font,underline bold
	Gui,4:Add,Text,cBlue gHomepage Center x115 y385,%APPNAME% homepage
	Gui,4:Add,Text,cBlue gWCHomepage Center x105 y400,Icon design by What Cheer
	Gui,4: Color,F8FAF0
	Gui,4: Show,auto,About Belvedere
Return

#Include includes\verbs.ahk
#Include includes\subjects.ahk
#Include includes\actions.ahk
#Include includes\Main_GUI.ahk
#Include includes\log.ahk
#Include includes\test.ahk
#Include includes\maint.ahk

EXIT:
	MsgBox, 4, Exit?, Are you sure you would like to exit %APPNAME% ?
	IfMsgBox No
		return
	
	Log(APPNAME . " is closing. Good-bye!", "System")
	ExitApp
