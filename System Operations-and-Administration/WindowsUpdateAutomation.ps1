<#
.SYNOPSIS
    Automated Windows Update script.
.DESCRIPTION
    This script checks for, downloads, and installs Windows updates on multiple Windows machines. 
    It logs the activities and can be run remotely or scheduled via a task scheduler.
.AUTHOR
    Bogdan Turcanu
.DEPENDENCIES
    PowerShell with administrative privileges, Windows Update Service.
.USAGE
    Replace $computers array with the names of the machines you want to update.
    Set $logPath to the desired path for the log file.
    This script requires that PowerShell is run with administrative privileges.
    Ensure that PSWindowsUpdate module is installed on the machines (Install-Module PSWindowsUpdate).
    Remote management should be enabled on the target machines.
#>

# Requires -RunAsAdministrator

# Configuration
$computers = @("PC1", "PC2", "PC3") # List of computers to update
$logPath = "C:\path\to\log\directory\windows_update_log.txt"

# Function to Install Windows Updates
function Install-WindowsUpdate {
    param (
        [string]$computerName
    )

    # Logging function
    function Log-Update {
        param (
            [string]$message
        )
        Add-Content -Path $logPath -Value "$(Get-Date) - $computerName: $message"
    }

    # Establishing Remote Session
    try {
        $session = New-PSSession -ComputerName $computerName
        Log-Update "Connected to $computerName"
    } catch {
        Log-Update "Error connecting to $computerName: $_"
        return
    }

    # Check for and Install Updates
    try {
        Log-Update "Checking for updates..."
        $updates = Invoke-Command -Session $session -ScriptBlock { 
            Import-Module PSWindowsUpdate
            Get-WindowsUpdate
        }

        if ($updates.Count -gt 0) {
            Log-Update "Installing updates..."
            Invoke-Command -Session $session -ScriptBlock {
                Install-WindowsUpdate -AcceptAll -AutoReboot
            }
            Log-Update "Updates installed successfully."
        } else {
            Log-Update "No updates available."
        }
    } catch {
        Log-Update "Error installing updates: $_"
    } finally {
        Remove-PSSession -Session $session
        Log-Update "Session closed."
    }
}

# Main Execution
foreach ($computer in $computers) {
    Install-WindowsUpdate -computerName $computer
}
