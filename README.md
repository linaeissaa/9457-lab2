# Simple Antivirus Daemon

## 1. Project Description

This project implements a simple antivirus daemon using Bash scripting on Linux.

The daemon periodically monitors a specified directory, checks files for suspicious
extensions and keywords, and moves suspicious files into a quarantine directory.
A separate script allows the user to review quarantined files, restore false
positives, or permanently delete files considered malicious.

## 2. Project Objectives

- Learn how to write and execute Bash shell scripts.
- Monitor a directory periodically.
- Detect directory changes by comparing snapshots.
- Identify suspicious files by their final extension or content.
- Move suspicious files into a quarantine directory.
- Restore files that were incorrectly flagged.
- Permanently delete quarantined files.
- Use a Makefile to organize and run project tasks.

## 3. Files and Directories

- `antivirusd.sh`: Continuously monitors the specified directory and quarantines suspicious files.
- `restore.sh`: Provides an interactive menu to restore or permanently delete quarantined files.
- `Makefile`: Provides targets to prepare directories, run the scripts, and remove snapshot files.
- `directory-info.last`: Stores the most recent directory snapshot.
- `directory-info.new`: Stores a newly generated directory snapshot for comparison.
- `testdir/`: Example directory to monitor.
- `malicious_dir/`: Directory where suspicious files are quarantined.

## 4. Requirements

- Linux operating system or a Linux virtual machine.
- Bash.
- GNU Make.
- Standard Linux utilities, including `grep`, `diff`, `ls`, `cp`, and `rm`.

On Ubuntu, install Make if it is not already installed:

    sudo apt update
    sudo apt install make

Check the installed versions:

    bash --version
    make --version

## 5. Suspicious File Rules

### Suspicious extensions

The following final extensions are considered suspicious:

- `.exe`
- `.bat`
- `.vbs`
- `.scr`
- `.ps1`

Only the final extension is checked.

For example:

- `file.txt.scr` is flagged by its extension.
- `file.scr.txt` is not flagged by its extension.
- `file.exec` is not flagged by its extension.

### Suspicious keywords

The script searches file contents for the following keywords:

- `virus`
- `trojan`
- `malware`
- `worm`
- `ransomware`

Keyword matching is case-insensitive and matches the keyword anywhere in the file content.

For example, `WORM`, `wormhole`, and `mywormfile.txt` match the keyword `worm` when they occur in the file content.

## 6. How to Run the Project

### Step 1: Prepare the directories

Run:

    make setup

This creates `testdir/` and `malicious_dir/` if they do not exist.

### Step 2: Add test files

Place files you want to test inside `testdir/`.

For example:

    echo "This file contains a wormhole keyword." > testdir/example.txt
    echo "Example executable" > testdir/example.exe

These are test examples only; do not use real malicious files.

### Step 3: Start the antivirus daemon

Run:

    make antivirus

The daemon scans the directory immediately if it has no previous snapshot.
After that, it checks for changes every five seconds.

The interval can be changed by editing the `INTERVAL` variable in the Makefile.

Stop the daemon using `Ctrl+C`.

### Step 4: Review quarantined files

In another terminal, navigate to the project directory and run:

    make restore

Choose a file by its number, then select one of the available options:

1. Restore the file to the monitored directory.
2. Permanently delete the file from the quarantine directory.
3. Return to the file list.

### Step 5: Remove snapshot files

To remove the snapshot files, run:

    make clean

This does not remove files from `testdir/` or `malicious_dir/`.

## 7. Implementation Notes

The antivirus daemon generates a current snapshot using:

    ls -l "$dir" > directory-info.new

It compares the new snapshot with `directory-info.last` using `diff`.

When a change is detected, the daemon scans the directory. After the scan,
it regenerates `directory-info.last` from the current directory contents.
This ensures that the saved snapshot reflects the directory after suspicious
files have been removed.


