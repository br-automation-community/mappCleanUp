The sample consists of a sample task that can be copied and pasted into your project. Files can be deleted by the following criteria.

* Delete oldest file
* Delete all files older than a certain date and time
* Delete oldest file until a certain amount of files are left
* Delete oldest file until a certain amount of space is free

**<span style="color:red">Important Note:</span>** When using the parameter "Pattern" in combination with maximum files or minimum space, the task will only delete files that match the pattern but will use the total number of files or space as a reference. For example, if the pattern is set to ".csv" files and the maximum number of files is set to 10. The directory contain 8 files that match the pattern but 15 files in total. The task will delete 5 files that match the pattern to get the total number of files down to 10.

## Command structure

The task uses a variable structure to communicate with the outside world that can also be used to interact with other tasks. The structure *CleanUp* looks as follows:

<table>

    <tr>
        <th width="100">Level 1</th>
        <th>Level 2</th>
        <th>Level Description</th>
    </tr>
    <tr>
        <td>CMD</td>
        <td colspan="3">Used to trigger a command</td>
    </tr>
    <tr>
        <td></td>
        <td>DeleteMaxFiles</td>
        <td colspan="3">Delete oldest file until a certain amount of files are left.</td>
    </tr>
    <tr>
        <td></td>
        <td>DeleteMinSpace</td>
        <td colspan="3">Delete oldest file until a certain amount of space is free.</td>
    </tr>
    <tr>
        <td></td>
        <td>DeleteOldest</td>
        <td colspan="3">Delete oldest file.</td>
    </tr>
    <tr>
        <td></td>
        <td>DeleteOlderThan</td>
        <td colspan="3">Delete all files older than a certain date and time.</td>
    </tr>
    <tr>
        <td></td>
        <td>UpdateFreeSpace</td>
        <td colspan="3">Update free space information. (CleanUp.DAT.FreeSpace)</td>
    </tr>
    <tr>
        <td></td>
        <td>ErrorReset</td>
        <td colspan="3">Reset error.</td>
    </tr>
    <tr>
        <td>PAR</td>
        <td colspan="3">Parameter structure</td>
    </tr>
    <tr>
        <td></td>
        <td>Simulate</td>
        <td colspan="3">Files are only listed but not actually deleted. <strong>The default value is true to protect the user from accidently deleting files.</strong> </td>
    </tr>
    <tr>
        <td></td>
        <td>Device</td>
        <td colspan="3">Device name.</td>
    </tr>
    <tr>
        <td></td>
        <td>Path</td>
        <td colspan="3">Path to files.</td>
    </tr>
    <tr>
        <td></td>
        <td>MaxFilesToKeep</td>
        <td colspan="3">Maximum number of files to keep. (Command DeleteMaxFiles)</td>
    </tr>
    <tr>
        <td></td>
        <td>MinSpace</td>
        <td colspan="3">Delete files until minimum space is available. (Command DeleteMinSpace)</td>
    </tr>
    <tr>
        <td></td>
        <td>OlderThan</td>
        <td colspan="3">Delete all files older than this date. (Command DeleteOlderThan)</td>
    </tr>
    <tr>
        <td></td>
        <td>Pattern</td>
        <td colspan="3">File must match this pattern (ex. .pdf or .csv).</td>
    </tr>
    <tr>
        <td>DAT</td>
        <td colspan="3">Return data from command.</td>
    </tr>
    <tr>
        <td></td>
        <td>FilesList</td>
        <td colspan="3">List of files that were deleted. Only the first x deleted files are listed here.</td>
    </tr>
    <tr>
        <td></td>
        <td>FilesDeleted</td>
        <td colspan="3">Number of files that were deleted.</td>
    </tr>
    <tr>
        <td></td>
        <td>FilesCount</td>
        <td colspan="3">Number of files left in the directory.</td>
    </tr>
    <tr>
        <td></td>
        <td>FreeSpace</td>
        <td colspan="3">Free space on the media.</td>
    </tr>
    <tr>
        <td>ERR</td>
        <td colspan="3">Information about errors.</td>
    </tr>
    <tr>
        <td></td>
        <td>State</td>
        <td colspan="3">State where the error occurred.</td>
    </tr>
    <tr>
        <td></td>
        <td>Text</td>
        <td colspan="3">Error text.</td>
    </tr>
    <tr>
        <td>Status</td>
        <td colspan="3">Shows the status as number</td>
    </tr>

</table>

## Pre-Configuration

The following constants can be adjusted if necessary.

| Constant | Default | Text |
|---|---|---|
| FILE_NAME_LEN | 200 | Maximum file name length. |

## Error handling

The task generates the following list of error messages. All other error numbers are generated from included libraries that can be found in the Automation Studio help.

| No | Constant | Text |
|---|---|---|
| 10000 | CLEANUP_ERR_FILE_NAME_TO_LONG  | File name + path exceeds maximum file name length |
| 10001 | CLEANUP_ERR_PAR_IS_EMPTY  | Corresponding parameter for command is empty  |
| 10002 | CLEANUP_ERR_MIN_SPACE  | Minimum space could not be achieved  |
| 10003 | CLEANUP_ERR_MIN_FILES  | Minimum number of files could not be achieved  |
