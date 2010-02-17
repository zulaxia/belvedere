contains(Subject, Object)
{
	IfInString, Subject, %Object%
		result := true
	else
		result := false

	return result
}

containsOneOf(Subject, Object)
{
	if Subject contains %Object%
		result := true
	else
		result := false

	return result
}

isEqual(Subject, Object)
{
	if (Subject = Object)
		result := true
	else
		result := false

	return result
}

isOneOf(Subject, Object)
{
	if Subject in %Object%
		result := true
	else
		result := false

	return result
}

isGreaterThan(Subject, Object)
{
	if (Subject > Object)
		result := true
	else
		result := false

	return result
}

isGreaterThanEqual(Subject, Object)
{
	if (Subject >= Object)
		result := true
	else
		result := false

	return result
}

isLessThan(Subject, Object)
{
	if (Subject < Object)
		result := true
	else
		result := false

	return result
}

isLessThanEqual(Subject, Object)
{
	if (Subject <= Object)
		result := true
	else
		result := false

	return result
}

isInTheLast(Subject, Object)
{
	global thisRule
	IniRead, Units, rules.ini, %thisRule%, Units
	if (Units = "ERROR")
	{
		global testUnits
		Units = %testUnits%
	}

	EnvSub, Time, %Subject%, s
	if (Units = "minutes")
	{
		if ((Time/60) < Object)
			result := true
		else
			result := false
	}
	else if (Units = "hours")
	{
		if ((Time/3600) < Object)
			result := true
		else
			result := false
	}
	else if (Units = "days")
	{
		if ((Time/86400) < Object)
			result := true
		else
			result := false
	}
	else if (Units = "weeks")
	{
		if ((Time/604800) < Object)
			result := true
		else
			result := false
	}

	return result
}

RegEx(Subject, Object)
{
	MatchPos := RegExMatch(Subject, Object)
	if MatchPos
		result := true
	else
		result := false
	
	return result
}
