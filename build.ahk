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
SetWorkingDir %A_ScriptDir%
buildDir = build
executableName= Belvedere.exe

; Check dependencies
RegRead, ahk2exe, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Ahk2Exe.exe ;ahk2exe
if ErrorLevel{
	MsgBox, "You do not have AutoHotkey_L installed. Please download it."
	ExitApp, 1
}
; NSIS

; Clean old build files
IfExist, %buildDir%
	FileRemoveDir, %buildDir%, 1
FileCreateDir, %buildDir%

; Compile Belvedere.ahk
RunWait, %ahk2exe% /in Belvedere.ahk

; Move to build folder
FileMove, %executableName%, %buildDir%

; Compile help.

; Move the help file to the the build folder.

; Copy installer files to build
