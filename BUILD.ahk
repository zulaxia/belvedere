; Build script for Belvedere
; Version 0.0.1
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
buildDir = %A_WorkingDir%\build\
executableName= Belvedere.exe

; NSIS
; Microsoft HTML Help Workshop 1.3
; ahk2exe
ahk2exe = I:\Program Files (x86)\AutoHotKey\Compiler\Ahk2Exe.exe
; Check dependencies

; Clean old build files
;FileRemoveDir, 

; Compile Belvedere.ahk
RunWait, %ahk2exe% /in Belvedere.ahk

; Copy to build folder
FileMove, %executableName%, %buildDir%

; Compile help.

; Move the executable and help file to the the build folder.

; Copy installer files to build
