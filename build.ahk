; Build script for Belvedere
; Version 0.0.2
; Author: Dorian Alexander Patterson <imaginationc@gmail.com>
; Requires: AutoHotkey_L 1.1.07.01+
;
; Copyright 2012 Dorian Alexander Patterson
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; Set up build environment
#NoEnv
#SingleInstance ignore
SetWorkingDir A_ScriptDir
buildDir = build
helpProject = %A_WorkingDir%\help\Belvedere Help.hhp
executableName= Belvedere.exe

; Check dependencies
; AutoHotkey script compiler.
RegRead, ahk2exe, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Ahk2Exe.exe 
if ErrorLevel{
	MsgBox, "You do not have AutoHotkey_L installed. Please download it."
	ExitApp, 1
}
; Help manual compiler.
RegRead, hhw, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\hhw.exe 
if ErrorLevel{
	MsgBox, "You do not have Microsoft HTML Help Workshop installed. Please download it."
	ExitApp, 1
}
; Commandline compiler for NSIS (makensis.exe)
RegRead, makensis, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\NSIS, InstallLocation
makensis .= "\makensis.exe"

; Clean old build files
IfExist, %buildDir%
	FileRemoveDir, %buildDir%, 1
FileCreateDir, %buildDir%

; Compile Belvedere.ahk
RunWait, %ahk2exe% /in Belvedere.ahk

; Move to build folder
FileMove, %executableName%, %buildDir%

; Compile help.
while(!helpCompiled){
	RunWait %hhw% %helpProject%
	MsgBox, 4, , Did you compile the help manual sucessfully?
	IfMsgBox Yes
		helpCompiled = 1
	Else
		MsgBox, 0, , "Fix the errors in the help manual project and try again."
		If MsgBox OK{
			ExitApp, 1
		}
}

; Move the help file to the the build folder.

; Copy installer files to build
