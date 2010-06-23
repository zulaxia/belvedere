delete(file)
{
	FileDelete, %file%
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

move(file, destination, overwrite, compress, shortcut)
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
		FileMove, %file%, %destination%, %overwrite%
		if ErrorLevel
			return ErrorLevel
		else
			return 0
	}
}

copy(file, destination, overwrite, compress)
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
rename(file, template)
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
	zipname := name . ".zip"
	RunWait, %A_ScriptDir%\resources\7za.exe a "%directory%\%zipname%" "%directory%\%fullname%",,hide
	
	ifExist, %directory%\%zipname%
		FileDelete, %directory%\%fullname%
}

addtoitunes(file)
{
	COM_Init() ;Initalize the COM module
	iTunes := COM_CreateObject("iTunes.Application") ;Connect to iTunes. This will Also open iTunes automatically if its not already open
	if (iTunes = 0)
		return -1 ;iTunes is not installed
		
	iTunesLibrary := COM_Invoke(iTunes, "LibraryPlaylist")
	if (iTunesLibrary = 0)
		return -2 ;unable to retrieve library
	
	iTunesFile := COM_Invoke(iTunesLibrary, "AddFile", file)
	if (iTunesFile = 0)
		return -3 ;unable to add file
		
	COM_Release(iTunes)
	COM_Term()
}
