delete(file)
{
	FileDelete, %file%
	if ErrorLevel
		return ErrorLevel
	else
		return 0
}

move(file, destination, overwrite, compress)
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

compressFile(file)
{
	SplitPath, file,fullname,directory,, name
	zipname := name . ".zip"
	RunWait, %A_ScriptDir%\resources\7za.exe a "%directory%\%zipname%" "%directory%\%fullname%",,hide
	
	ifExist, %directory%\%zipname%
		FileDelete, %directory%\%fullname%
}
