# Linux Antivirus and File Quarantine System

## 1. Project Overview

This project implements a simple antivirus-style monitoring system using Bash scripting on Linux.

The system continuously monitors a specified directory for suspicious files. It identifies potentially malicious files by checking their extensions and contents, moves detected files into a quarantine directory, and provides an interactive tool to restore files or permanently delete them.

The project demonstrates the use of Bash scripting, file management, directory monitoring, conditional statements, loops, functions, and Linux command-line utilities.

## 2. Project Objectives

The main objectives are to:

- Monitor a specified directory for changes.
- Detect suspicious files based on their extensions or contents.
- Copy suspicious files into a quarantine directory while preserving their original filenames.
- Delete the original files only after successful copying.
- Allow users to restore quarantined files that were incorrectly flagged.
- Allow users to permanently delete files identified as genuinely malicious.
- Handle invalid inputs and file-operation errors.

## 3. Project Structure

The project contains the following files and directories:

```text
9457-lab2/
├── antivirusd.sh
├── restore.sh
├── Makefile
├── README.md
├── testdir/
├── malicious_dir/
├── directory-info.last
└── directory-info.new
```

### File descriptions

| File or directory | Description |
|---|---|
| `antivirusd.sh` | Scans and monitors the specified directory for suspicious files. |
| `restore.sh` | Provides an interactive menu for restoring or permanently deleting quarantined files. |
| `Makefile` | Automates directory setup and execution of the scripts. |
| `README.md` | Documents the project, its functionality, and usage instructions. |
| `testdir/` | The default directory monitored by the antivirus. |
| `malicious_dir/` | The default quarantine directory for detected files. |
| `directory-info.last` | Stores the previous directory snapshot. |
| `directory-info.new` | Stores the latest directory snapshot for comparison. |

The snapshot files are generated automatically when the antivirus runs.

## 4. Detection Rules

The antivirus identifies suspicious files using two methods.

### 4.1. Suspicious file extensions

The following file extensions are flagged:

- `exe`
- `bat`
- `vbs`
- `scr`
- `ps1`

Extension matching is case-insensitive. For example, both `program.exe` and `program.EXE` are flagged.

The antivirus checks the final file extension.

### 4.2. Suspicious keywords

The antivirus also searches file contents for the following keywords:

- `virus`
- `trojan`
- `malware`
- `worm`
- `ransomware`

Keyword matching is case-insensitive.

For example, a file containing the word `WORM` or `Ransomware` is flagged even if its extension is not suspicious.

**Important:** These rules are basic detection rules for an educational project. They do not provide comprehensive malware detection.

## 5. How the Antivirus Works

The `antivirusd.sh` script follows these steps:

1. Validates the command-line arguments.
2. Checks that the monitored directory exists.
3. Validates the monitoring interval.
4. Creates the quarantine directory if necessary.
5. Performs an initial scan of the monitored directory.
6. Checks regular files directly inside the monitored directory for suspicious extensions and keywords.
7. Copies each detected file into `malicious_dir`, preserving its original filename.
8. Deletes the original file only if copying succeeds.
9. Displays a message when a file has been successfully quarantined.
10. Creates directory snapshots and compares them at the specified interval.
11. Scans the directory again whenever a change is detected.

If a file with the same name already exists in the quarantine directory, the script reports an error and keeps the original file.

If copying a suspicious file fails, the original is also kept.

### Example output

```text
Performing initial scan of 'testdir'...
program.exe is malicious and it is DELETED
suspicious.txt is malicious and it is DELETED
Initial scan complete.
Monitoring 'testdir' every 5 seconds...
```

The filenames and order of messages depend on the files present during the scan.

When a change is detected, the script may display:

```text
Change detected in 'testdir'. Scanning...
newfile.txt is malicious and it is DELETED
Scan complete.
```

The message `is malicious and it is DELETED` is displayed after the file has been copied successfully and its original has been deleted successfully.

## 6. How the Restore Tool Works

The `restore.sh` script allows users to manage files in the quarantine directory.

When executed, it displays the available quarantined files and asks the user to select one.

The user can choose from three options:

### Option 1: Restore the file

Copies the selected file back into the monitored directory and removes the quarantined copy after successful copying.

If a file with the same name already exists in the monitored directory, the restore operation is refused to prevent overwriting it.

### Option 2: Permanently delete the file

Deletes the selected file from the quarantine directory.

This action is intended for files that the user has determined are genuinely malicious.

### Option 3: Leave the file unchanged

Leaves the selected file in quarantine and returns to the list of available files.

The restore tool also handles invalid menu selections by displaying an error message and prompting the user again.

If the quarantine directory becomes empty, the tool displays an appropriate message and exits.

**Note:** Restoring a file does not guarantee that the antivirus will leave it alone. If the file still matches the detection rules, a subsequent scan may quarantine it again.

## 7. Prerequisites

The project requires:

- A Linux operating system, such as Ubuntu.
- Bash.
- GNU utilities, including `grep`, `cp`, `rm`, `ls`, and `diff`.
- GNU Make.

These tools are normally available on standard Ubuntu installations.

To check whether the required commands are available, run:

```bash
bash --version
make --version
```

## 8. Setup Instructions

### Step 1: Open the project directory

Navigate to the directory containing the project files.

For example:

```bash
cd ~/Desktop/9457-lab2
```

Use the appropriate path if your project is stored elsewhere.

### Step 2: Create the required directories

Run:

```bash
make setup
```

This creates the default monitored and quarantine directories if they do not already exist.

The default directories are:

- `testdir`
- `malicious_dir`

### Step 3: Prepare test files

You can create sample files to test the antivirus:

```bash
echo "This is a normal document." > testdir/normal.txt
echo "This file contains a wormhole." > testdir/suspicious.txt
echo "Harmless test content." > testdir/program.exe
```

Expected behavior:

- `normal.txt` remains in `testdir`.
- `suspicious.txt` is flagged because its contents contain the keyword `worm`.
- `program.exe` is flagged because its extension is `exe`.

**Warning:** Use only disposable test files when testing deletion and quarantine operations.

## 9. Running the Antivirus

### Using the Makefile

Run:

```bash
make antivirus
```

The Makefile uses the following default values:

```makefile
DIR = testdir
MALICIOUS_DIR = malicious_dir
INTERVAL = 5
```

This monitors `testdir`, quarantines suspicious files in `malicious_dir`, and checks for directory changes every five seconds.

The antivirus performs an initial scan before beginning continuous monitoring.

To stop the antivirus, press:

```text
Ctrl+C
```

### Running the script directly

The script accepts three command-line arguments:

```bash
./antivirusd.sh <directory_to_monitor> <quarantine_directory> <interval-seconds>
```

For example:

```bash
./antivirusd.sh testdir malicious_dir 5
```

This command monitors `testdir`, uses `malicious_dir` as the quarantine directory, and sets the monitoring interval to five seconds.

The interval must be a positive integer.

## 10. Running the Restore Tool

To launch the restore tool using the default directories, run:

```bash
make restore
```

Alternatively, execute the script directly:

```bash
./restore.sh testdir malicious_dir
```

The script displays the files in quarantine and allows the user to select a file and choose an action.

If there are no files in quarantine, the script informs the user and exits.

## 11. Cleaning Up

To remove the directory snapshot files, run:

```bash
make clean
```

This removes:

```text
directory-info.last
directory-info.new
```

It does not delete files from `testdir` or `malicious_dir`.

To remove the test files manually, first stop the antivirus and make sure you do not need any files in the test directories.

For example, to remove regular files from the default test directories:

```bash
rm -f testdir/*
rm -f malicious_dir/*
```

**Warning:** These commands permanently delete the matching regular files in those directories. Use them only if you are certain the files can be discarded.

## 12. Testing and Verification

The following tests can be used to verify the main functionality.

| Test | Expected result |
|---|---|
| A normal `.txt` file with no suspicious keywords | The file remains in the monitored directory. |
| A file with a suspicious extension, such as `.exe` | The file is flagged and quarantined. |
| A `.txt` file containing a suspicious keyword | The file is flagged and quarantined. |
| A suspicious file is successfully copied to quarantine | The original is deleted, and the quarantined copy retains the original filename. |
| Copying a suspicious file fails | The original file is kept. |
| A file with the same name already exists in quarantine | The existing quarantined file is not overwritten, and the original is kept. |
| A suspicious file is added while monitoring is running | The file is detected during a subsequent scan after a directory change is detected. |
| A user restores a quarantined file | The file is copied back to the monitored directory, and the quarantined copy is removed if the operation succeeds. |
| A user permanently deletes a quarantined file | The selected file is removed from quarantine. |
| A user enters an invalid selection in the restore menu | An error message is displayed, and the user is prompted again. |

To check shell syntax, run:

```bash
bash -n antivirusd.sh
bash -n restore.sh
```

If both commands finish without output, no Bash syntax errors were reported.

## 13. Limitations

This project is a basic educational antivirus simulation, not a production security application.

Its limitations include:

- Detection depends entirely on the configured extensions and keywords.
- Legitimate files may be flagged if they match the detection rules.
- Malicious files that do not match the rules may not be detected.
- The antivirus monitors regular files directly inside the specified directory; it does not recursively scan subdirectories.
- Directory snapshots are used to detect changes. This approach is less reliable than dedicated filesystem monitoring tools and may not detect every possible change.
- The script does not provide advanced malware analysis, cryptographic verification, or real-time security guarantees.

These limitations should be considered when interpreting the results.

## 14. Conclusion

This project demonstrates how Bash scripting and standard Linux utilities can be used to implement a simple file-monitoring and quarantine system.

It supports basic suspicious-file detection, quarantine management, interactive file restoration, permanent deletion, input validation, and continuous directory monitoring.

The project provides practical experience with Linux commands, shell scripting, file operations, automation using Makefiles, and error handling.
