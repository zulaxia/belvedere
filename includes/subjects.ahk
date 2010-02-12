getName(file)
{
	SplitPath, file,,,,fileNameNoExt
	return fileNameNoExt
}

getExtension(file)
{
	StringCaseSense, Off
	SplitPath, file,,,extension
	return extension
}

getSize(file)
{
	global thisRule
	IniRead, Units, rules.ini, %thisRule%, Units
	FileGetSize, fileSize, %file%
	if (Units = "KB")
	{
		fileSize := fileSize/1024 
	}
	if (Units = "MB")
	{
		fileSize := fileSize/1048576
	}
	return fileSize
}

getDateLastOpened(file)
{
	FileGetTime, lastAccess, %file%, A
	return lastAccess
}

getDateLastModified(file)
{
	FileGetTime, lastModified, %file%, M
	return lastModified
}

getDateCreated(file)
{
	FileGetTime, created, %file%, C
	return created
}

getLargest(folder)
{
	LargestFile := 0
	Filename :=
	Loop, %folder%*.*, , 1
	{
		if (A_LoopFileSize > LargestFile)
		{
			LargestFile := A_LoopFileSize
			Filename := A_LoopFileLongPath
		}
	}
	return Filename
}

getSmallest(folder)
{
	SmallestFile := 9999999999999
	Filename :=
	Loop, %folder%*.*, , 1
	{
		if (A_LoopFileSize < SmallestFile)
		{
			SmallestFile := A_LoopFileSize
			Filename := A_LoopFileLongPath
		}
	}
	return Filename
}

getOldest(folder)
{
	OldestFile := 0
	Filename :=
	Loop, %folder%*.*, , 1
	{
		if (A_LoopFileTimeAccessed > OldestFile)
		{
			OldestFile := A_LoopFileTimeAccessed
			Filename := A_LoopFileLongPath
		}
	}
	return Filename
}

getYoungest(folder)
{
	youngestFile := 30000000000000
	Filename :=
	Loop, %folder%*.*, , 1
	{
		if (A_LoopFileTimeAccessed < youngestFile)
		{
			youngestFile := A_LoopFileTimeAccessed
			Filename := A_LoopFileLongPath
		}
	}
	return Filename
}

getRBSize(folder, Units)
{
	;Determine the Size of the RB in bytes
	FolderSize:= 0
	Loop, C:\RECYCLER\%SID%\*.*, , 1
	{
		FolderSize += %A_LoopFileSize%
	}
	
	If (Units = "KB")
	{
		return FolderSize/1024
	}
	else if (Units = "MB")
	{
		return FolderSize/1048576
	}
	else if (Units = "GB")
	{
		return FolderSize/1073741824
	}
}
