; Build script for Belvedere
; Version 0.1.0
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
buildDir = %A_WorkingDir%\build
installerDir = %A_WorkingDir%\installer
helpProject = %A_WorkingDir%\help\Belvedere Help.hhp
distDir = %A_WorkingDir%\dist
executableName = Belvedere.exe
installerScript = %buildDir%\installer.nsi

; Check dependencies
; AutoHotkey script compiler.
RegRead, ahk2exe, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
if ErrorLevel{
	MsgBox, "You do not have AutoHotkey_L installed. Please download it."
	ExitApp, 1
}

ahk2exe .= "\Compiler\Compile_AHK.exe" 

; Help manual compiler.
RegRead, hhc, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\hhw.exe, Path
if ErrorLevel{
	MsgBox, "You do not have Microsoft HTML Help Workshop installed. Please download it."
	ExitApp, 1
}

hhc .= "\hhc.exe"

; Commandline compiler for NSIS (makensis.exe)
RegRead, makensis, HKEY_LOCAL_MACHINE, SOFTWARE\NSIS
if ErrorLevel{
	MsgBox, "You do not have NSIS Installed, the installer will not be compiled."
	skipInstaller := 1
}

makensis .= "\makensis.exe"

; Clean old build files
IfExist, %buildDir%
	FileRemoveDir, %buildDir%, 1
FileCreateDir, %buildDir%

; Compile Belvedere.ahk
RunWait, %ahk2exe% /nogui %A_ScriptDir%\Belvedere.ahk

; Move to build folder
IfExist, %executableName% 
{
	FileMove, %executableName%, %buildDir%
}Else{
	MsgBox, "Application Compile Failed, exiting..."
	ExitApp, 1
}

; Compile help.
RunWait, %hhc% "%helpProject%"

IfNotExist, %A_ScriptDir%\build\Belvedere Help.chm
{
	MsgBox, "Help Compile Failed, the installer will not be compiled."
	skipInstaller := 1
}

; Copy installer files to build
FileCopy, %installerDir%\*.*, %buildDir%\*.*
FileCopy, LICENSE.txt, %buildDir%

; Build the installer
if(!skipInstaller)
{
	CompileCommand = %makensis% /V1 %installerScript%
	FileCreateDir, %A_WorkingDir%\dist
	RunWait, %CompileCommand%
}
