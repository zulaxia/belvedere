delete(file)
{
	FileDelete, %file%
}

move(file, destination, overwrite, compress)
{
	global thisRule
	global errorCheck
	
	SplitPath, file,fullname,,, name
	zipname := name . ".zip"
	newfile = %destination%\%fullname%
	
	IfExist, %destination%
	{
		if (compress = 1)
		{		
			if (overwrite = 1)
			{
				FileMove, %file%, %destination%, %overwrite%
				compressFile(newfile)
			}
			else
			{
				IfNotExist, %destination%\%zipname%
				{
					FileMove, %file%, %destination%, %overwrite%
					compressFile(newfile)
				}
			}
		}
		else
		{
			FileMove, %file%, %destination%, %overwrite%
		}
	}
	else
	{
		Msgbox,,Missing Folder,A folder you're attempting to move files to does not exist.`n Check your "%thisRule%" rule and verify that %destination% exists.
		errorCheck := 1
	}
}

copy(file, destination, overwrite, compress)
{
	global thisRule
	global errorCheck
	
	SplitPath, file,fullname,,, name
	zipname := name . ".zip"
	newfile = %destination%\%fullname%
	
	IfExist, %destination%
	{
		if (compress = 1)
		{		
			if (overwrite = 1)
			{
				FileCopy, %file%, %destination%, %overwrite%
				compressFile(newfile)
			}
			else
			{
				IfNotExist, %destination%\%zipname%
				{
					FileCopy, %file%, %destination%, %overwrite%
					compressFile(newfile)
				}
			}
		}
		else
		{
			FileCopy, %file%, %destination%, %overwrite%
		}
	}
	else
	{
		Msgbox,,Missing Folder,A folder you're attempting to copy files to does not exist.`n Check your "%thisRule%" rule and verify that %destination% exists.
		errorCheck := 1
	}
}

recycle(file)
{
	FileRecycle, %file%
}

compressFile(file)
{
	SplitPath, file,fullname,directory,, name
	zipname := name . ".zip"
	RunWait, %A_ScriptDir%\resources\7za.exe a "%directory%\%zipname%" "%directory%\%fullname%"
	
	ifExist, %directory%\%zipname%
		FileDelete, %directory%\%fullname%
}
