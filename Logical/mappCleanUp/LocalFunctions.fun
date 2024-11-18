
FUNCTION CreateError : CLEANUP_STATE
	VAR_INPUT
		CleanUp : REFERENCE TO mappCleanUpType;
		No : UINT;
		Text : STRING[200];
		State : CLEANUP_STATE;
		Logger : UDINT;
	END_VAR
END_FUNCTION

FUNCTION CreateLoggerEntry : USINT
	VAR_INPUT
		LogMsg : UDINT; (*Log message*)
		LogBuffer : UDINT; (*Address of log buffer*)
	END_VAR
	VAR
		RtcGettime : RTCtime_typ;
		TmpStr : STRING[20];
		LastMsg : STRING[STRING_LEN];
	END_VAR
END_FUNCTION
