// -------------------------------------------------------------------------------------------
// Create error
// -------------------------------------------------------------------------------------------
FUNCTION CreateError
	CleanUp.Status := No;
	CleanUp.ERR.State := State;
	CleanUp.ERR.Text := Text;
	
	CreateLoggerEntry(ADR(Text), Logger);
	
	CreateError := CLEANUP_ERR;
END_FUNCTION

// -------------------------------------------------------------------------------------------
// Is second string in first string																		
// -------------------------------------------------------------------------------------------
FUNCTION IsInstr
	IF (brsstrlen(string1) > brsstrlen(string2)) THEN
		FOR idx:=0 TO brsstrlen(string1) - brsstrlen(string2) DO
			IF (brsmemcmp(string1 + idx, string2, brsstrlen(string2)) = 0) THEN
				IsInstr := TRUE;
				EXIT;
			END_IF
		END_FOR;
	END_IF
END_FUNCTION

// -------------------------------------------------------------------------------------------
// Handle log buffer
// -------------------------------------------------------------------------------------------
FUNCTION CreateLoggerEntry
	IF LogBuffer = 0 THEN
		RETURN;		
	END_IF	
	// Make sure log message fits
	IF brsstrlen(LogMsg) > LOG_LEN - 20 THEN
		brsstrcpy(LogMsg, ADR('*** log meassage exceeds maximum length ***'));
		RETURN;
	END_IF
	// Check previous message
	IF brsstrlen(LogBuffer) > 19 THEN
		brsstrcpy(ADR(LastMsg), LogBuffer + 19);
	END_IF

	// Make sure we dont flood Logger
	IF brsstrcmp(LogMsg, ADR(LastMsg)) <> 0 AND LogBuffer <> 0 THEN
		// Move ring buffer around
		brsmemmove(LogBuffer+LOG_LEN+1, LogBuffer, LOG_LEN*(LOG_NUM-1));
		brsstrcpy(LogBuffer, ADR(''));
		// Create time information
		RTC_gettime(ADR(RtcGettime)); 
		IF(RtcGettime.day < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.day, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsitoa(RtcGettime.day, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR('.'));
		IF(RtcGettime.month < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.month, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(' '));
		IF(RtcGettime.hour < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.hour, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(':'));
		IF(RtcGettime.minute < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.minute, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(':'));
		IF(RtcGettime.second < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.second, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR('.'));
		IF(RtcGettime.millisec < 10) THEN
			brsstrcat(LogBuffer, ADR('00'));
		ELSIF(RtcGettime.millisec < 100) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.millisec, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		// Add log message
		brsstrcat(LogBuffer, ADR(' '));
		brsstrcat(LogBuffer, LogMsg);
	END_IF

	CreateLoggerEntry := TRUE;
END_FUNCTION