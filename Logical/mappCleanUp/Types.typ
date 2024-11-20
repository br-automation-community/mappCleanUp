
TYPE
	mappCleanUpType : 	STRUCT 
		CMD : mappCleanUpCmdType;
		PAR : mappCleanUpParType;
		DAT : mappCleanUpDatType;
		ERR : mappCleanUpErrType;
		Status : UINT;
	END_STRUCT;
	mappCleanUpCmdType : 	STRUCT 
		DeleteMaxFiles : BOOL;
		DeleteMinSpace : BOOL;
		DeleteOldest : BOOL;
		DeleteOlderThan : BOOL;
		UpdateFreeSpace : BOOL;
		ErrorReset : BOOL;
	END_STRUCT;
	mappCleanUpParType : 	STRUCT 
		Simulate : BOOL; (*Files are only listed but not acutually deleted*)
		Device : STRING[80]; (*Device name*)
		Path : STRING[200]; (*Path to files*)
		MaxFilesToKeep : UINT; (*Maximum number of files to keep*)
		MinSpace : UDINT; (*Delete files until minimum space is available*)
		OlderThan : DATE_AND_TIME; (*Delete all files older than this date*)
		Pattern : STRING[80]; (*File must match this pattern (ex. .pdf or .csv)*)
	END_STRUCT;
	mappCleanUpDatType : 	STRUCT 
		FilesList : ARRAY[0..9]OF STRING[50]; (*List of files that were deleted*)
		FilesDeleted : UINT; (*Number of files that were deleted*)
		FilesCount : UDINT; (*Number of files that were deleted*)
		FreeSpace : UDINT;
	END_STRUCT;
	mappCleanUpErrType : 	STRUCT 
		State : CLEANUP_STATE;
		Text : STRING[200];
	END_STRUCT;
	CLEANUP_STATE : 
		(
		CLEANUP_WAIT,
		CLEANUP_MEM_INFO,
		CLEANUP_DIR_INFO,
		CLEANUP_DIR_OPEN,
		CLEANUP_DIR_READ,
		CLEANUP_DIR_CLOSE,
		CLEANUP_DELETE_OLDEST,
		CLEANUP_DELETE_OLDER_THAN,
		CLEANUP_DELETE_MAX_FILES_1,
		CLEANUP_DELETE_MAX_FILES_2,
		CLEANUP_DELETE_MIN_SPACE_1,
		CLEANUP_DELETE_MIN_SPACE_2,
		CLEANUP_FILE_DELETE,
		CLEANUP_ERR
		);
END_TYPE
