<# DiskUsage Script for powershell v0.1
Steve's attempt to make life easier on himself cause he prefers BASH DU over WinDirStat and TreeView. 
Something easy and scriptable that can be managed in RMM Tools. 
#>

#Checks script variable input. "du.ps1 c:", "du.ps1 \somepath\someotherpath"
$Check = $args[0] 

#Checks if no variable was inputted at time of execution, sets current path "." to continue. 
if ($Check -eq $null) { 
$Check = @(".")
}

#Main function to call at end of script. 
Function Get-DiskUsage {

    #Resolves path location from $Check variable
    $location = Resolve-Path -Path $Check;
    #Clean display for path being checked. 
    Write-Host "Checking directory: $location";

    # The magic. Need to find out how to clean up the errors thrown from  Access is denied System.
    # and UnauthorizedAccessException,Microsoft.PowerShell.Commands.GetChildItemCommand
    #Finally  Get-ChildItem -Path "C:\" -force -Attributes !ReparsePoint
    gci -Path $Check -Force -Attributes !ReparsePoint -ErrorAction SilentlyContinue | 
            %{$fname=$_; Write-Host "$_"; 

                gci -Force -Recurse $_.FullName -ErrorAction SilentlyContinue |

                #gci -Force -Recurse $_.FullName -ErrorAction SilentlyContinue 
             


            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue |
            Select @{Name="Name"; Expression={$fname}},
                   @{Name="Total (MB)";
                   Expression={"{0:N3}" -f ($_.sum / 1MB) }}, Sum } |
            sort Sum -Descending |
            Format-Table -Property Name,"Total (MB)"#, Sum -AutoSize
    }
Get-DiskUsage