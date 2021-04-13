; logging class taken from https://www.autohotkey.com/boards/viewtopic.php?t=50663

class LogClass
{ ; Class that handles writing to a log file
	; This class makes working with a log file much easier.  Once created, you can write to a log file with a single method call.
	; Each instance of the object supports a single log file (and its inactive older versions).  To use multiple log files (with separate names) create multiple instances.
	; The log files will be tidied up and rotated automatically.
	; The current log will be titled with just the base filename (e.g., MyLogFile.log) with older, inactive log files being named with a trailing index (e.g., MyLogFile_1.log, MyLogFile_2.log).  Newer files having a higher index.  
	; Log files may be limited by size, and when the threshold is reached the file will be moved to an inactive/indexed filename and a new log started.  
	;
	; A brief usage example is as follows:
	;	global log := new LogClass(“MyLogFile”)
	;	log.initalizeNewLogFile(false, “Header text to appear at the start of the new file”)
	;	log.addLogEntry(“Your 1st message to put in the log file”)
	;	log.addLogEntry(“Your next message to put in the log file”)
	;	log.finalizeLog(“Footer text to appear at the very end of your log, which you are done with.”)
	;
	; This LogClass is inspired (very much so) by the pre-AHK built-in classes (circa 2009) file Log.ahk
	; by Ben McClure, and found at
	; From: https://autohotkey.com/board/topic/37953-class-log-logging-and-log-file-management-library/
	; Ben's Log.ahk required the Class.ahk, Vector.ahk, and String.ahk which are no longer available (and outdated), and hence was a dead piece of code.
	;
	; The <name>String properties (e.g., preEntryString, HeaderString, etc.) may be set via initalizeNewLogFile() or individually.  
	; They are strings that will be applied automatically when creating/ending a log file, or adding a new log message/entry.  This allows you to apply a common format (or information) to every logfile or log entry.
	; The String properties all accept variables which may be expanded when written.
		; * $time or %A_Now% expands to the time the log entry is written (as formatted according to this.logsTimeFormat).
		; * $printStack expands to a list of the function calls which caused the log entry to be written.
		; * %Var% expands to whatever value variable Var is, but Var must be a global/built-in variable.
	; These String property variables may be used in the log entries too (e.g., by this.addLogEntry(entry))
	; (c) 2018 Ahbi Santini


	__New(aLogBaseFilename, aMaxNumbOldLogs=0, aMaxSizeMBLogFile=-1, aLogDir="", aLogExten="")
	{
		; Input variables
		; 	aLogBaseFilename -> 1/3 of the log's full filename (filename -> aLogDir\aLogBaseFilename.aLogExten)
		; 	                    Note: If aLogBaseFilename is blank (e.g., ""), then the ScriptName without the exten is used (e.g., "MyScript.ahk" results in a base name of "MyScript"), which is probably the easiest.
		; 	                    Note: If aLogBaseFilename is fully pathed (e.g., C:\Logs\MyLogFile.log) aLogDir and aLogExten are ignored.
		; 	aMaxNumbOldLogs -> The maximum number of old log files to keep when rotating/tidying up the log files.  -1 is infinite.  0 (the default) will not create any indexed (e.g., MyLogFile_1.log) files.
		; 	aMaxSizeMBLogFile -> The maximum size (in megabytes) before a log file is automatically closed and rotated to a new file.  0 or less is infinite (the default).  
		; 	aLogDir -> 1/3 of the log's full filename (filename -> aLogDir\aLogBaseFilename.aLogExten).  The default is A_WorkingDir.
		; 	aLogExten -> 1/3 of the log's full filename (filename -> aLogDir\aLogBaseFilename.aLogExten).  The default is "log".
		
		this._classVersion := "2018-09-07"
		
		; CONSTANTS
		; establish any default values (These defaults aren't supposed to be user editable. Treat them as programmer's Internal-Use-Only configuration constants)
		this.maxNumbOldLogs_Default     := 0  ; -1 is infinite, 0 is only the current file (NOTE: If initalizeNewLogFile(overwriteExistingFile = -1) this is pretty much ignored except for tidy())
		this.maxSizeMBLogFile_Default   := -1 ; 0 or less than (-1) is unlimited size
		this.logDir_Default             := A_WorkingDir
		this.logExten_Default           := "log"
		this.logsFileEncoding_Default   := "UTF-8"
		this.logsTimeFormat_Default     := "yyyy-MM-dd hh:mm:ss tt"
		this.preEntryString_Default     := ""
		this.postEntryString_Default    := ""
		this.headerString_Default       := ""
		this.footerString_Default       := ""
		this.useRecycleBin_Default      := true
		this.printStackMaxDepth_Default := 5 ; maximum number of parent function calls to include the PrintStack function
		this.isAutoWriteEntries_Default := true
		this.dividerString_Default      := ""

		; actual working variables
		; initialize any properties (not received as inputs)
		this.logsFileEncoding      := this.logsFileEncoding_Default
		this.logsTimeFormat        := this.logsTimeFormat_Default
		this.preEntryString        := this.preEntryString_Default
		this.postEntryString       := this.postEntryString_Default
		this.headerString          := this.headerString_Default
		this.footerString          := this.footerString_Default
		this.useRecycleBin         := this.useRecycleBin_Default
		this.printStackMaxDepth    := this.printStackMaxDepth_Default
		this.isAutoWriteEntries    := this.isAutoWriteEntries_Default
		this.isLogClassTurnedOff   := false
		this._pendingEntries       := []
		this._ignorePendingEntries := false
		this.dividerString         := this.createDividerString("-", 70, true)
		; this.scriptEnvReport       := this.createScriptEnvReport() ; this actually has to be run last or else it doesn't have the values set properly

		; Error checking done in property get/set
		this.maxNumbOldLogs := aMaxNumbOldLogs
		this.maxSizeMBLogFile := aMaxSizeMBLogFile 

		; now error check the filename input values
		if(aLogDir="")
			aLogDir := this.logDir_Default
		if(aLogExten="")
			aLogExten := this.logExten_Default
		if(aLogBaseFilename="")
		{ ; use the ScriptName without the extension (i.e., *.ahk or *.exe)
			SplitPath, A_ScriptFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			aLogBaseFilename := OutNameNoExt
		}
		else if(this.isFilenameFullyPathed(aLogBaseFilename))
		{ ; ignore the other given filename inputs
			SplitPath, aLogBaseFilename, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			aLogDir := OutDir ; overwrite any aLogDir we were given as input
			aLogExten := OutExtension  ; overwrite any aLogExten we were given as input
			aLogBaseFilename := OutNameNoExt ; now it looks like the normal aLogDir . "\" . aLogBaseFilename . "." aLogExten triplet
		}

		; put the filename parts together
		this._currentFileName_FullPath := aLogDir . "\" . aLogBaseFilename . "." . aLogExten

		; this actually has to be run last or else it doesn't have the values set properly
		this.scriptEnvReport       := this.createScriptEnvReport()
		return this
	}
	
	; Properties
	; ---------------------------------------------
	;BeginRegion
	
	classVersion
	{ ; (Read-Only)  Just the revision/version number of this class
		get
		{
			return this._classVersion
		}
	}

	; List
	; -------------------
	; currentFileName_FullPath ; (Read-Only) The current log filename, in full path form.  All other filename related properties read/write to this as the master/keeper of the filename 
	; preEntryString           ; A string to prepend (before) to any log entry (made via addLogEntry()).
	; postEntryString          ; A string to append (after) to any log entry (made via addLogEntry()).
	; headerString             ; A string to be placed at the start of every new logfile (made via initalizeNewLogFile()).
	; footerString             ; A string to be placed at the end of every new logfile (made via finalizeLog()).
	; logsFileEncoding         ; The encoding for the logfile (see AHK help page on FileEncoding).  The default is UTF-8
	; logsTimeFormat           ; The format that $time or %A_Now% will be expanded to (see AHK help page on FormatTime).  The default is "yyyy-MM-dd hh:mm:ss tt"
	; maxNumbOldLogs           ; The maximum number of old (i.e., indexed; e.g., MyLogFile_1.log) files to keep when rotating/cleaning the logs.  (NOTE: If initalizeNewLogFile(overwriteExistingFile = -1) this is pretty much ignored except for tidy())
	; maxSizeMBLogFile         ; The maximum size (in megabytes) of the log file before a new file is automatically created.  The size is not super-strict.  If you really try you can break this, especially is headerString creates a file bigger than your size limit.
	; useRecycleBin            ; Should deleted files be deleted or moved to the RecycleBin?  The default is true (to the Recycle Bin).
	; isAutoWriteEntries       ; New log entries can be written immediately (the default), or saved up in the pendingEntries array (to be written later).  Useful if you want to limit the number of times a logfile is edited in a given time period (e.g., if your logfile is in a cloud synched folder).  If changed (to true) while entries are pending, they will all be written on next addLogEntry().
	; isLogClassTurnedOff      ; When true, pretty much every function instantly exits ** with NO error value ** (so no entries may be added/files moved).  (The default is: false).  Useful for turning off logging ability, especially when your addLogEntry() calls are buried deep in some class/function and you don't want to hunt them down and comment them out.
	; printStackMaxDepth       ; When expanding the String property variable $printStack how far back in call chain should be reported?  The default is 5
	; dividerString            ; a default string to use as a divider sting.  Created and (may be) set by this.createDividerString()
	; scriptEnvReport          ; a default string that can be used as the headerString.  Created and (may be) set by this.createScriptEnvReport()
	; _pendingEntries[]        ; (Internal use only)  The array of unwritten log entries.
	; _ignorePendingEntries    ; (Internal use only)  If when writing the unwritten log entries a new file needs to be created (due to size), this flags initalizeNewLogFile()/finalizeLog() to not reset the pendingEntries[]

	; not yet implemented (and maybe never will be)
	; maxNumbLogEntries ; before a new logfile
	; numberCurrentLogEntries ; (includes pending) read-only
	; maxPendingEntries ; don't let pending entries get out of control
	
	maxNumbOldLogs
	{ ; The maximum number of old (i.e., indexed; e.g., MyLogFile_1.log) files to keep when rotating/cleaning the logs
		get
		{
			return this._maxNumbOldLogs
		}
		set
		{
			; -1 is infinite, 0 is only the current file
			aMaxNumbOldLogs:= value
			if aMaxNumbOldLogs is not integer
			{
				aMaxNumbOldLogs := this.maxNumbOldLogs_Default
				; Note this default is a constant (as much as AHK has them) and set via New()
			}
			return this._maxNumbOldLogs := aMaxNumbOldLogs 
		}
	}
	
	maxSizeMBLogFile
	{ ; The maximum size (in megabytes) of the log file before a new file is automatically created.  The size is not super-strict.  If you really try you can break this, especially is headerString creates a file bigger than your size limit.
		get
		{
			return this._maxSizeMBLogFile
		}
		set
		{ ; 0 or less than (-1) is unlimited size
			
			aMaxSizeMBLogFile:= value
			if aMaxSizeMBLogFile is not number
			{ 
				aMaxSizeMBLogFile := this.maxSizeMBLogFile_Default
				; Note this default is a constant (as much as AHK has them) and set via New()
			}
			if (aMaxSizeMBLogFile = 0 ) 
			{ ; a value of 0 can be confusing, set it to -1 which means the same thing (infinite size)
				aMaxSizeMBLogFile := -1
			}
			return this._maxSizeMBLogFile := aMaxSizeMBLogFile 
		}
	}
	
	printStackMaxDepth
	{ ; When expanding the String property variable $printStack how far back in call chain should be reported?  The default is 5
		get
		{
			return this._printStackMaxDepth
		}
		set
		{
			aPrintStackMaxDepth:= value
			if aPrintStackMaxDepth is not digit
			{
				aPrintStackMaxDepth := this.printStackMaxDepth_Default
				; Note this default is a constant (as much as AHK has them) and set via New()
			}
			return this._printStackMaxDepth := aPrintStackMaxDepth 
		}
	}
	
	;EndRegion

	; Pseudo-Properties (actually functions that look like properties)
	; ---------------------------------------------
	;BeginRegion
	
	baseFileName
	{ ; (Read-Only) The current log file's filename w/o extension or trailing index (e.g., MyLogFile_1.log would be "MyLogFile").
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutNameNoExt
		}
		set
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutNameNoExt
		}
	}
	
	currentFileName
	{ ; (Read-Only) The current log file's filename, w/o path information.
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutFileName
		}
		set
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutFileName
		}
	}
	
	currentFileName_FullPath
	{ ; (Read-Only) The current log file's filename, w/ path information.  This property is set via New()
		get
		{
			return this._currentFileName_FullPath
		}
		set
		{
			return this._currentFileName_FullPath
		}
	}
	
	logDir
	{ ; (Read-Only) The current log file's directory.
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutDir
		}
		set
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutDir
		}
	}
	
	logExten
	{ ; (Read-Only) The current log file's extension (e.g., *.log).  
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutExtension
		}
		set
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutExtension
		}
	}

	;EndRegion
	
	
	
	; Methods (of suitable importance)
	; ---------------------------------------------
	;BeginRegion
	
	initalizeNewLogFile(overwriteExistingFile=0, aHeaderString="UNDEF", aPreEntryString="UNDEF", aPostEntryString="UNDEF", aFooterString="UNDEF", aLogsFileEncoding="UNDEF")
	{ ; Start a new log file, and set (if given) any of the predefined string properties. This method will rotate/move any old log files, as needed.  For the Header/Footer isAutoWriteEntries is ignored (always instantly writes)
	; Input variables
	; 	overwriteExistingFile (-1,0, or 1) -> should a pre-existing log file be appended to (-1), a new file created (0), or overwritten (1) ... (creating as new file moves the older files to the end; e.g., MyLogFile_1.log)?
	; 	aHeaderString     -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aPreEntryString   -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aPostEntryString  -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aFooterString     -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aLogsFileEncoding -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
	
		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aLogDir := this.logDir
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := false
		
		; UNDEF is used so the properties may have a "" value
		if(aHeaderString != "UNDEF")
			this.headerString := aHeaderString
		if(aPreEntryString != "UNDEF")
			this.preEntryString := aPreEntryString
		if(aPostEntryString != "UNDEF")
			this.postEntryString := aPostEntryString
		if(aFooterString != "UNDEF")
			this.footerString := aFooterString
		if(aLogsFileEncoding != "UNDEF")
			this.logsFileEncoding := aLogsFileEncoding
		if(!this._ignorePendingEntries)
			this._pendingEntries := []
		this._ignorePendingEntries := false ; reset IgnoreVal regardless if it was set or not

		if (!InStr(FileExist(aLogDir), "D"))
		{ ; check if Dir exits
			FileCreateDir, %aLogDir%
			errLvl := ErrorLevel
		}
		else if( FileExist(aCurrentFileName_FullPath) )
		{ ; if the Dir exists, check if the file exists and handle accordingly
			if (overwriteExistingFile == 1)
			{
				FileDelete, %aCurrentFileName_FullPath%
				errLvl := ErrorLevel
			}
			else if (overwriteExistingFile == 0)
			{
				errLvl += this.moveLog()
				errLvl += this.tidyLogs()
			}
			else ; (overwriteExistingFile == -1)
			{
				; append to file
			}
		}
		
		if(!errLvl)
		{ ; now write the header string
			aLogFileEncoding := this.logsFileEncoding
			aHeaderString := this.headerString
			aHeaderString := this.transformStringVars(aHeaderString) ; expand any variables in the string
			; write automatically regardless of this.isAutoWriteEntries
			; if aHeaderString=="", you're essentially touching the file (unix's touch command)
			errLvl := this.appendFile(aHeaderString, aCurrentFileName_FullPath, aLogFileEncoding, false)
		}
		return errLvl
	}
	
	finalizeLog(aFooterString="UNDEF", willTidyLogs=true)
	{ ; End a  log file, and set (if given) the predefined string property. This method will rotate/move any old log files, as needed.  For the Header/Footer isAutoWriteEntries is ignored (always instantly writes)
		; Note: "End" should not be confused with File.close().  File.close() is done every time an entry is written to the log file.  We're not sitting here with an open File the entire time you're using the LogClass. 
	; Input variables
	; 	aFooterString -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file or initalizeNewLogFile())
	; 	willTidyLogs  -> Should the function run tidyLog() or not.  Set to False if you want to save the log file and append to it next time.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
	
		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		errLvl := false
		aLogDir := this.logDir
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		aMaxNumbOldLogs := this.maxNumbOldLogs

		; UNDEF is used so the properties may have a "" value
		if(aFooterString != "UNDEF")
			this.footerString := aFooterString
		
		if (!InStr(FileExist(aLogDir), "D"))
		{ ; check if Dir exits
			FileCreateDir, %aLogDir%
			errLvl := ErrorLevel
		}

		if(!errLvl)
		{ ; write any pending entries & footer to the file
			if(!this._ignorePendingEntries)
			{ ; if this got called do to a log exceeding its size limit, we'll saving the pending entries for the next log file
				errLvl := this.savePendingEntriesToLog()
				; if a large enough number of entries are pending multiple log files may be written
			}
			
			aLogFileEncoding := this.logsFileEncoding
			aFooterString := this.footerString
			aFooterString := this.transformStringVars(aFooterString)
			; write automatically regardless of this.isAutoWriteEntries
			errLvl += this.appendFile(aFooterString, aCurrentFileName_FullPath, aLogFileEncoding)
		}

		; clean up the multiple log files
		if( (aMaxNumbOldLogs > 0) && (willTidyLogs) )
		{ ; if we only have 1 log file, then leave it alone, also leave alone if you wish to append to a large log file (which can create new if the size exceeds the max).
			errLvl += this.moveLog()
			errLvl += this.tidyLogs()
		}
		
		this._ignorePendingEntries := false ; reset IgnoreVal regardless if it was set or not
		return errLvl
	}
	
	addLogEntry(entryString="", addNewLine=true, usePreEntryString=true, usePostEntryString=true)
	{ ; Adds a new entry (string) to the log file (or pending entries array, see aIsAutoWriteEntries).  Creates the entry as preEntryString . entryString . postEntryString
	; The <name>String properties (e.g., preEntryString, HeaderString, etc.) may be set via initalizeNewLogFile() or individually.  
	; They are strings that will be applied automatically when creating/ending a log file or adding a new log message/entry.  This allows you to apply a common format (or information) to every logfile or log entry.
	; The String properties all accept variables which may be expanded when written.
		; * $time or %A_Now% expands to the time the log entry is written (as formatted according to this.logsTimeFormat).
		; * $printStack expands to a list of the function calls which caused the log entry to be written.
		; * %Var% expands to whatever value variable Var is, but Var must be a global/built-in variable.
	; These String property variables may be used in entryString too
	; -----------------
	; Input variables
	; 	entryString          -> The string you wish to write to the log.  Will be pre/post-appended as dictated by the other inputs
	; 	addNewLine (Boolean) -> Should a "`n" be added to the end of entryString or not (useful if use 1-line entries)?  Default is true.
	; 	usePreEntryString (Boolean) -> Should preEntryString by added before entryString?  Default is true.
	; 	usePostEntryString (Boolean) -> Should postEntryString by added after entryString?  Default is true.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)

		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aPreEntryString := this.preEntryString
		aPostEntryString := this.postEntryString
		aIsAutoWriteEntries := this.isAutoWriteEntries
		errLvl := false

		; transform (unpack the variables) in each string
		; then concatenate them together, as desired
		entryString := this.transformStringVars(entryString)
		if(usePreEntryString)
		{
			aPreEntryString := this.transformStringVars(aPreEntryString)
			entryString := aPreEntryString . entryString
		}
		if(addNewLine)
		{
			entryString := entryString . "`n"
		}
		if(usePostEntryString)
		{
			aPostEntryString := this.transformStringVars(aPostEntryString)
			entryString := entryString . aPostEntryString
		}
		
		; now add the entry to file/array
		; add everything to the array, then if auto writing, write out the array
		retVal := this._pendingEntries.push(entryString) ; God I love push/pop. I don't know why but I have loved those 2 functions for decades now.
		if(aIsAutoWriteEntries) 
		{ ; if auto writing, write out the array
			errLvl := this.savePendingEntriesToLog()
		}
		return errLvl
	}
	
	savePendingEntriesToLog()
	{ ; Writes the pending entries to the log file, creating more log files if needed
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aLogDir := this.logDir
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		aLogFileEncoding := this.logsFileEncoding
		aMaxSizeMBLogFile := this.maxSizeMBLogFile
		errLvl := false

		if (!InStr(FileExist(aLogDir), "D"))
		{ ; check if Dir exits
			FileCreateDir, %aLogDir%
			errLvl := ErrorLevel
		}
		
		if(!errLvl)
		{
			arrayLength := this._pendingEntries.length()
			Loop, %arrayLength% ; this should be a contiguous array 
			{ ; start writing out the array
				; is the log file too big to add more to it?
				if(aMaxSizeMBLogFile > 0) ; < or = 0 is unlimited size
				{
					if(FileExist(aCurrentFileName_FullPath)) ; FileGetSize fails if the file doesn't exist
					{ 
						FileGetSize, logSize, %aCurrentFileName_FullPath% ; get in bytes because the K & M options return integers and this annoys me
						if(!ErrorLevel) 
						{
							logSizeMB := this.byteToMB(logSize)
							if(logSizeMB > aMaxSizeMBLogFile)
							{  ; close the file and start a new one
								this._ignorePendingEntries := true ; don't let finalizeLog()/initalizeNewLogFile() clear the array (array := [])
								errLvl += this.finalizeLog()
								this._ignorePendingEntries := true ; this got cleared by finalizeLog()
								errLvl += this.initalizeNewLogFile() ; this does move & tidy too
							}
						}
					}
				}
				
				; write the next entry
				minIndex := this._pendingEntries.MinIndex() ; rename for easier handling
				entryString := this._pendingEntries.RemoveAt(minIndex) ; I want this to be called shift().  If I have push/pop, I want shift/unshift. :(
				try {
					; I know this.appendFile() has a very similar name to the old FileAppend command
					; but this.appendFile() is really using the File.Write() object (unless you changed it)
					errLvl += this.appendFile(entryString, aCurrentFileName_FullPath, aLogFileEncoding)
				} catch e {
					
					; sometimes the file can be written to too quickly, if you're pounding it with new entries
					; try again after a rest
					; hopefully moving to the File Object (from FileAppend) solves this
					MsgBox, 16,, % "Before we try again...`nUnable to write to log file!" "`n" "`t" "(Possibly written to too fast?)" "`n`n" "Filename: " aCurrentFileName_FullPath "`n" "LogEntry: " entryString "`n" "Exception.message: " e.message "`n" "Exception.Extra: " e.extra "`n`n`n" "------------------" "`n" . this.printStack(10)
					Sleep 500
					try {
						errLvl += this.appendFile(entryString, aCurrentFileName_FullPath, aLogFileEncoding)
					} catch e {
						MsgBox, 16,, % "Unable to write to log file!" "`n" "`t" "(Possibly written to too fast?)" "`n`n" "Filename: " aCurrentFileName_FullPath "`n" "LogEntry: " entryString "`n" "Exception.message: " e.message "`n" "Exception.Extra: " e.extra "`n`n`n" "------------------" "`n" . this.printStack(10)
					}
				}
			}
		}
		return errLvl
	}

	moveLog(aNewLogFilename="", aNewLogDir="", overwriteExistingFile=false)
	{ ; Moves the current log to a new filename.  Will place it at the end of the index chain (e.g., MyLogFile_1.log), or to the name given via input variables.
	; Input variables
	; 	aNewLogFilename -> The filename to move current log to.  If blank, will place it at the end of the index chain (e.g., MyLogFile_1.log).  If a fully pathed filename, aNewLogDir is ignored.
	; 	aNewLogDir      -> The directory to move current log to.  The full filename's path will be aNewLogDir\aNewLogFilename (unless the caveats described above apply)
	; 	overwriteExistingFile (Boolean) -> Should any existing files be overwritten?  
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)

	if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aCurrentFileName_FullPath := this.currentFileName_FullPath ; source file
		errLvl := false

		; check that the source file actually exists
		errLvl := !FileExist(aCurrentFileName_FullPath)
		if(!errLvl)
		{
			; now error check the input values
			if(this.isFilenameFullyPathed(aNewLogFilename))
			{
				SplitPath, aNewLogFilename, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
				aNewLogDir := OutDir ; overwrite any aNewLogDir we were given as input
				aNewLogFilename := OutFileName ; now it looks like the normal aNewLogDir . "\" . aNewLogFilename pair
			}
			else if (aNewLogDir = "")
			{ ; if aNew is fully pathed, this will be skipped
				aNewLogDir := this.logDir
			}

			if (!InStr(FileExist(aNewLogDir), "D"))
			{ ; check if Dir exits
				FileCreateDir, %aNewLogDir%
				errLvl := ErrorLevel
			}
			
			if(!errLvl)
			{
				if(aNewLogFilename = "") ; destination file
				{ ; if "", move log to end of A_Index chain (e.g., MyLogFile_1.log)
					SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
					
					Loop
					{
						candidateFilename := aNewLogDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
						if (!FileExist(candidateFilename))
							break
					}
					aNewLogFilename_FullPath := candidateFilename ; set to whichever candidate won
				}
				else
				{ ; if != "", move to explicitly given destination file
					aNewLogFilename_FullPath := aNewLogDir . "\" . aNewLogFilename
				}
				
				; Move the file
				FileMove, %aCurrentFileName_FullPath%, %aNewLogFilename_FullPath%, %overwriteExistingFile%
				errLvl := ErrorLevel
			}
		}
		return errLvl
	}
	
	tidyLogs(aMaxNumbOldLogs="")
	{ ; Rotates logs (newest is highest in the index chain (e.g., MyLogFile_1.log)).  Deletes oldest logs (and re-numbers the less-old) until there are less than aMaxNumbOldLogs/maxNumbOldLogs.
	; Input variables
	; 	aMaxNumbOldLogs -> The maximum number of old log files to keep.  If not blank, sets this.maxNumbOldLogs.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)

		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aUseRecycleBin := this.useRecycleBin
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := 0

		if (aMaxNumbOldLogs = "")
			aMaxNumbOldLogs := this.maxNumbOldLogs
		
		if (aMaxNumbOldLogs >= 0) ; -1 means keep all old logs
		{
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			; count the number of files (yeah, a discontinuity in the numbering system breaks this (e.g., 1, 2, 3, 7, 8 ... will stop at 3)
			Loop
			{
				candidateFilename := OutDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
				doesExist := FileExist(candidateFilename)
				if (!doesExist)
					break
				totalNumbOldLogs := A_Index
			}

			; rotate/delete the files
			new_Index := 0
			if(totalNumbOldLogs > aMaxNumbOldLogs)
			{
				numbLogsToDelete := totalNumbOldLogs - aMaxNumbOldLogs
				Loop, %totalNumbOldLogs%
				{
					oldFilename := OutDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
					if(FileExist(oldFilename))
					{
						if(A_Index <= numbLogsToDelete)
						{ ; delete the older/lower numbered files (makes way for the next step)
							errLvl1 := this.deleteLog(oldFilename, aUseRecycleBin)
							errLvl := errLvl + errLvl1
						}
						else
						{ ; move the newer/higher numbered files to a lower number (they are now older)
							new_Index++
							newFilename := OutDir . "\" . OutNameNoExt . "_" . new_Index . "." OutExtension
							FileMove, %oldFilename%, %newFilename%, 1 ; overwrite if file still exists (will probably fail if that is the case, or else FileDelete would have handled it)
							errLvl := errLvl + ErrorLevel
						}
					}
				}
			}
		}
		return errLvl
	}
	
	deleteAllLogs(putInRecycleBin=true, useWildCard=true)
	{ ; Deletes all log files (using 1 of 2 methods). 
	; Input variables
	; 	putInRecycleBin -> switches between FileDelete and FileRecycle
	; 	useWildCard -> If false, will walk through log files until a numeric break is hit.  If true, will delete everything using a "baseName_*.exten" wildcard string.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := 0

		; delete the current file
		errLvl += this.deleteLog(aCurrentFileName_FullPath, putInRecycleBin)

		; delete all the old files
		errLvl += this.deleteAllOldLogs(putInRecycleBin, useWildCard)
		return errLvl
	}

	deleteAllOldLogs(putInRecycleBin=true, useWildCard=true)
	{ ; Deletes all OLD log files (using 1 of 2 methods). Will not delete the current log file.
	; Input variables
	; 	putInRecycleBin -> switches between FileDelete and FileRecycle
	; 	useWildCard -> If false, will walk through log files until a numeric break is hit.  If true, will delete everything using a "baseName_*.exten" wildcard string.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := 0

		; delete all the old files
		SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		if(useWildCard)
		{ ; the wildcard technique, which just deletes everything
			candidateFilename := OutDir . "\" . OutNameNoExt . "_" . "*" . "." OutExtension
			errLvl += this.deleteLog(candidateFilename, putInRecycleBin)
		}
		else
		{ ; the original walking technique which stops once you hit a discontinuity (which allows you to hide old files at high numbers)
			Loop
			{
				candidateFilename := OutDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
				doesExist := FileExist(candidateFilename)
				if (!doesExist)
					break
				errLvl += this.deleteLog(candidateFilename, putInRecycleBin)
			}
		}
		return errLvl
	}

	deleteLog(fileToDelete, putInRecycleBin=true)
	{ ; deletes/recycles a log (any file really)
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		errLvl := false
		
		doesExist := FileExist(fileToDelete)
		if (doesExist)
		{
			if(putInRecycleBin)
			{
				FileRecycle, %fileToDelete%
			}
			else
			{
				FileDelete, %fileToDelete%
			}
			errLvl := ErrorLevel
		}
		return errLvl
	}

	; addLogObject(entryObject="", addNewLine=true, usePreEntryString=true, usePostEntryString=true) 
	; { ; converts an Object to a String and then calls addLogEntry()
		; ; from nnnik
		; ; see https://autohotkey.com/boards/viewtopic.php?p=224955#p224955
		
		; ; !!!!!!!!!!! NOTICE !!!!!!!!!!!
		; ; until I put in a default method to do the conversion this.objectToString() this isn't going to work
		
		
		; return this.addLogEntry(this.objectToString(entryObject), addNewLine, usePreEntryString, usePostEntryString)
	; }

	; setObjectToString(objectToStringFunction)
	; { ;replaces the current function that's responsible for turning an object into a string with this one
		; ; So, if you have a toString() function in your object you're doing log entries of, you can either use:
		; ; 1. addLogEntry(obj.toString()) or 
		; ; 2. set setObjectToString(obj.toString()) and then call addLogObject(obj), which if you had multiple instantiations would be easier.
	
		; ; from nnnik
		; ; see https://autohotkey.com/boards/viewtopic.php?p=224955#p224955
		; This.objectToString := objectToStringFunction
		; return
	; }
	
	;EndRegion


	; Methods (helpers)
	; ---------------------------------------------
	;BeginRegion
	
	appendFile(text, filename, encoding, skipIfEmpty=true)
	{ ; a wrapper to FileAppend or its File Object equivalent (so much faster)
		errLvl := false
		USE_FILE_OBJECT := true

		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		if( (text == "") && (skipIfEmpty) )
		{
			; do not write if equal to ""
		}
		else
		{
			if(USE_FILE_OBJECT)
			{
				file := FileOpen(filename, "a" , encoding)
				if(file) ; no error occurred
				{
					bytesWritten := file.Write(text)
					file.Close()
					file := "" ; free up the object
					
					; error check: see if anything was written.  Tested that (text != ""), which would write no bytes.
					if( (bytesWritten == 0) && (text != "") )
					{
						errLvl := true
					}
				}
				else
				{
					errLvl := true
				}
			}
			else
			{
				FileAppend, %text%, %filename%, %encoding%
				errLvl := ErrorLevel
			}
		}
		return errLvl
	}
	
	createDividerString(char="-", length=70, includeNewLine=true, useAsProperty=false)
	{ ; create a string that repeats X times (e.g., "---------------" and can be used as a line or divider)
		outStr := ""
		Loop, %length%
		{
			outStr .= char
		}
		if(includeNewLine)
		{
			outStr .= "`n"
		}

		if(useAsProperty)
		{
			this.dividerString := outStr
		}
		return outStr
	}
	
	byteToMB(bytes, decimalPlaces=2)
	{ ; It converts bytes to megabytes (you expected something else?).  And limits things to X digits after the decimal place.
		kiloBytes := bytes / 1024.0
		megaBytes := kiloBytes / 1024.0
		megaBytes := round(megaBytes, decimalPlaces)

		return megaBytes
	}
	
	isFilenameFullyPathed(filename)
	{ ; determine if a filename has a relative path or starts at the root (i.e., fully pathed)
		SplitPath, filename, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		if(OutDrive != "")
			return true
		else
			return false
	}
	
	transformStringVars(encodedString)
	{ ; converts a variable (normal %var%, or made up for this class, $printStack) to whatever its value is (when this function is run)
	; The String properties all accept variables which may be expanded when written.
	; * $time or %A_Now% expands to the time the log entry is written (as formatted according to this.logsTimeFormat).
	; * $printStack expands to a list of the function calls which caused the log entry to be written.
	; * $printCalling expands to only the function which caused the log entry to be written. (A shorter version of $printStack)
	; * %Var% expands to whatever value variable Var is, but Var must be a global/built-in variable.
	; ------------------------
	; Input variables
	; 	encodedString -> A string, possibly with an encoded %var%/$var in it
	; Non-Input variables (that are relied upon in an important enough way that I should tell you about it).
	; 	this.logsTimeFormat -> The format that $time or %A_Now% will be expanded to (see AHK help page on FormatTime).  The default is "yyyy-MM-dd hh:mm:ss tt"
	; Output variables
	; 	plaintextString -> A string with any %var%/$var replaced by those variables values.

		aLogsTimeFormat := this.logsTimeFormat
		plaintextString := ""
		
		if(encodedString != "")
		{
			; Replace $time var
			if ( (InStr(encodedString, "$time")) OR (InStr(encodedString, "`%A_Now`%")) )
			{ ; $time is really a hold over from the (circa 2009) Log.ahk class.  %A_Now% is preferred.
				; Format the current time
				FormatTime, formattedTime, %A_Now%, %aLogsTimeFormat%
				encodedString := RegExReplace(encodedString, "\$time", formattedTime)
				encodedString := RegExReplace(encodedString, "\%A_Now\%", formattedTime)
			}

			; Expand %var%
			if (RegExMatch(encodedString,"%\w+%"))
			{ 
				; variables need to be ** global ** to be DeRef'ed
				Transform, encodedString, DeRef, %encodedString% ; convert any variables to actual values
			}

			; Replace $printStack var
			if (InStr(encodedString, "$printStack"))
			{ 
				depth := this.printStackMaxDepth
				skip := 2 ; skip transformStringVars() and printStack()
				encodedString := StrReplace(encodedString, "$printStack", this.printStack(depth, skip))
			}

			; Replace $printCalling var
			if (InStr(encodedString, "$printCalling"))
			{ 
				encodedString := StrReplace(encodedString, "$printCalling", this.printCalling())
			}

			; ; Replace $function() var
			; if ( (InStr(encodedString, "$function(")) OR (InStr(encodedString, "`%A_Now`%")) )
			{ ; uncommented to allow code folding (based on brackets)
				; I haven't figured out a way to expand a function call yet.  
				; I played with variadic functions, and pulling the function name & parameters then using x := %func%(params*), but I never could get it to work.
				; Plus if you had a string param with commas (,) in it (i.e., commas that should be ignored), the RegEx to properly grab the params would be tough.  I could default back to CSV processing techniques.
				; from my test.ahk file, as of the Nth attempt when I gave up and just made $printStack its own thing.
					; I got it to work with 1 param
						; filename := "D:\Handbrake\MKV"
						; testStr := "This is $function(isFilenameFullyPathed(" . filename . ")).  See what it did."
						; FoundPos := RegExMatch(testStr,"\$function\((.+)\((.+)\)\)", v)
						; tmpVar := %v1%(v2)
						; newStr := RegExReplace(testStr,"\$function\(.+\)", tmpVar)
						; msgbox, %newStr%
					; I never got it to work with 2+ params
						; filename := "D:\Handbrake\MKV"
						; cmd = MinMax
						; testStr := "This is $function(WinGet(cmd, filename)).  See what it did."
						; FoundPos := RegExMatch(testStr,"\$function\((.+)\((.+)\)\)", v)
						; numbArg := isFunc(v1) - 1
						; vArray := StrSplit(v2,",")
						; aLen := vArray.length()
						; Loop, aLen
						; {
							; arVal := vArray[A_Index]
							; bArray.Insert(%arVal%)
						; }
						; tmpVar := %v1%(bArray*)
						; tmpVar2 := WinGet(cmd, filename)
						; newStr := RegExReplace(testStr,"\$function\(.+\)", tmpVar)
						; tmpStr  =	
								; ( LTrim
									; TestStr: %testStr%
									; FoundPos: %FoundPos%
									; numbArg: %numbArg%
									; vArrayL: %aLen%
									; v1: %v1%
									; v2: %v2%
									; tmpVar: %tmpVar%
									; tmpVar2: %tmpVar2%
									; newStr: %newStr%
								; )
						; msgbox, %tmpStr%
			}

			; The (circa 2009) Log.ahk class used $title, but since he didn't write any examples of using $title I don't understand how it was to be used, and I don't have a property that supports it.  I have Header/FooterString to do what I think you might have used $title for, but don't really know.
			; ; Replace $title var
			; if (InStr(string, "$title")) {
				; ; Get saved title
				; if (title := Log_getTitle(LogObject))
					; string := RegExReplace(string, "\$title", title)
			; }
			
			; copy the now-expanded string to the output string
			plaintextString := encodedString
		}
		return plaintextString
	}

	printStack(maxNumbCalls=2000, numbCallsToSkipOver=1 )
	{ ; outputs a String detailing the parentage of functions that called this function
		; slightly modified from nnnik's excellent work at ..
		; https://autohotkey.com/boards/viewtopic.php?f=74&t=48740

		; if numbCallsToSkipOver=1, skip this printStack() since the work is done in generateStack()
		str := "Stack Print, most recent function calls first:`n"
		str .= "`t" . "Skipping over " . numbCallsToSkipOver . " calls and a maximum shown call depth of " . maxNumbCalls . ".`n"

		maxNumbCalls := maxNumbCalls + numbCallsToSkipOver
		stack := this.generateStack()
		for each, entry in stack
		{
			if(A_Index <= numbCallsToSkipOver)
			{ ; do nothing
			}
			else if(A_Index <= maxNumbCalls) 
			{ ; the default is 2000 which is likely every call (i.e. the for-loop will end first)
				str .= "Line: " . entry.line . "`tCalled: " . entry.what "`tFile: " entry.file "`n"
			}
			else
			{
				break
			}
		}
		return str
	}

	printCalling(maxNumbCalls=1, numbCallsToSkipOver=3)
	{ ; outputs a String detailing the parentage of functions that called this function
		; slightly modified from nnnik's excellent work at ..
		; https://autohotkey.com/boards/viewtopic.php?f=74&t=48740

		maxNumbCalls := maxNumbCalls + numbCallsToSkipOver
		stack := this.generateStack()
		for each, entry in stack
		{
			if(A_Index <= numbCallsToSkipOver)
			{ ; do nothing
			}
			else if(A_Index <= maxNumbCalls) 
			{ ; the default is 2000 which is likely every call (i.e. the for-loop will end first)
				str := entry.what . "(ln: " . entry.line . ")"
			}
			else
			{
				break
			}
		}
		return str
	}

	generateStack( offset := -1 )
	{ ;returns the call stack as an Array of exception objects - the first array is the function most recently called.
		; from nnnik's excellent work at ..
		; https://autohotkey.com/boards/viewtopic.php?f=74&t=48740
		if ( A_IsCompiled )
			Throw exception( "Cannot access stack with the exception function, as the script is compiled." )
		stack := []
		While ( exData := exception("", -(A_Index-offset)) ).what != -(A_Index-offset)
			stack.push( exData )
		return stack
	}
	
	createScriptEnvReport(useAsProperty=false)
	{ ; creates a large string that details the environment the script is running in
		lesserTab := ""
		Loop, 4
		{
			lesserTab .= A_Space
		}
		newlineChar := "`n"
		lineStr := this.dividerString
		if( (!InStr(lineStr, newlineChar)) && (StrLen(lineStr) != InStr(lineStr, newlineChar)) )
		{ ; add a newline to the divderString if there isn't one
			lineStr .= "`n"
		}
		
		; FileGetTime, OutputVar [, Filename, WhichTime]
		FileGetTime, ModTime, %A_ScriptFullPath%, M
		FormatTime, ModTime, ModTime, ddd MMM d, yyyy hh:mm:ss tt
		
		currentFileName_FullPath := this.currentFileName_FullPath ; the below doesn't like the this.var notation
		maxNumbOldLogs     := this.maxNumbOldLogs ; the below doesn't like the this.var notation
		maxSizeMBLogFile   := this.maxSizeMBLogFile ; the below doesn't like the this.var notation
		isAutoWriteEntries := this.boolean2String(this.isAutoWriteEntries, "Yes", "No")
		
		is64bitOS  := this.boolean2String(A_Is64bitOS, "Yes", "No")
		isCompiled := this.boolean2String(A_IsCompiled, "Yes", "No")
		isUnicode  := this.boolean2String(A_IsUnicode, "Yes", "No")
		isAdmin    := this.boolean2String(A_IsAdmin, "Yes", "No")
		
		url=https://api.ipify.org ; CHANGE ME, if this website stops working
		externalIPAddr := this.URLDownloadToVar(url)
		aLogsTimeFormat := this.logsTimeFormat
		FormatTime, formattedTime, %A_Now%, %aLogsTimeFormat%

		infoStr  =	
			( LTrim
			Script:    %A_ScriptName%
			Computer:  %A_ComputerName%
			User:      %A_UserName%
			Script Last Modified:  
			%lesserTab%%ModTime%
			
			Script Dir: 
			%lesserTab%%A_ScriptDir%
			Working Dir: 
			%lesserTab%%A_WorkingDir%
			
			Log Info: 
			%lesserTab%%currentFileName_FullPath%
			Maximum number of old logs:    %maxNumbOldLogs%
			Maximum size (MB) of logs:     %maxSizeMBLogFile%
			Write log entries immediately: %isAutoWriteEntries%

			AHK version:      %A_AhkVersion%
			OS version:       %A_OSVersion%
			is OS 64-bit:     %is64bitOS%
			is AHK Unicode:   %isUnicode%
			script Compiled:  %isCompiled%
			running as Admin: %isAdmin%

			External IP:    %externalIPAddr%%lesserTab%(at %formattedTime%)
			IP Address #1:  %A_IPAddress1%
			IP Address #2:  %A_IPAddress2%
			IP Address #3:  %A_IPAddress3%
			IP Address #4:  %A_IPAddress4%
			)

			scriptInfoString := lineStr . lineStr
			scriptInfoString .= infoStr . "`n"
			scriptInfoString .= lineStr . lineStr

		if(useAsProperty)
		{
			this.scriptEnvReport := scriptInfoString
		}
		return scriptInfoString
	}
	
	boolean2String(bool, trueVal="true", falseVal="false")
	{ ; just re-formats a boolean to a given string pair
		if(bool)
		{
			return trueVal
		}
		else
		{
			return falseVal
		}
	}

	URLDownloadToVar(url)
	{ ; downloads a URL to the return variable.  Returns "ERROR" if an error occurred.
		; url -> a fully formed URL (e.g., https://https://api.ipify.org)
	
		; see documentation for URLDownloadToFile()
		; https://autohotkey.com/docs/commands/URLDownloadToFile.htm
		; https://docs.microsoft.com/en-us/windows/desktop/winhttp/iwinhttprequest-interface
		
		retVal := "ERROR"
		try {
			hObject := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			hObject.Open("GET",url, true)
			hObject.Send()
			hObject.WaitForResponse()
			retVal := hObject.ResponseText
		}
		catch {
			; retVal := hObject.status
			retVal := "ERROR"
		}
		if (retVal == "")
		{
			retVal := "ERROR"
		}
		return retVal
	}
	
	objectToString(object) 
	{ ;turns an object into a string
		; from nnnik
		; see https://autohotkey.com/boards/viewtopic.php?p=224955#p224955

		; Disp(byref Obj, ShowBase=0, circularPrevent := "", indent := 0 )
		; {
			; try {
				; if !circularPrevent
					; circularPrevent := []
				; OutStr:=""
				; If !IsObject(Obj)
				; {
					; If ((Obj+0)=="")
					; {
						; If (IsByRef(Obj) && (StrPut(Obj)<<A_IsUnicode)<VarSetCapacity(Obj))
						; {
							; Loop % VarSetCapacity(Obj)
								; outstr.=Format("{1:02X} ",NumGet(Obj,A_Index-1,"UChar"))
							; msgbox test
							; return """" . outstr . """"
						; }
						; Else If (Strlen(obj)!="")
							; return """" . obj . """"
					; }
					; return Obj
				; }
				; If IsFunc(Obj)
					; return "func( """ . Obj.name . """ )"
				; if circularPrevent.hasKey( &Obj )
					; return  Format("Object(&{:#x})", &Obj) 
				; circularPrevent[&Obj] := 1
				; StartNum := 0
				; For Each in Obj {
					; If !(StartNum+1 = Each) {
						; NonNumeric:=1
						; break
					; }
					; StartNum := Each
				; }
				; If (NonNumeric) {
					; identStr := ""
					; indent++
					; Loop % indent
						; indentStr .= "`t"
					; For Each,Key in Obj
						; OutStr .= indentStr . Disp( noByRef( each ), ShowBase, circularPrevent, indent ) . ": " . Disp( noByRef(Key),ShowBase, circularPrevent, indent ) . ", `n"
					
					; StringTrimRight,outstr,outstr,3
					; If ( IsObject( ObjGetBase( Obj ) ) && ShowBase )
						; OutStr.= ( outStr ? ", `n" . indentStr : "" ) "base:" . Disp( obj.Base,ShowBase, circularPrevent, indent )
					; outstr:="`n" . subStr( indentStr, 1, -1 ) . Format("{`t = Object(&{:#x})`n", &Obj) . OutStr . "`n" . subStr( indentStr, 1, -1 ) . "}"
				; }
				; Else {
					; For Each,Key in Obj
						; OutStr .= Disp( noByRef(Key),ShowBase, circularPrevent, indent ) . ", "
					; StringTrimRight,outstr,outstr,2
					; outstr:="[" . OutStr . "]"
				; }
				; return outstr
			; }
			; catch e
				; return "Error(" e.what ", " e.message ")"
		; }
		; noByRef( var ) {
			; return var
		; }
		
		return "ERROR"
	}


	;EndRegion
	
	; Revision History
	; ---------------------------------------------
	;BeginRegion
	; 2018-09-07
	; * Support for writing to the same log file over multiple runs of the script (i.e., appending to an existing log file)
	;   * initalizeNewLogFile(overwriteExistingFile=0) overwriteExistingFile is now -1, 0 or 1 where -1 means "append to an existing file"
	;   * finalizeLog(willTidyLogs=true) if willTidyLogs=false it will leave the log there for the next time 
	;   * appendFile() will no longer skip writing if the string to write is "".  Allows the Unix `touch` command to occur via initalizeNewLogFile() if HeaderString is blank and no file exists.
	; * Created/Changed more helper methods
	;   * LogClass.dividerString & createDividerString(useAsProperty=false) are the results of createDivierString() saved to a property.
	;   * createDividerString(includeNewLine=true) now adds a trailing NewLine character by default.
	;   * LogClass.scriptEnvReport & createScriptEnvReport() creates a string with a bunch of data about the environment the script is running in.  See the LogExamples.ahk script for a, well, example.
	; * created $printCalling expanding variable.  It is a shortened version of $printStack in that it only prints the calling function's name
	;   * changed transformStringVars() to support $printCalling
	;   * added printCalling() to create the text that replaces $printCalling
	; * NOT FINALIZED
	; * NOT YET Support for converting a random Object to String and then writing it to the log
	;   * added addLogObject() to allow you to add a log entry from an Object vs. addLogEntry() which is for Strings
	;   * added setObjectToString() to allow you to define which method addLogObject() will use to convert an object to a string
	;   * NEED TO put in a default method for setObjectToString() and test it.
	
	
	; 2018-06-19
	; * Made all filename properties read-only (set via New())
	; * changed printStack().maxNumbCalls to 2000 which is pretty much ALL calls
	;
	; 2018-06-15
	; * Initial fully commented draft of class
	; * TODO: more error checking on the filename properties
	;
	; 2018-06-08
	; * This folly begins
	;EndRegion

}

