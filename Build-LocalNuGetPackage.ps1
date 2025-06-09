param (
    [Parameter(Mandatory = $true)]
    [string]$BuildConfiguration,

    [Parameter(Mandatory = $false)]
    [string]$LocalFeedPath,

    [Parameter(Mandatory = $false)]
    [string]$ProjectPath
)

if (-not $PSBoundParameters.ContainsKey('ProjectPath')) {
    # Assume execution from the folder where the csproj file is located
    $ProjectPath = (Get-Location).Path
}

if (-not $PSBoundParameters.ContainsKey('LocalFeedPath')) {
    # Assume path of local feed if not supplied as parameter
    $LocalFeedPath = "C:\Dev\LocalPackageFeed"
}

dotnet pack -c $BuildConfiguration

# Delete existing package first
# $pattern = "MyProject.Core.*.nupkg"
Get-ChildItem -Path $LocalFeedPath -Filter "MyProject.Core.*.nupkg" | Remove-Item -Force

try
{
    Write-Verbose "Attempting to move package from $ProjectPath\bin\$BuildConfiguration\MyProject.Core.1.0.0.nupkg to $LocalFeedPath"
    
    Move-Item -Path "$ProjectPath\bin\$BuildConfiguration\MyProject.Core.1.0.0.nupkg" `
              -Destination "$LocalFeedPath" `
              -Verbose
              
    Write-Verbose "Package moved successfully."
} catch
{
    Write-Error "Failed to move the package: $_"
}