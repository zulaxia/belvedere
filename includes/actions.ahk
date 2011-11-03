delete(file, attributes)
{
	IfInString, Attributes, D
		FileRemoveDir, %file%, 1
	else
		FileDelete, %file%
		
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

move(file, destination, overwrite, compress, shortcut, attributes)
{
	global thisRule
	global errorCheck
	
	SplitPath, file,fullname,directory,, name
	zipname := name . ".zip"
	scname := directory . "\" . name . ".lnk"
	newfile = %destination%\%fullname%
	
	IfNotExist, %destination%
		return -1 ;missing destination folder

	if (shortcut = 1)
		FileCreateShortcut, %newfile%, %scname%
	
	if (compress = 1)
	{		
		if (overwrite = 1)
		{
			IfInString, Attributes, D
				FileMoveDir, %file%, %destination%\%name%, %overwrite%+1
			else
				FileMove, %file%, %destination%, %overwrite%
			
			if ErrorLevel
			{
				return ErrorLevel
			}
			else
			{
				compressFile(newfile)
				return 0
			}
		}
		else
		{
			IfNotExist, %destination%\%zipname%
			{
				IfInString, Attributes, D
					FileMoveDir, %file%, %destination%\%name%, %overwrite%
				else
					FileMove, %file%, %destination%, %overwrite%
				
				if ErrorLevel
				{
					return ErrorLevel
				}
				else
				{
					compressFile(newfile)
					return 0
				}
			}
		}
	}
	else
	{
		IfInString, Attributes, D
			FileMoveDir, %file%, %destination%\%name%, 2
		else
			FileMove, %file%, %destination%, %overwrite%
		
		if ErrorLevel
			return ErrorLevel
		else
			return 0
	}
}

copy(file, destination, overwrite, compress, attributes)
{
	global thisRule
	global errorCheck
	
	SplitPath, file,fullname,,, name
	zipname := name . ".zip"
	newfile = %destination%\%fullname%

	IfNotExist, %destination%
		return -1 ;missing destination folder	

	if (compress = 1)
	{		
		if (overwrite = 1)
		{
			IfInString, Attributes, D
				FileCopyDir, %file%, %destination%\%name%, %overwrite%
			else
				FileCopy, %file%, %destination%, %overwrite%
			if ErrorLevel
			{
				return ErrorLevel
			}
			else
			{
				compressFile(newfile)
				return 0
			}
		}
		else
		{
			IfNotExist, %destination%\%zipname%
			{
				IfInString, Attributes, D
					FileCopyDir, %file%, %destination%\%name%, %overwrite%
				else
					FileCopy, %file%, %destination%, %overwrite%
				if ErrorLevel
				{
					return ErrorLevel
				}
				else
				{
					compressFile(newfile)
					return 0
				}
			}
		}
	}
	else
	{
		IfInString, Attributes, D
			FileCopyDir, %file%, %destination%\%name%, %overwrite%
		else
			FileCopy, %file%, %destination%, %overwrite%
			
		if ErrorLevel
			return ErrorLevel
		else
			return 0
	}
}

;approach and code inspired by Lightning Renamer
; written by no1readsthese
; http://www.autohotkey.com/forum/topic29448.html
rename(file, template, attributes)
{
	SplitPath, file, fullname, directory, extension, name_no_ext, drive
	extension := "." extension
	
	;Replace all known template items
	StringReplace, template, template, [filename], %name_no_ext%, ALL
	StringReplace, template, template, [fullname], %fullname%, ALL
	StringReplace, template, template, [ext], %extension%, ALL
	StringReplace, template, template, [drive], %drive%, ALL
	StringReplace, template, template, [YYYY], %A_YYYY%, ALL
	StringReplace, template, template, [MM], %A_MM%, ALL
	StringReplace, template, template, [DD], %A_DD%, ALL
	StringReplace, template, template, [MMMM], %A_MMMM%, ALL
	StringReplace, template, template, [MMM], %A_MMM%, ALL
	StringReplace, template, template, [DDDD], %A_DDDD%, ALL
	StringReplace, template, template, [DDD], %A_DDD%, ALL
	StringReplace, template, template, [WDay], %A_WDay%, ALL
	StringReplace, template, template, [YDay], %A_YDay%, ALL
	StringReplace, template, template, [YWeek], %A_YWeek%, ALL
	StringReplace, template, template, [hh], %A_Hour%, ALL
	StringReplace, template, template, [mm], %A_Min%, ALL
	StringReplace, template, template, [ss], %A_Sec%, ALL
	StringReplace, template, template, [ms], %A_MSec%, ALL
	StringReplace, template, template, [DT], %A_Now%, ALL
	StringReplace, template, template, [DT-UTC], %A_NowUTC%, ALL

	;Remove all illegal characters
	StringReplace, template, template, \,, All
	StringReplace, template, template, /,, All
	StringReplace, template, template, :,, All
	StringReplace, template, template, ?,, All
	StringReplace, template, template, <,, All
	StringReplace, template, template, >,, All
	StringReplace, template, template, *,, All
	StringReplace, template, template, |,, All
	StringReplace, template, template, ",, All ;"

	IfInString, Attributes, D
		FileMoveDir, %file%, %directory%\%template%
	else	
		FileMove, %file%, %directory%\%template%
	
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

recycle(file)
{
	FileRecycle, %file%
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

open(file)
{
	Run, %file%,,UseErrorLevel
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

print(file)
{
	Run, print %file%,,Hide UseErrorLevel
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

custom(file, destination)
{
	Run, %destination% %file%,,hide
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

compressFile(file)
{
	SplitPath, file,fullname,directory,, name
	FileGetAttrib, Attributes, %file%
	zipname := name . ".zip"
	RunWait, %A_ScriptDir%\resources\7za.exe a "%directory%\%zipname%" "%directory%\%fullname%",,hide
	
	ifExist, %directory%\%zipname%
	{
		IfInString, Attributes, D
			FileRemoveDir, %directory%\%fullname%, 1
		else
			FileDelete, %directory%\%fullname%
		
	}
}
