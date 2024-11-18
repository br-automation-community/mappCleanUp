
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	CASE State OF
		CLEANUP_WAIT:
			DirOpen_0.enable := FALSE;
			DirOpen_0();
			DirReadEx_0.enable := FALSE;
			DirReadEx_0();
			DirClose_0.enable := FALSE;
			DirClose_0();

			// Command delete oldest file
			IF EDGEPOS(CleanUp.CMD.DeleteOldest) THEN				
				SateAfterRead := CLEANUP_DELETE_OLDEST;
				SateAfterDelete := CLEANUP_DIR_CLOSE;
				
				State := CLEANUP_DIR_OPEN;			
			END_IF

			// -------------------------------------------------------------------------------------------
			// Start reading folder
		CLEANUP_DIR_OPEN:
			DirOpen_0.enable := TRUE;
			DirOpen_0.pDevice := ADR(CleanUp.PAR.Device);
			DirOpen_0.pName := ADR(CleanUp.PAR.Path);
			DirOpen_0();
		
			// File created successful
			IF DirOpen_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'open device > ';
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Device));
				brsstrcat(ADR(TmpStr1), ADR(' with dir > '));
				brsstrcat(ADR(TmpStr1), ADR(CleanUp.PAR.Path));
				CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));
				
				// Reset variables
				brsmemset(ADR(CleanUp.DAT), 0, SIZEOF(CleanUp.DAT));
				brsmemset(ADR(FileInformation), 0, SIZEOF(FileInformation));
					
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
					// Generate log entry
					TmpStr1 := 'found file > ';
					brsstrcat(ADR(TmpStr1), ADR(FileDirInfo.Filename));
					CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));
					
					// Go to next state
					State := SateAfterRead;

					DirReadEx_0.enable := FALSE;
					DirReadEx_0();

				END_IF
	
				// No more entries
			ELSIF DirReadEx_0.status = fiERR_NO_MORE_ENTRIES THEN
				// Generate log entry
				TmpStr1 := 'no more files found ';
				brsstrcat(ADR(TmpStr1), ADR(FileDirInfo.Filename));
				CreateLoggerEntry(ADR(TmpStr1), ADR(Logger));
					
				// Go to next state
				State := SateAfterRead;
					
				// Error
			ELSIF DirReadEx_0.status <> ERR_OK AND DirReadEx_0.status <> ERR_FUB_BUSY THEN
				TmpStr1 := 'ERR open file > ';
				brsstrcat(ADR(TmpStr1), ADR(FileDirInfo.Filename));
				State := CreateError(ADR(CleanUp), DirReadEx_0.status, TmpStr1, State, ADR(Logger));
			END_IF
		
			// -------------------------------------------------------------------------------------------
			// Delete oldest file
		CLEANUP_DELETE_OLDEST:
			// Read next file, remember oldest file
			IF DirReadEx_0.status <> fiERR_NO_MORE_ENTRIES THEN 
				IF FileInformation.Date > FileDirInfo.Date OR FileInformation.Date = DT#1970-01-01-00:00:00 THEN
					FileInformation := FileDirInfo;
				END_IF
				State := CLEANUP_DIR_READ;
				
			// Delete oldest file
			ELSE
				brsstrcpy(ADR(FileDeleteName), ADR(FileInformation.Filename));
				State := CLEANUP_FILE_DELETE;
			END_IF
		
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
					
				State := CLEANUP_WAIT;
											
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
					
					State := SateAfterDelete;
					
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

