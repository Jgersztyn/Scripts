<#
.SYNOPSIS
    Builds and releases a local NuGet package for a given project file and releases it to a local feed directory.

.PARAMETER BuildConfiguration
    The build configuration (e.g., Debug, Release).

.PARAMETER ProjectPath
    The path to the project file (.csproj) that should be built and released.

.PARAMETER LocalFeedPath
    The local path where the NuGet package will be released. Defaults "C:\Dev\LocalPackageFeed" if not specified.

.EXAMPLE
    .\Build-LocalNuGetPackage -BuildConfiguration Release -ProjectPath "C:\Repos\MyProject\MyProject.csproj"

    Creates a NuGet package for the specified project in Release configuration and moves it to the default local feed path.

.NOTES
    Author: Jason Gersztyn
    Date: 2025-06-10
#>
param (
    [Parameter(Mandatory = $true)]
    [string]$BuildConfiguration,

    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $false)]
    [string]$LocalFeedPath
)

if (-not $PSBoundParameters.ContainsKey('LocalFeedPath')) {
    # Assume path of local feed if not supplied as parameter
    $LocalFeedPath = "C:\Dev\LocalPackageFeed"
}

# Attempt build and release of the package based on provided directory
if (Test-Path $ProjectPath)
{
    dotnet pack $ProjectPath -c $BuildConfiguration
}
else 
{
    Write-Error "Project file not found at: $ProjectPath. Please ensure csproj file is present and run again."
    exit 1
}

# Get package name via csproj file that should be inside the current directory
$ProjectFile = Get-ChildItem -Path $ProjectPath -Filter "*.csproj" | Select-Object -First 1
$ProjectName = [System.IO.Path]::GetFileNameWithoutExtension($ProjectFile.Name)

# Delete existing package before building and releasing the new package
Get-ChildItem -Path $LocalFeedPath -Filter "$ProjectName.*.nupkg" | Remove-Item -Force

try
{
    Write-Verbose "Attempting to move package from $ProjectPath\bin\$BuildConfiguration\$ProjectName.1.0.0.nupkg to $LocalFeedPath"
    
    Move-Item -Path "$ProjectPath\bin\$BuildConfiguration\$ProjectName.1.0.0.nupkg" `
              -Destination "$LocalFeedPath" `
              -Verbose
              
    Write-Verbose "Local package release completed successfully."
}
catch
{
    Write-Error "Failed to move the package: $_"
}