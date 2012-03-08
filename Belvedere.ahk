/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\Belvedere.exe
No_UPX=1
NoDecompile=1
Created_Date=1
Execution_Level=2
[VERSION]
Set_Version_Info=1
Company_Name=Lifehacker
File_Description=Belvedere
Inc_File_Version=0
Internal_Name=Belvedere
Product_Name=Belvedere
Product_Version=1.0.48.5
Set_AHK_Version=1
[ICONS]
Icon_1=%In_Dir%\resources\belvedere.ico
Icon_2=%In_Dir%\resources\belvedere.ico
Icon_3=%In_Dir%\resources\belvedere-paused.ico
Icon_4=%In_Dir%\resources\belvedere-paused.ico
Icon_5=%In_Dir%\resources\belvedere-paused.ico
Icon_6=%In_Dir%\resources\belvedere.ico
Icon_7=%In_Dir%\resources\belvedere-paused.ico

* * * Compile_AHK SETTINGS END * * *
*/

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
StringCaseSense, Off
GoSub, SetVars
GoSub, TRAYMENU
GoSub, MENUBAR
GoSub, BuildINI
IniRead, Folders, rules.ini, Folders, Folders, %A_Space%
IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames, %A_Space%
IniRead, SleepTime, rules.ini, Preferences, SleepTime, 3
IniRead, SleeptimeLength, rules.ini, Preferences, SleeptimeLength, minutes
IniRead, EnableLogging, rules.ini, Preferences, EnableLogging, 0
IniRead, LogType, rules.ini, Preferences, LogType, %A_Space%
IniRead, GrowlEnabled, rules.ini, Preferences, GrowlEnabled, 0
IniRead, TrayTipEnabled, rules.ini, Preferences, TrayTipEnabled, 0
IniRead, ConfirmExit, rules.ini, Preferences, ConfirmExit, 1
IniRead, ExistingVersion, rules.ini, About, Version, 0

;Check to see what version was running before we were initiated (used for upgrades)
if (ExistingVersion < Version)
	GoSub, UpgradeINI

;Register Belvedere with the Growl for Windows Application
if GrowlEnabled = 1
	RunWait, %A_ScriptDir%\resources\growlnotify.exe /a:"Belvedere" /r:"Action"`,"System"`,"Error" /ai:"%A_ScriptDir%\resources\both.png" "Belvedere has been registered"
	
Log("Starting " . APPNAME . " " . Version, "System")
Notify("Starting " . APPNAME . " " . Version, "System")
WinNotify("Starting " . APPNAME . " " . Version, "System")
GoSub, getParams

;main execution loop
Loop
{
	;Loops through all the folder names for rules
	IniRead, Folders, rules.ini, Folders, Folders
	Loop, Parse, Folders, |
	{
		thisFolder = %A_LoopField%
		if (thisFolder = "ERROR") or (thisFolder = "")
			continue

		;Loops through all the rule names for the specific folder for execution
		IniRead, FolderRules, rules.ini, %thisFolder%, RuleNames
		Loop, Parse, FolderRules, |
		{
			thisRule = %A_LoopField%
			if (thisRule = "ERROR") or (thisRule = "")
				continue

			;Loops to determine number of subjects within a rule
			NumOfRules := 1
			Loop
			{
				IniRead, MultiRule, rules.ini, %thisRule%, Subject%A_Index%
				if (MultiRule != "ERROR")
					NumOfRules++ 
				else
					break
			}
			
			IniRead, Folder, rules.ini, %thisRule%, Folder, %A_Space%
			IniRead, Enabled, rules.ini, %thisRule%, Enabled, 0
			IniRead, ConfirmAction, rules.ini, %thisRule%, ConfirmAction, 0
			IniRead, Recursive, rules.ini, %thisRule%, Recursive, 0
			IniRead, Action, rules.ini, %thisRule%, Action, %A_Space%
			IniRead, Destination, rules.ini, %thisRule%, Destination, %A_Space%
			IniRead, Matches, rules.ini, %thisRule%, Matches, %A_Space%
			IniRead, AttribReadOnly, rules.ini, %thisRule%, AttribReadOnly, 0
			IniRead, AttribHidden, rules.ini, %thisRule%, AttribHidden, 0
			IniRead, AttribSystem, rules.ini, %thisRule%, AttribSystem, 0
			
			thisAttributes :=
			if AttribReadOnly
				thisAttributes = R,%thisAttributes%
			if AttribHidden
				thisAttributes = H,%thisAttributes%
			if AttribSystem
				thisAttributes = S,%thisAttributes%
			StringTrimRight, thisAttributes, thisAttributes, 1
			
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
			;also checking to see if the user wants to compress it as well
			if (Destination != "")
			{
				IniRead, Overwrite, rules.ini, %thisRule%, Overwrite, 0
				IniRead, Compress, rules.ini, %thisRule%, Compress, 0
			}

			;Loop through all of the folder contents
			Loop %Folder%, 1, %Recursive%
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
					FileGetAttrib, Attributes, %A_LoopFileLongPath%

					;skip any further processing if it is an excluded attribute
					if Attributes contains %thisAttributes%
						continue

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
						MsgBox,,No Match, Subject does not have a match
					
					; Below determines the comparison verb
					if (Verb%RuleNum% = "contains")
						result%RuleNum% := contains(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "does not contain")
						result%RuleNum% := !(contains(thisSubject, Object%RuleNum%))
					else if (Verb%RuleNum% = "contains one of")
						result%RuleNum% := containsOneOf(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "is")
						result%RuleNum% := isEqual(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "matches one of")
						result%RuleNum% := isOneOf(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "does not match one of")
						result%RuleNum% := !(isOneOf(thisSubject, Object%RuleNum%))
					else if (Verb%RuleNum% = "RegEx")
						result%RuleNum% := RegEx(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "is less than")
						result%RuleNum% := isLessThan(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "is less than or equal")
						result%RuleNum% := isLessThanEqual(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "is greater than")
						result%RuleNum% := isGreaterThan(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "is greater than or equal")
						result%RuleNum% := isGreaterThanEqual(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "is not")
						result%RuleNum% := !(isEqual(thisSubject, Object%RuleNum%))
					else if (Verb%RuleNum% = "is in the last")
						result%RuleNum% := isInTheLast(thisSubject, Object%RuleNum%)
					else if (Verb%RuleNum% = "is not in the last")
						result%RuleNum% := !(isInTheLast(thisSubject, Object%RuleNum%))
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

				;if we have matches, then we act upon them below
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
					
					Message = Action taken: %Action%`r`n
					Message = %Message%File: %file%`r`n
					
					;Here is where we act upon the files that matched
					if (Action = "Move file") or (Action = "Move file & leave shortcut")
					{
						Log("Destination: " . Destination, "Action")
						Message = %Message%Destination: %Destination%`r`n
						
						if (Action = "Move file & leave shortcut")
							errcode := move(file, Destination, Overwrite, Compress, 1, Attributes)
						else
							errcode := move(file, Destination, Overwrite, Compress, 0, Attributes)
							
						if (errcode = -1)
						{
							Msgbox,,Missing Folder,A folder you're attempting to move files to does not exist.`n Check your "%thisRule%" rule and verify that %Destination% exists.
							Log("ERROR: Unable to move file, destination folder missing", "Action")
							Message = %Message%Unable to move file, destination folder missing
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else if (errcode <> 0)
						{
							Log("ERROR: Unable to move file", "Action")
							Message = %Message%Unable to move file
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
						
					}
					else if (Action = "Rename file")
					{
						Log("Destination: " . Destination, "Action")
						Message = %Message%Destination: %Destination%`r`n
						
						errcode := rename(file, Destination, Attributes)
						if errcode
						{
							Log("ERROR: Unable to rename file", "Action")
							Message = %Message%Unable to rename file
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
					}
					else if (Action = "Send file to Recycle Bin")
					{
						errcode := recycle(file)
						if errcode
						{
							Log("ERROR: Unable to move file to recycle bin", "Action")
							Message = %Message%Unable to move file to recycle bin
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
					}
					else if (Action = "Delete file")
					{
						errcode := delete(file, Attributes)
						if errcode
						{
							Log("ERROR: Unable to delete file", "Action")
							Message = %Message%Unable to delete file
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
					}
					else if (Action = "Copy file")
					{
						Log("Destination: " . Destination, "Action")
						errcode := copy(file, Destination, Overwrite, Compress, Attributes)
						if (errcode = -1)
						{
							Msgbox,,Missing Folder,A folder you're attempting to copy files to does not exist.`n Check your "%thisRule%" rule and verify that %Destination% exists.
							Log("ERROR: Unable to copy file, destination folder missing", "Action")
							Message = %Message%Unable to copy file, destination folder missing
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else if (errcode <> 0)
						{
							Log("ERROR: Unable to copy file", "Action")
							Message = %Message%Unable to copy file
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
					}
					else if (Action = "Open file")
					{
						errcode := open(file)
						if errcode
						{
							Log("ERROR: Unable to open file", "Action")
							Message = %Message%Unable to open file
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
					}
					else if (Action = "Print file")
					{
						errcode := print(file)
						if errcode
						{
							Log("ERROR: Unable to print file", "Action")
							Message = %Message%Unable to print file
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
					}
					else if (Action = "Custom")
					{
						errcode := custom(file, Destination)
						if errcode
						{
							Log("ERROR: Unable to complete custom action on file", "Action")
							Message = %Message%Unable to complete custom action on file
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
						else
						{
							Notify(Message, "Action")
							WinNotify(Message, "Action")
						}
					}
					else if (Action = "Add to iTunes")
					{
						errcode := addtoitunes(file)
						if errcode
						{
							Log("ERROR: Unable to add file to iTunes", "Action")
							Message = %Message%Unable to add file to iTunes
							Notify(Message, "Error")
							WinNotify(Message, "Error")
						}
					}
					else
					{
						Msgbox,,No Action, You've detemerined no action to take.
					}
					
					Log("======================================", "Action")
				}
			}
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
			IniRead, RBLastEmpty, rules.ini, RecycleBin, RBLastEmpty, %A_Now%
			period :=
			
			;Everything is converted to seconds just to make sure
			if (RBEmptyTimeLength = "minutes")
				period := RBEmptyTimeValue * 60
			else if (RBEmptyTimeLength = "hours")
				period := RBEmptyTimeValue * 3600
			else if (RBEmptyTimeLength = "days")
				period := RBEmptyTimeValue * 86400
			else if (RBEmptyTimeLength = "weeks")
				period := RBEmptyTimeValue * 604800
			else
				period := RBEmptyTimeValue
			
			ElapsedPeriod := %A_Now%
			EnvSub, ElapsedPeriod, RBLastEmpty, Seconds
			
			;Empty the RB if we have passed the time set
			if (ElapsedPeriod > period)
			{
				IniWrite, %A_Now%, rules.ini, RecycleBin, RBLastEmpty
				GoSub, emptyRB
			}
		}
	}

	if (MaxRunCount && A_Index >= MaxRunCount)
	{
		Log(APPNAME . " is closing due to run count command line parameter. Good-bye!", "System")
		Notify(APPNAME . " is closing due to run count command line parameter. Good-bye!", "System")
		WinNotify(APPNAME . " is closing due to run count command line parameter. Good-bye!", "System")
		ExitApp
	}

	;Everything is converted to milliseconds because of Sleep command
	if (SleeptimeLength = "minutes")
		SleepPeriod := Sleeptime * 60000
	else if (SleeptimeLength = "hours")
		SleepPeriod := Sleeptime * 3600000
	else if (SleeptimeLength = "days")
		SleepPeriod := Sleeptime * 86400000
	else if (SleeptimeLength = "weeks")
		SleepPeriod := Sleeptime * 604800000
	else
		SleepPeriod := Sleeptime * 1000
	
	Sleep, %SleepPeriod%
}

;This is responsible for grabbing and validating command line paramenters
; code segment by Ace_NoOne & toralf
; http://www.autohotkey.com/forum/topic7556.html
getParams:
	Loop, %0% ;for each command line parameter
	{
		param := %A_Index%
		if (param = "-r")
		{
			value := A_Index + 1
			param_val := %value%
			if param_val is integer
			{
				Log("Command Line Paramter " . param . " accepted with value " . param_val, "System")
				Notify("Command Line Paramter " . param . " accepted with value " . param_val, "System")
				WinNotify("Command Line Paramter " . param . " accepted with value " . param_val, "System")
				MaxRunCount := param_val
			}
		}
	}
return

;This is repsonsible for emptying the Recycle Bin at the interval set
emptyRB:
	FileRecycleEmpty
	if ErrorLevel
	{
		Log("ERROR: Recycle Bin - Interval Empty Failed", "Action")
		Notify("Recycle Bin - Interval Empty Failed", "Error")
		WinNotify("Recycle Bin - Interval Empty Failed", "Error")
	}
	else
	{
		IniRead, RBLastEmpty, rules.ini, RecycleBin, RBLastEmpty, 0
		if RBLastEmpty
			FormatTime, DT, %RBLastEmpty%
		else
			DT := 
		GuiControl, 1: ,RBLastEmpty, Last Empty:  %DT%
		Log("Recycle Bin - Interval Empty Successful", "Action")
		Notify("Recycle Bin - Interval Empty Successful", "Action")
		WinNotify("Recycle Bin - Interval Empty Successful", "Action")
	}
return

;Here we are creating all the variables for usage as well as the resource files
SetVars:
	APPNAME = Belvedere
	Version = 0.7.1
	AllSubjects = Name||Extension|Size|Date last modified|Date last opened|Date created|
	NoDefaultSubject = Name|Extension|Size|Date last modified|Date last opened|Date created|
	NameVerbs = is||is not|matches one of|does not match one of|contains|does not contain|contains one of|RegEx|
	NoDefaultNameVerbs = is|is not|matches one of|does not match one of|contains|does not contain|contains one of|RegEx|
	NumVerbs =	is||is not|is greater than|is greater than or equal|is less than|is less than or equal|
	NoDefaultNumVerbs = is|is not|is greater than|is greater than or equal|is less than|is less than or equal|
	DateVerbs = is in the last||is not in the last| ; removed is||is not| for now... needs more work implementing
	NoDefaultDateVerbs = is in the last|is not in the last|
	AllActions = Move file||Move file & leave shortcut|Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|Print file|Custom|Add to iTunes|
	AllActionsNoDefault = Move file|Move file & leave shortcut|Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|Print file|Custom|Add to iTunes|
	SizeUnits = MB||KB
	NoDefaultSizeUnits = MB|KB|
	DateUnits = seconds|minutes||hours|days|weeks
	NoDefaultDateUnits = seconds|minutes|hours|days|weeks|
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
		IniWrite, %A_Space%, rules.ini, Folders, Folders
		IniWrite, %A_Space%, rules.ini, Rules, AllRuleNames
		IniWrite, 3, rules.ini, Preferences, Sleeptime
		IniWrite, minutes, rules.ini, Preferences, SleeptimeLength
		IniWrite, 0, rules.ini, Preferences, RBEnable
		IniWrite, 0, rules.ini, Preferences, EnableLogging
		IniWrite, %A_Space%, rules.ini, Preferences, LogType
		IniWrite, %A_Desktop%, rules.ini, Preferences, LastFolder
		IniWrite, 0, rules.ini, Preferences, GrowlEnabled
		IniWrite, 0, rules.ini, Preferences, TrayTipEnabled
		IniWrite, 1, rules.ini, Preferences, ConfirmExit
		IniWrite, 0, rules.ini, Preferences, Default_Enabled
		IniWrite, 0, rules.ini, Preferences, Default_ConfirmAction
		IniWrite, 0, rules.ini, Preferences, Default_Recursive
		IniWrite, 0, rules.ini, RecycleBin, RBEmpty
		IniWrite, %A_Space%, rules.ini, RecycleBin, RBEmptyTimeValue
		IniWrite, %A_Space%, rules.ini, RecycleBin, RBEmptyTimeLength
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
	Menu, FileMenu, Add, &Backup Settings..., BACKUP
	Menu, FileMenu, Add, &Import Settings..., IMPORT
	Menu, FileMenu, Add
	Menu, FileMenu, Add, &View Log..., VIEWLOG
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
		Notify(APPNAME . " has resumed from being paused", "System")
		WinNotify(APPNAME . " has resumed from being paused", "System")
		Menu, TRAY, Icon, resources\belvedere.ico
		SB_SetText("", 2)
	}
	else
	{
		Log(APPNAME . " has been paused", "System")
		Notify(APPNAME . " has been paused", "System")
		WinNotify(APPNAME . " has been paused", "System")
		Menu, TRAY, Icon, resources\belvedere-paused.ico
		SB_SetText("PAUSED", 2)
	}
	
	Menu, TRAY, ToggleCheck, &Pause
	Menu, FileMenu, ToggleCheck, &Pause
	Pause, Toggle
return

RESTART:
	Reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	MsgBox,,Restart Failed, I was unable to restart myself.`nPlease manually restart %APPNAME% at your earliest convenience for your new settings to take effect.
return

;Run when the 'Backup Settings...' menu item is clicked on the Main Menu
; Saves the rules.ini file if the user chooses to back it up
BACKUP:
	Gui, 1: +OwnDialogs
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
	Gui, 1: +OwnDialogs
	FileSelectFile, ImportFile, , , Import %APPNAME% Settings,
	if (ImportFile = "")
		return
		
	;Check that all the key settings are present to determine if this is a true settings file
	IniRead, Sleeptime, rules.ini, Preferences, Sleeptime, %A_Space%
	IniRead, SleeptimeLength, rules.ini, Preferences, SleeptimeLength, %A_Space%
	IniRead, EnableLogging, rules.ini, Preferences, EnableLogging, %A_Space%
	IniRead, RBEnable, rules.ini, Preferences, RBEnable, %A_Space%
	if (Sleeptime = "" or SleeptimeLength = "" or EnableLogging = "" or RBEnable = "")
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
	Gosub, RefreshVars
	
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
Return

;Run when the 'View Log...' menu item is clicked on the Main Menu
;Shows the log file in a new window
VIEWLOG:
	Gui, 5: Destroy
	Gui, 5: +owner1
	Gui, 5: +toolwindow
	Gui, 5: Add, Edit, h425 w600 vLogView ReadOnly
	Gui, 5: Add, Button, x10 y440 h30 vRefreshLog gRefreshLog, Refresh
	Gui, 5: Add, Button, x280 y440 h30 vClearLog gClearLog, Clear Log
	Gui, 5: Add, Button, x545 y440 h30 vSaveLog gSaveLog, Save Log...
	GoSub, RefreshLog
	Gui, 1: +Disabled
	Gui, 5: Show, auto, %APPNAME% Log
Return

4GuiClose:
5GuiClose:
	Gui, 1: -Disabled
	Gui, 4: Destroy
	Gui, 5: Destroy
return

;Run when the 'Refresh' button is clicked under the log screen
; will re-read the log and display in the same window
RefreshLog:
	IfNotExist, %A_ScriptDir%\event.log
	{
		GuiControl, 5: , LogView, %A_Space%
	}
	else
	{
		FileRead, FileContents, %A_ScriptDir%\event.log
		if ErrorLevel
			MsgBox,,Read Error, Unable to read %APPNAME% log.
			
		GuiControl, 5: , LogView, %FileContents%
	}
Return

;Run when the 'Clear Log' button is clicked under the log screen
; will delete the curent log file without backing it up
ClearLog:
	Gui +OwnDialogs
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
	Gui +OwnDialogs
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

UpgradeINI:
	IniWrite, %Version%, rules.ini, About, Version ;go ahead and write the new version

	if ExistingVersion = 0 ;This is our catchall (anythign less than 0.6) for now, moving forward we'll have this populated
	{
		IniRead, SleepTime, rules.ini, Preferences, SleepTime

		if (SleepTime >= 604800000)
		{
			SleepTime /=604800000
			IniWrite, %SleepTime%, rules.ini, Preferences, Sleeptime
			IniWrite, weeks, rules.ini, Preferences, SleeptimeLength		
		}
		else if (SleepTime >= 86400000)
		{
			SleepTime /=86400000
			IniWrite, %SleepTime%, rules.ini, Preferences, Sleeptime
			IniWrite, days, rules.ini, Preferences, SleeptimeLength
		}
		else if (SleepTime >= 3600000)
		{
			SleepTime /=3600000
			IniWrite, %SleepTime%, rules.ini, Preferences, Sleeptime
			IniWrite, hours, rules.ini, Preferences, SleeptimeLength		
		}
		else if (SleepTime >= 60000)
		{
			SleepTime /=60000
			IniWrite, %SleepTime%, rules.ini, Preferences, Sleeptime
			IniWrite, minutes, rules.ini, Preferences, SleeptimeLength
		}
		else
		{
			IniWrite, %SleepTime%, rules.ini, Preferences, Sleeptime
			IniWrite, seconds, rules.ini, Preferences, SleeptimeLength
		}
	}
	MsgBox, 1, Upgrade, Welcome to %APPNAME% %Version% we noticed that you just upgraded a previous version.`nPlease give us a few seconds to verify your configuration...
	Gosub, VerifyConfig
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

7ZIPHOMEPAGE:
	Run, http://www.7-zip.org
return

;Run when the 'About Belvedere' menu item is clicked on the Main Menu
ABOUT:
	Gui,4: Destroy
	Gui,4: +toolwindow
	Gui,4: Add,Picture,x45 y0,%BelvederePNG%
	Gui,4: font, s8, Courier New
	Gui,4: Add, Text,x275 y235,%Version%
	Gui,4: font, s9, Arial 
	Gui,4: Add,Text,x10 y250 Center,Belvedere is an automated file management application`nthat performs actions on files based on user-defined criteria.`n`nBelvedere is written by Adam Pash and distributed`nby Lifehacker under the GNU Public License.`nFor details on how to use Belvedere, check out the
	Gui,4: Font,underline bold
	Gui,4: Add,Text,cBlue gHELP Center x115 y350, %APPNAME% Help Text
	Gui,4: Font, norm
	Gui,4: Add,Text, Center x165 y367, or
	Gui,4: Font,underline bold
	Gui,4: Add,Text,cBlue gHomepage Center x115 y385,%APPNAME% homepage
	Gui,4: Add,Text,cBlue gWCHomepage Center x105 y400,Icon design by What Cheer
	Gui,4: Add,Text,cBlue g7zipHomepage Center x30 y415, 7-Zip used for compression under GNU LGPL license
	Gui,4: Color,F8FAF0
	Gui,1: +Disabled
	Gui,4: Show, AutoSize,About Belvedere
Return

#Include includes\verbs.ahk
#Include includes\subjects.ahk
#Include includes\actions.ahk
#Include includes\Main_GUI.ahk
#Include includes\log.ahk
#Include includes\test.ahk
#Include includes\maint.ahk
#Include includes\gui-rule.ahk

;Closing the app; w/ confirmation
EXIT:
	Gui, 1: +OwnDialogs
	
	if ConfirmExit
	{
		MsgBox, 4, Exit?, Are you sure you would like to exit %APPNAME% ?
		IfMsgBox No
			return
	}
	
	Log(APPNAME . " is closing. Good-bye!", "System")
	Notify(APPNAME . " is closing. Good-bye!", "System")
	ExitApp
