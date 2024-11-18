
TYPE
	mappCleanUpType : 	STRUCT 
		CMD : mappCleanUpCmdType;
		PAR : mappCleanUpParType;
		DAT : mappCleanUpDatType;
		ERR : mappCleanUpErrType;
		StatusNo : UINT;
	END_STRUCT;
	mappCleanUpCmdType : 	STRUCT 
		DeleteMaxFiles : BOOL;
		DeleteMinSpace : BOOL;
		DeleteOldest : BOOL;
		DeleteOlderThan : BOOL;
		ErrorReset : BOOL;
	END_STRUCT;
	mappCleanUpParType : 	STRUCT 
		Simulate : BOOL; (*Files are only listed but not acutually deleted*)
		Device : STRING[80]; (*Device name*)
		Path : STRING[200]; (*Path to files*)
		MaxFilesToKeep : UINT; (*Maximum number of files to keep*)
		MinSpace : UDINT; (*Delete files until minimum space is available*)
		OlderThan : DATE_AND_TIME; (*Delete all files older than this date*)
	END_STRUCT;
	mappCleanUpDatType : 	STRUCT 
		FilesList : ARRAY[0..9]OF STRING[20]; (*List of files that were deleted*)
		FilesDeleted : UINT; (*Number of files that were deleted*)
	END_STRUCT;
	mappCleanUpErrType : 	STRUCT 
		State : CLEANUP_STATE;
		Text : STRING[200];
	END_STRUCT;
	CLEANUP_STATE : 
		(
		CLEANUP_WAIT,
		CLEANUP_DIR_OPEN,
		CLEANUP_DIR_READ,
		CLEANUP_DIR_CLOSE,
		CLEANUP_DELETE_OLDEST,
		CLEANUP_FILE_DELETE,
		CLEANUP_ERR
		);
END_TYPE
