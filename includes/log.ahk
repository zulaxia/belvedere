Log(LogString, Type)
{
	global
	if (EnableLogging = 1)
	{
		if( (Type = "System" or Type = "Action") and LogType = "Both")
		{
			StringUpper, Type, Type
			FormatTime, TimeString , , yyyy-MM-dd hh:mm:ss
			FileAppend, %TimeString% %Type% %LogString% `n,  %LogFile%
		}
		else if (Type = "System" and LogType = "System")
		{
			FormatTime, TimeString , , yyyy-MM-dd hh:mm:ss
			FileAppend, %TimeString% SYSTEM %LogString% `n,  %LogFile%
		}
		else if (Type = "Action" and LogType = "Actions")
		{
			FormatTime, TimeString , , yyyy-MM-dd hh:mm:ss
			FileAppend, %TimeString% ACTION %LogString% `n,  %LogFile%
		}
	}
}
