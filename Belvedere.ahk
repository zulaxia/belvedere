;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows
; Author:         Adam Pash <adam.pash@gmail.com>
; Contributor:	  Matthew Shorts <mshorts@gmail.com>
;
; Script Function:
;	Automated file manager
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetFormat, float, 0.2
GoSub, SetVars
GoSub, TRAYMENU
GoSub, MENUBAR
GoSub, BuildINI
SetTimer, emptyRB, Off
IniRead, Folders, rules.ini, Folders, Folders, %A_Space%
IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames, %A_Space%
IniRead, SleepTime, rules.ini, Preferences, SleepTime, 300000
IniRead, EnableLogging, rules.ini, Preferences, EnableLogging, 0
IniRead, LogType, rules.ini, Preferences, LogType, %A_Space%
IniRead, CaseSensitivity, rules.ini, Preferences, CaseSensitivity, 1

;Will be set based on global settings in ini file
; will default to On just to be safe
if CaseSensitivity = 0
	StringCaseSense, Off
else
	StringCaseSense, On

Log("Starting " . APPNAME . " " . Version, "System")

;main execution loop
Loop
{
	;Loops through all the rule names for execution
	Loop, Parse, AllRuleNames, |
	{
		thisRule = %A_LoopField%
		NumOfRules := 1

		;Loops to determine number of subjects within a rule
		Loop
		{
			IniRead, MultiRule, rules.ini, %thisRule%, Subject%A_Index%
			if (MultiRule != "ERROR")
				NumOfRules++ 
			else
				break
		}
		
		if (thisRule = "ERROR") or (thisRule = "")
			continue

		IniRead, Folder, rules.ini, %thisRule%, Folder, %A_Space%
		IniRead, Enabled, rules.ini, %thisRule%, Enabled, 0
		IniRead, ConfirmAction, rules.ini, %thisRule%, ConfirmAction, 0
		IniRead, Recursive, rules.ini, %thisRule%, Recursive, 0
		IniRead, Action, rules.ini, %thisRule%, Action, %A_Space%
		IniRead, Destination, rules.ini, %thisRule%, Destination, %A_Space%
		IniRead, Matches, rules.ini, %thisRule%, Matches, %A_Space%
		
		;If rule is not enabled, just skip over it
		if (Enabled = 0)
			continue

		;Loop to read the subjects, verbs and objects for the list defined
		Loop
		{
			if ((A_Index-1) = NumOfRules)
				break

			if (A_Index = 1)
				RuleNum =
			else
				RuleNum := A_Index - 1

			IniRead, Subject%RuleNum%, rules.ini, %thisRule%, Subject%RuleNum%
			IniRead, Verb%RuleNum%, rules.ini, %thisRule%, Verb%RuleNum%
			IniRead, Object%RuleNum%, rules.ini, %thisRule%, Object%RuleNum%
		}

		;if we're moving something, need to find out if I can overwrite it
		if (Destination != "")
			IniRead, Overwrite, rules.ini, %thisRule%, Overwrite, 0

		;Loop through all of the folder contents
		Loop %Folder%, 0, %Recursive%
		{
			Loop
			{
				if ((A_Index - 1) = NumOfRules)
					break

				if (A_Index = 1)
					RuleNum =
				else
					RuleNum := A_Index - 1

				file = %A_LoopFileLongPath%
				fileName = %A_LoopFileName%

				; Below determines the subject of the comparison
				if (Subject%RuleNum% = "Name")
					thisSubject := getName(file)
				else if (Subject%RuleNum% = "Extension")
					thisSubject := getExtension(file)
				else if (Subject%RuleNum% = "Size")
					thisSubject := getSize(file)
				else if (Subject%RuleNum% = "Date last modified")
					thisSubject := getDateLastModified(file)
				else if (Subject%RuleNum% = "Date last opened")
					thisSubject := getDateLastOpened(file)
				else if (Subject%RuleNum% = "Date created")
					thisSubject := getDateCreated(file)
				else
					MsgBox, Subject does not have a match
				
				; Below determines the comparison verb
				if (Verb%RuleNum% = "contains")
					result%RuleNum% := contains(thisSubject, Object%RuleNum%)
				else if (Verb%RuleNum% = "does not contain")
					result%RuleNum% := !(contains(thisSubject, Object%RuleNum%))
				else if (Verb%RuleNum% = "is")
					result%RuleNum% := isEqual(thisSubject, Object%RuleNum%)
				else if (Verb%RuleNum% = "matches one of")
					result%RuleNum% := isOneOf(thisSubject, Object%RuleNum%)
				else if (Verb%RuleNum% = "does not match one of")
					result%RuleNum% := !(isOneOf(thisSubject, Object%RuleNum%))
				else if (Verb%RuleNum% = "is less than")
					result%RuleNum% := isLessThan(thisSubject, Object%RuleNum%)
				else if (Verb%RuleNum% = "is greater than")
					result%RuleNum% := isGreaterThan(thisSubject, Object%RuleNum%)
				else if (Verb%RuleNum% = "is not")
					result%RuleNum% := !(isEqual(thisSubject, Object%RuleNum%))
				else if (Verb%RuleNum% = "is in the last")
					result%RuleNum% := isInTheLast(thisSubject, Object%RuleNum%)
				else if (Verb%RuleNum% = "is not in the last")
					result%RuleNum% := !isInTheLast(thisSubject, Object%RuleNum%)
			}
			
			; Below evaluates result and takes action
			Loop
			{
				if (NumOfRules < A_Index)
					break

				if (A_Index = 1)
					RuleNum=
				else
					RuleNum := A_Index - 1

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
						break
					}
					else
					{
						result := 0
						continue
					}
				}
			}

			;if we have mathces, then we act upon them below
			if result
			{
				;User can ask to confirm the actions, and if so, we ask them if they woudl liek to procede
				if (ConfirmAction = 1)
				{
					MsgBox, 4, Action Confirmation, Are you sure you want to %Action% %fileName% because of rule %thisRule%?
					IfMsgBox No
						continue
				}
				
				Log("======================================", "Action")
				Log("Action taken: " . Action, "Action")
				Log("File: " . file, "Action")
				
				;Here is where we cat upon the files that matched
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
				period := RBEmptyTimeValue * 60000
			else if (RBEmptyTimeLength = "hours")
				period := RBEmptyTimeValue * 3600000
			else if (RBEmptyTimeLength = "days")
				period := RBEmptyTimeValue * 86400000
			else if (RBEmptyTimeLength = "weeks")
				period := RBEmptyTimeValue * 604800000
			
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
			;turning off the RB Timer
			SetTimer, emptyRB, Off
			Log("Recycle Bin - empty interval has been disabled", "System")
		}
	}

	Sleep, %SleepTime%
}

;This is repsonsible for emptying the Recycle Bin at the interval set
emptyRB:
	FileRecycleEmpty
	Log("Recycle Bin - Interval Empty", "Action")
return

;Here we are creating all the variables for usage as well as the resource files
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
	LogTypes = System|Actions|Both|
	
	IfNotExist,resources
		FileCreateDir,resources
	
	FileInstall, resources\belvedere.ico, resources\belvedere.ico
	FileInstall, resources\belvedere-paused.ico, resources\belvedere-paused.ico
	FileInstall, resources\belvederename.png, resources\belvederename.png
	FileInstall, resources\both.png, resources\both.png
	Menu, TRAY, Icon, resources\belvedere.ico,,1
	BelvederePNG = resources\both.png
	LogFile = %A_ScriptDir%\event.log
return

;If I don't have the INI file existent, I will go ahead and build it
BuildINI:
	IfNotExist, rules.ini
	{
		IniWrite,%A_Space%,rules.ini, Folders, Folders
		IniWrite,%A_Space%,rules.ini, Rules, AllRuleNames
		IniWrite,300000,rules.ini, Preferences, Sleeptime
		IniWrite,0,rules.ini, Preferences, RBEnable
		IniWrite,0,rules.ini, Preferences, EnableLogging
		IniWrite,%A_Space%,rules.ini, Preferences, LogType
		IniWrite,1,rules.ini, Preferences, CaseSensitivity
	}
return

;Menu that sits in the system tray
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

;Menu that is at the top of the main GUI
MENUBAR:
	Menu, FileMenu, Add,&Pause, PAUSE
	Menu, FileMenu, Add
	Menu, FileMenu, Add, Backup Settings..., BACKUP
	Menu, FileMenu, Add, Import Settings..., IMPORT
	Menu, FileMenu, Add
	Menu, FileMenu, Add, View Log..., VIEWLOG
	Menu, FileMenu, Add
	Menu, FileMenu, Add,E&xit,EXIT
	Menu, HelpMenu, Add, &Help, HELP
	Menu, HelpMenu, Add,&About %APPNAME%,ABOUT
	Menu, MenuBar, Add, &File, :FileMenu
	Menu, MenuBar, Add, &Help, :HelpMenu
Return

;Run when the 'Preferences' tray menu option is clicked
;Preferences Option in Tray Menu
PREFS:
	GoSub MANAGE
	GuiControl, 1: Choose, Tabs, 3
return

;Run when the 'Pause' menu option is clicked
;Pauses the application either from the Tray or Main GUI menu
; changes the tray icon color as well as the status bar text and
; a check mark next to the Pause option on the Main GUI menu
PAUSE:
	if (A_IsPaused = 1)
	{
		Log(APPNAME . " has resumed from being paused", "System")
		Menu, TRAY, Icon, resources\belvedere.ico
		SB_SetText("", 2)
	}
	else
	{
		Log(APPNAME . " has been paused", "System")
		Menu, TRAY, Icon, resources\belvedere-paused.ico
		SB_SetText("PAUSED", 2)
	}
	
	Menu, TRAY, ToggleCheck, &Pause
	Menu, FileMenu, ToggleCheck, &Pause
	Pause, Toggle
return

;Run when the 'Backup Settings...' menu item is clicked on the Main Menu
; Saves the rules.ini file if the user chooses to back it up
BACKUP:
	FileSelectFile, BackupFile, S, ,Backup %APPNAME% Settings, 
	if (BackupFile = "")
		return
	
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

;Run when the 'Import Settings...' menu item is clicked on the Main Menu
;Imports the rules.ini file if the user chooses to do so
; this will irretrevably overwrite the current rules.ini file
IMPORT:
	FileSelectFile, ImportFile, , , Import %APPNAME% Settings,
	if (ImportFile = "")
		return
	
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

;Run when the 'View Log...' menu item is clicked on the Main Menu
;Shows the log file in a new window
VIEWLOG:
	Gui, 5: Destroy
	Gui, 5: Add, Edit, h425 w600 vLogView ReadOnly
	Gui, 5: Add, Button, x10 y440 h30 vRefreshLog gRefreshLog, Refresh
	Gui, 5: Add, Button, x280 y440 h30 vClearLog gClearLog, Clear Log
	Gui, 5: Add, Button, x545 y440 h30 vSaveLog gSaveLog, Save Log...
	GoSub, RefreshLog
	Gui, 5: Show, auto, %APPNAME% Log
Return

;Run when the 'Refresh' button is clicked under the log screen
; will re-read the log and display in the same window
RefreshLog:
	FileRead, FileContents, %A_ScriptDir%\event.log
	GuiControl, 5: , LogView, %FileContents%
Return

;Run when the 'Clear Log' button is clicked under the log screen
; will delete the curent log file without backing it up
ClearLog:
	MsgBox, 4, Clear Log?, Are you sure you would like to clear the application log?
	IfMsgBox No
		return
	FileDelete, %A_ScriptDir%\event.log
	GoSub, RefreshLog
Return

;Run when the 'Save Log...' button is clicked under the log screen
; will prompt the user to save the current file and still keep the
; current one in the directory
SaveLog:
	FileSelectFile, BackupFile, S, ,Save %APPNAME% Log, 
	if (BackupFile = "")
		return
	
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

;Run when the 'Help' menu item is clicked on the Main Menu
; displays the CHM file
HELP:
	Run, "resources\Belvedere Help.chm"
return

;Link to the homepage on Lifehacker (used in About dialog)
HOMEPAGE:
	Run, http://lifehacker.com/341950/
return

;Link to the homepage on What Cheer (used in About dialog)
WCHOMEPAGE:
	Run, http://what-cheer.com/
return

;Run when the 'About Belvedere' menu item is clicked on the Main Menu
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

;Closing the app; w/ confirmation
EXIT:
	MsgBox, 4, Exit?, Are you sure you would like to exit %APPNAME% ?
	IfMsgBox No
		return
	
	Log(APPNAME . " is closing. Good-bye!", "System")
	ExitApp
