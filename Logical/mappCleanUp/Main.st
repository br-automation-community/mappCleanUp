
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	CASE State OF
		CLEANUP_WAIT:
			CleanUp.Status := ERR_OK;
			
			DevMemInfo_0.enable := FALSE;
			DevMemInfo_0();
			DirInfo_0.enable := FALSE;
			DirInfo_0();
			DirOpen_0.enable := FALSE;
			DirOpen_0();
			DirReadEx_0.enable := FALSE;
			DirReadEx_0();
			DirClose_0.enable := FALSE;
			DirClose_0();
			FileDelete_0.enable := FALSE;
			FileDelete_0();

			// Command delete oldest file
			IF EDGEPOS(CleanUp.CMD.DeleteOldest) THEN
				// Reset variables
				brsmemset(ADR(CleanUp.DAT), 0, SIZEOF(CleanUp.DAT));
				brsmemset(ADR(FileInformation), 0, SIZEOF(FileInformation));

				// Set callbacks and status
				StateAfterInfo := CLEANUP_DIR_INFO;
				StateAfterRead := CLEANUP_DELETE_OLDEST;
				StateAfterDelete := CLEANUP_DIR_CLOSE;
				CleanUp.Status := ERR_FUB_BUSY;
				
				State := CLEANUP_MEM_INFO;			
			END_IF
			
			// Command delete oldest than
			IF EDGEPOS(CleanUp.CMD.DeleteOlderThan) THEN
				IF CleanUp.PAR.OlderThan <> DT#1970-01-01-00:00:00 THEN
					// Reset variables
					brsmemset(ADR(CleanUp.DAT), 0, SIZEOF(CleanUp.DAT));
					brsmemset(ADR(FileInformation), 0, SIZEOF(FileInformation));

					// Set callbacks and status
					StateAfterInfo := CLEANUP_DIR_INFO;
					StateAfterRead := CLEANUP_DELETE_OLDER_THAN;
					StateAfterDelete := CLEANUP_DIR_READ;
					CleanUp.Status := ERR_FUB_BUSY;
					
					State := CLEANUP_MEM_INFO;
				ELSE
					State := CreateError(ADR(CleanUp), CLEANUP_ERR_PAR_IS_EMPTY, 'parameter >OlderThan< was not set', State, ADR(Logger));
				END_IF
			END_IF
			
			// Command delete files and keep x
			IF EDGEPOS(CleanUp.CMD.DeleteMaxFiles) THEN
				IF CleanUp.PAR.MaxFilesToKeep <> 0 THEN
					// Reset variables
					brsmemset(ADR(CleanUp.DAT), 0, SIZEOF(CleanUp.DAT));
					brsmemset(ADR(FileInformation), 0, SIZEOF(FileInformation));
					SimFileCount := 0;

					// Set callbacks and status
					StateAfterInfo := CLEANUP_DIR_INFO;
					StateAfterRead := CLEANUP_DELETE_MAX_FILES_1;
					StateAfterDelete := CLEANUP_DELETE_MAX_FILES_2;					
					
					CleanUp.Status := ERR_FUB_BUSY;
					
					State := CLEANUP_MEM_INFO;
				ELSE
					State := CreateError(ADR(CleanUp), CLEANUP_ERR_PAR_IS_EMPTY, 'parameter >MaxFilesToKeep< was not set', State, ADR(Logger));
				END_IF
			END_IF
			
			// Command delete files until minimum memory is restored
			IF EDGEPOS(CleanUp.CMD.DeleteMinSpace) THEN
				IF CleanUp.PAR.MinSpace <> 0 THEN
					// Reset variables
					brsmemset(ADR(CleanUp.DAT), 0, SIZEOF(CleanUp.DAT));
					brsmemset(ADR(FileInformation), 0, SIZEOF(FileInformation));
					SimMemCount := 0;

					// Set callbacks and status
					StateAfterInfo := CLEANUP_DIR_INFO;
					StateAfterRead := CLEANUP_DELETE_MIN_SPACE_1;
					StateAfterDelete := CLEANUP_DELETE_MIN_SPACE_2;					
					
					CleanUp.Status := ERR_FUB_BUSY;
					
					State := CLEANUP_MEM_INFO;
				ELSE
					State := CreateError(ADR(CleanUp), CLEANUP_ERR_PAR_IS_EMPTY, 'parameter >MinSpace< was not set', State, ADR(Logger));
				END_IF
			END_IF
			
			// Command update free space
			IF EDGEPOS(CleanUp.CMD.UpdateFreeSpace) THEN
				// Set callbacks
				StateAfterInfo := CLEANUP_WAIT;
				
				State := CLEANUP_MEM_INFO;
			END_IF

			// -------------------------------------------------------------------------------------------
			// Get device information
		CLEANUP_MEM_INFO:
			DevMemInfo_0.enable := TRUE;
			DevMemInfo_0.pDevice := ADR(CleanUp.PAR.Device);
			DevMemInfo_0();
		
			// Memory information successful
			IF DevMemInfo_0.status = ERR_OK THEN
				CleanUp.DAT.FreeSpace := DevMemInfo_0.freemem + (SimMemCount * CleanUp.PAR.Simulate);
				
				// Go to next step
				State := StateAfterInfo;
					
			// Error
			ELSIF DevMemInfo_0.status <> ERR_FUB_BUSY THEN
				TmpStr1 := 'ERR memory info > ';
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Device));
				State := CreateError(ADR(CleanUp), DevMemInfo_0.status, TmpStr1, State, ADR(Logger));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Get folder information
		CLEANUP_DIR_INFO:
			DirInfo_0.enable := TRUE;
			DirInfo_0.pDevice := ADR(CleanUp.PAR.Device);
			DirInfo_0.pPath := ADR(CleanUp.PAR.Path);
			DirInfo_0();
		
			// Dir info successful
			IF DirInfo_0.status = ERR_OK THEN
				CleanUp.DAT.FilesCount := DirInfo_0.filenum;
				
				// Go to next step
				State := CLEANUP_DIR_OPEN;
					
			// Error
			ELSIF DirInfo_0.status <> ERR_FUB_BUSY THEN
				TmpStr1 := 'ERR dir info > ';
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Device));
				brsstrcat(ADR(TmpStr1), ADR(' with dir > '));
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Path));
				State := CreateError(ADR(CleanUp), DirInfo_0.status, TmpStr1, State, ADR(Logger));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Start reading folder
		CLEANUP_DIR_OPEN:
			DirOpen_0.enable := TRUE;
			DirOpen_0.pDevice := ADR(CleanUp.PAR.Device);
			DirOpen_0.pName := ADR(CleanUp.PAR.Path);
			DirOpen_0();
		
			// Dir open successful
			IF DirOpen_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'open device > ';
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Device));
				brsstrcat(ADR(TmpStr1), ADR(' with dir > '));
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Path));
				CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));
									
				// Go to next step
				State := CLEANUP_DIR_READ;
					
				// Error
			ELSIF DirOpen_0.status <> ERR_FUB_BUSY THEN
				TmpStr1 := 'ERR open device > ';
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Device));
				brsstrcat(ADR(TmpStr1), ADR(' with dir > '));
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Path));
				State := CreateError(ADR(CleanUp), DirOpen_0.status, TmpStr1, State, ADR(Logger));
			END_IF
		
			// -------------------------------------------------------------------------------------------
			// Start reading folder
		CLEANUP_DIR_READ:		
			DirReadEx_0.enable := TRUE;
			DirReadEx_0.ident := DirOpen_0.ident;
			DirReadEx_0.pData := ADR(FileDirInfo);
			DirReadEx_0.data_len := SIZEOF(FileDirInfo);
			DirReadEx_0();
		
			// New file found
			IF DirReadEx_0.status = ERR_OK AND FileDirInfo.Mode = fiFILE THEN
				IF brsstrcmp(ADR(FileDirInfo.Filename), ADR('.')) <> 0 AND brsstrcmp(ADR(FileDirInfo.Filename), ADR('..')) <> 0 THEN			
					
					// Check if file name matches pattern
					IF IsInstr(ADR(FileDirInfo.Filename), ADR(CleanUp.PAR.Pattern)) OR CleanUp.PAR.Pattern = '' THEN
						// Generate log entry
						TmpStr1 := 'found file > ';
						brsstrcat(ADR(TmpStr1), ADR(FileDirInfo.Filename));
						CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));

						// Go to next state
						State := StateAfterRead;
					ELSE
						// Generate log entry
						TmpStr1 := 'file does not match pattern > ';
						brsstrcat(ADR(TmpStr1), ADR(FileDirInfo.Filename));
						CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));
					END_IF
					
					DirReadEx_0.enable := FALSE;
					DirReadEx_0();

				END_IF
	
			// No more entries
			ELSIF DirReadEx_0.status = fiERR_NO_MORE_ENTRIES THEN
				// Generate log entry
				CreateLoggerEntry(ADR('no more files found '), ADR(Logger));
					
				// Go to next state
				State := StateAfterRead;
					
				// Error
			ELSIF DirReadEx_0.status <> ERR_OK AND DirReadEx_0.status <> ERR_FUB_BUSY THEN
				TmpStr1 := 'ERR open file > ';
				brsstrcat(ADR(TmpStr1), ADR(FileDirInfo.Filename));
				State := CreateError(ADR(CleanUp), DirReadEx_0.status, TmpStr1, State, ADR(Logger));
			END_IF
		
			// -------------------------------------------------------------------------------------------
			// Delete oldest file
		CLEANUP_DELETE_OLDEST:
			// Evaluate next file
			IF DirReadEx_0.status <> fiERR_NO_MORE_ENTRIES THEN
				// File must be older than last
				IF FileInformation.Date > FileDirInfo.Date OR FileInformation.Date = DT#1970-01-01-00:00:00 THEN
					// Pretend that files were delete in simulation mode
					IF CleanUp.PAR.Simulate AND i < SIZEOF(CleanUp.DAT.FilesList)/SIZEOF(CleanUp.DAT.FilesList[0]) THEN
						i := 0;
						WHILE i <= CleanUp.DAT.FilesDeleted DO
							IF brsstrcmp(ADR(CleanUp.DAT.FilesList[i]), ADR(FileDirInfo.Filename)) = 0 THEN
								EXIT;
							END_IF
							i := i + 1;
						END_WHILE;
					ELSE
						i := CleanUp.DAT.FilesDeleted + 1;
					END_IF
					IF i = CleanUp.DAT.FilesDeleted + 1 THEN
						FileInformation := FileDirInfo;
					END_IF
				END_IF
				State := CLEANUP_DIR_READ;
				
			// Delete oldest file
			ELSE
				// Make sure we found at least one entry
				IF FileInformation.Date <> DT#1970-01-01-00:00:00 THEN
					// Fake simulation values
					IF CleanUp.PAR.Simulate THEN
						SimFileCount := SimFileCount + 1;
						SimMemCount := SimMemCount + FileInformation.Filelength;
					END_IF
					brsstrcpy(ADR(FileDeleteName), ADR(FileInformation.Filename));
					State := CLEANUP_FILE_DELETE;
				ELSE
					// Create error when there are not enough files to delete
					IF CleanUp.CMD.DeleteMinSpace AND DevMemInfo_0.freemem + SimMemCount < CleanUp.PAR.MinSpace THEN
						State := CreateError(ADR(CleanUp), CLEANUP_ERR_MIN_SPACE, 'Minimum space could not be achieved', State, ADR(Logger));
					ELSIF CleanUp.CMD.DeleteMaxFiles AND DirInfo_0.filenum - SimFileCount > CleanUp.PAR.MaxFilesToKeep THEN
						State := CreateError(ADR(CleanUp), CLEANUP_ERR_MIN_FILES, 'Minimum file count could not be achieved', State, ADR(Logger));
					ELSE
						State := CLEANUP_DIR_CLOSE;
					END_IF
				END_IF
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Delete files older than x
		CLEANUP_DELETE_OLDER_THAN:
			// Read next file, remember oldest file
			IF DirReadEx_0.status <> fiERR_NO_MORE_ENTRIES THEN 
				IF FileDirInfo.Date > CleanUp.PAR.OlderThan THEN
					brsstrcpy(ADR(FileDeleteName), ADR(FileDirInfo.Filename));
					FileInformation := FileDirInfo;
					State := CLEANUP_FILE_DELETE;
				ELSE
					State := CLEANUP_DIR_READ;					
				END_IF
				
				// Finish deleting old files
			ELSE
				State := CLEANUP_DIR_CLOSE;
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Delete files and keep x
		CLEANUP_DELETE_MAX_FILES_1:
			// Read next file, remember oldest file
			IF DirInfo_0.filenum - SimFileCount > CleanUp.PAR.MaxFilesToKeep THEN
				StateAfterRead := CLEANUP_DELETE_OLDEST;
				State := CLEANUP_DELETE_OLDEST;			

			// Finish deleting old files
			ELSE
				State := CLEANUP_DIR_CLOSE;
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Delete files and keep x
		CLEANUP_DELETE_MAX_FILES_2:
			brsmemset(ADR(FileInformation), 0, SIZEOF(FileInformation));
			DirInfo_0.enable := FALSE;
			DirInfo_0();
			
			StateAfterRead := CLEANUP_DELETE_MAX_FILES_1;
			State := CLEANUP_DIR_INFO;
		
			// -------------------------------------------------------------------------------------------
			// Delete files until minimum free space is restored
		CLEANUP_DELETE_MIN_SPACE_1:
			// Read next file, remember oldest file
			IF DevMemInfo_0.freemem + SimMemCount < CleanUp.PAR.MinSpace THEN
				StateAfterRead := CLEANUP_DELETE_OLDEST;
				State := CLEANUP_DELETE_OLDEST;			
			
			// Finish deleting old files
			ELSE
				State := CLEANUP_DIR_CLOSE;
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Delete files until minimum free space is restored
		CLEANUP_DELETE_MIN_SPACE_2:
			brsmemset(ADR(FileInformation), 0, SIZEOF(FileInformation));
			DirInfo_0.enable := FALSE;
			DirInfo_0();
			
			StateAfterRead := CLEANUP_DELETE_MIN_SPACE_1;
			State := CLEANUP_MEM_INFO;
			
			// -------------------------------------------------------------------------------------------
			// Close dir read
		CLEANUP_DIR_CLOSE:
			DirClose_0.enable := TRUE;
			DirClose_0.ident := DirOpen_0.ident;
			DirClose_0();
		
			// Directory closed successful
			IF DirClose_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'close dir ok > ';
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Path));
				CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));
				
				
				StateAfterInfo := CLEANUP_WAIT;
				State := CLEANUP_MEM_INFO;
											
				// Error
			ELSIF DirClose_0.status <> ERR_FUB_BUSY THEN
				TmpStr1 := 'ERR open file > ';
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Path));
				State := CreateError(ADR(CleanUp), DirClose_0.status, TmpStr1, State, ADR(Logger));
			END_IF
		
			// -------------------------------------------------------------------------------------------
			// Delete file
		CLEANUP_FILE_DELETE:
			// Make sure file and path fit into string
			IF brsstrlen(ADR(FileDeleteName)) + brsstrlen(ADR(CleanUp.PAR.Path)) <= FILE_NAME_LEN THEN
				// Create full file name path
				TmpStr2 := CleanUp.PAR.Path;
				brsstrcat(ADR(TmpStr2), ADR('\\'));
				brsstrcat(ADR(TmpStr2), ADR(FileDeleteName));
				
				// Delete file
				FileDelete_0.enable := NOT CleanUp.PAR.Simulate;
				FileDelete_0.pDevice := ADR(CleanUp.PAR.Device);
				FileDelete_0.pName := ADR(TmpStr2);
				FileDelete_0();
		
				// File delete successful
				IF FileDelete_0.status = ERR_OK OR CleanUp.PAR.Simulate THEN
					FileDelete_0.enable := FALSE;
					FileDelete_0();

					// Generate log entry
					IF CleanUp.PAR.Simulate THEN
						TmpStr1 := 'sim delete file ok > ';
					ELSE
						TmpStr1 := 'delete file ok > ';
					END_IF
					brsstrcat(ADR(TmpStr1), ADR(FileDeleteName));
					CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));
					
					// Remember deleted files name and count
					IF CleanUp.DAT.FilesDeleted < SIZEOF(CleanUp.DAT.FilesList)/SIZEOF(CleanUp.DAT.FilesList[0]) THEN
						CleanUp.DAT.FilesList[CleanUp.DAT.FilesDeleted] := FileDeleteName;
					END_IF
					CleanUp.DAT.FilesDeleted := CleanUp.DAT.FilesDeleted + 1;
					
					State := StateAfterDelete;
					
					// Error
				ELSIF FileDelete_0.status <> ERR_FUB_BUSY THEN
					TmpStr1 := 'ERR delete file > ';
					brsstrcat(ADR(TmpStr1), ADR(FileDeleteName));
					State := CreateError(ADR(CleanUp), FileDelete_0.status, TmpStr1, State, ADR(Logger));
				END_IF
				
			// File name and path are too long
			ELSE
				TmpStr1 := 'ERR file name is too long > ';
				brsstrcat(ADR(TmpStr1), ADR(FileDeleteName));
				State := CreateError(ADR(CleanUp), CLEANUP_ERR_FILE_NAME_TO_LONG, FileDeleteName, State, ADR(Logger));
			END_IF

			// -------------------------------------------------------------------------------------------
			// Error state
		CLEANUP_ERR:
			IF CleanUp.CMD.ErrorReset THEN
				brsmemset(ADR(CleanUp.ERR), 0, SIZEOF(CleanUp.ERR));
			
				State := CLEANUP_WAIT;
			END_IF
	END_CASE;
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

