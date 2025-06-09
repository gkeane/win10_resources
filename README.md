# Windows 10 EOL Migration Project - KACE Scripts

This repository contains scripts for the Windows 10 End of Life (EOL) migration project, designed to be used with the KACE Systems Management Appliance (SMA) and related tools.

## Purpose

These scripts help identify and categorize Windows 10 systems in your environment to facilitate the migration process before Windows 10 reaches end of life. They also include maintenance and diagnostic tools to ensure system health during the migration process.

## Scripts

### Custom Inventory Scripts

#### CI-Upd-24H2_RedReason.kace
This custom inventory script retrieves the RedReason value from the Windows registry, which indicates why a system is not ready for Windows 24H2 upgrade. This information is crucial for:
- Identifying specific blockers preventing Windows 24H2 upgrade
- Troubleshooting upgrade issues
- Planning remediation steps for affected systems

#### CI-Upd-24H2_upgEx.kace
This custom inventory script retrieves the UpgEx (Upgrade Experience) value from the Windows registry, which provides information about the system's Windows 24H2 upgrade experience status. This helps:
- Monitor upgrade readiness across the environment
- Track upgrade experience indicators
- Identify systems that may need additional attention

#### CI-Recovery_Partition_size.kace
This custom inventory script returns the size (in MB) of the recovery partition on a Windows system. It uses a PowerShell command to query partition information and is useful for:
- Auditing recovery partition sizes across your environment
- Identifying systems with missing or unusually sized recovery partitions

**Implementation:**
- In KACE SMA, go to Inventory > Custom Inventory
- Create a new Custom Inventory item
- In the Custom Inventory Rule field, paste the following:
  ```
  ShellCommandTextReturn(cmd /c powershell -EncodedCommand RwBIAHQALQBJQABQAGcAfABQAGkAdABpAG8AbgAgAC0AQwBPAHMAAGgALAAkAF8ALgBUAHkAcABlAC0AZQAgAFIAZQBjAG8AdgBlAHIAeQAgAHwAIABGAG8AcgBFAGEAYwBoAC0ATwBiAGoAZQBjAHQAIAB7ACAAJABfAC4AUwBpAHoAZQAgAC8AIAAxAE0AQgAgAH0A)
  ```
- Save and deploy to target machines
- The script will return the recovery partition size in MB for each system

### SQL Queries

#### win10_green_with_small_recovery.sql
This script returns Windows 10 systems that are marked as 'Capable' for upgrade (green) and have a recovery partition size (from the CI-Recovery_Partition_size custom inventory item) less than 2GB (2048 MB).

**Usage:**
1. Log into your KACE SMA web interface
2. Navigate to the SQL Query tool
3. Copy and paste this script
4. Execute the query to get the results

#### win10_green.sql
This script identifies Windows 10 systems that are capable of being upgraded. It returns:
- System name
- System description
- IP address
- MAC address
- System ID

The query specifically looks for:
- Systems running Windows 10
- Systems marked as "Capable" in the OSUPGRADE_READINESS table

#### win10_red.sql
This script identifies Windows 10 systems that are NOT capable of being upgraded. It returns:
- System name
- System description
- IP address
- MAC address
- System ID

The query specifically looks for:
- Systems running Windows 10
- Systems NOT marked as "Capable" in the OSUPGRADE_READINESS table

### Batch Scripts

#### sfc_scannow.bat
This batch script performs a System File Checker (SFC) scan on Windows systems and logs the results. Key features:
- Automatically detects system architecture (32-bit vs 64-bit)
- Runs SFC scan using the appropriate method for the system
- Implements a 30-day cooldown period between scans
- Logs results to both local and network locations
- Uses PowerShell for timestamp generation and file age checking

Log locations:
- Local: `C:\ProgramData\Quest\KACE\user\sfcscan.log`
- Network: `\\chs-deploy\kacereport\sfc\[COMPUTERNAME]_sfc_[TIMESTAMP].log`

The script includes:
- Timestamp generation for unique log files
- Automatic bitness detection and appropriate SFC execution
- Error handling for network share access
- Detailed logging of all operations
- 30-day cooldown period to prevent excessive scanning

### PowerShell Scripts

#### RegChange_Updates_From_MS.ps1
This script resets and reconfigures Windows Update settings to ensure updates are received directly from Microsoft, and sets policies for Windows 11 24H2 targeting. It also adjusts power settings to prevent standby on AC power.

**What it does:**
- Stops the Windows Update service (wuauserv)
- Removes existing Windows Update Group Policy registry keys and cached policy data
- Recreates and configures the Windows Update policy registry keys for direct updates from Microsoft
- Sets Windows Update to target Windows 11 24H2
- Configures Automatic Updates (AU) subkey with recommended settings
- Restarts the Windows Update service
- Adjusts power settings to prevent standby on AC and set standby on DC

**Usage:**
Run this script as an administrator in PowerShell. It is intended for use in environments where you need to reset Windows Update policies (e.g., after removing WSUS or other update management) and ensure the device is configured to receive updates directly from Microsoft, targeting Windows 11 24H2.

Example:
```
powershell.exe -ExecutionPolicy Bypass -File .\RegChange_Updates_From_MS.ps1
```

#### Powershell_ExtendWinRE_or_CreateNew.ps1
This script increases the size of the Windows Recovery Environment (WinRE) partition to enable servicing and updates. It is provided by Microsoft as part of KB5035679 guidance for WinRE update issues.

- **Reference:** [Microsoft KB5035679 - Instructions to run a script to resize the recovery partition to install a WinRE update](https://support.microsoft.com/en-us/topic/kb5035679-instructions-to-run-a-script-to-resize-the-recovery-partition-to-install-a-winre-update-98502836-cb2c-4d9a-874c-23bcdf16cd45)

**What it does:**
- Checks WinRE status
- Backs up the current WinRE partition
- Resizes or creates a new WinRE partition as needed
- Restores WinRE functionality
- Logs all actions

**Usage:**
1. Open PowerShell as Administrator.
2. Run the script with the required backup folder parameter:
   ```
   Powershell.exe -ExecutionPolicy Bypass -File .\Powershell_ExtendWinRE_or_CreateNew.ps1 -BackupFolder C:\WinRE_backup
   ```
3. Follow the instructions in the Microsoft article for prerequisites and post-steps.

For full details, troubleshooting, and support, see the Microsoft article linked above.

## Usage

### SQL Queries
1. Log into your KACE SMA web interface
2. Navigate to the SQL Query tool
3. Copy and paste the desired script
4. Execute the query to get the results

### Batch Scripts
1. Deploy the script through KACE SMA or run manually
2. Script will automatically:
   - Check if a scan was performed in the last 30 days
   - Run SFC scan using the appropriate method for the system architecture
   - Log results locally and to network share
   - Handle both 32-bit and 64-bit systems appropriately

## Requirements

- KACE Systems Management Appliance (SMA)
- Appropriate permissions to run SQL queries
- Access to the MACHINE and OSUPGRADE_READINESS tables
- Network access to `\\chs-deploy\kacereport\sfc` for log storage
- Windows system with PowerShell available
- Write access to `C:\ProgramData\Quest\KACE\user`

## Contributing

Feel free to contribute additional scripts or improvements to existing ones. Please ensure that any new scripts are properly documented and tested before submitting.

## Note

These scripts are specifically designed for the Windows 10 EOL migration project and should be used in conjunction with your organization's migration strategy. 