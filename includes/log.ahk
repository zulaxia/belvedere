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

Notify(String, Type)
{
	global
	if (GrowlEnabled = 1)
	{
		Title = Belvedere %Type% Message
		RunWait, %A_ScriptDir%\resources\growlnotify.exe /a:"Belvedere" /n:%Type% /t:"%Title%" "%String%"
	}
}
