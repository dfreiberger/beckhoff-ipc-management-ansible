[CmdletBinding()]
param (
    [String]
    $PackageName,
    [String]
    $PackageInstallerPath,
    [String]
    $PackageVersion,
    [String]
    $Authors,
    [String]
    $Description,
    [String]
    $SilentArgs
)

function New-Template($templatePath, $tokens, $outputPath)
{
    $template = Get-Content $templatePath -Raw
    $out = [regex]::Replace(
        $template,
        '{{ (?<tokenName>\w+) }}',
        {
            param($match)

            $tokenName = $match.Groups['tokenName'].Value

            return $tokens[$tokenName]
        })
    $out | Out-File $outputPath -Encoding utf8
}

# check if package path exists
if (-not (Test-Path $PackageInstallerPath))
{
    throw "Package installer path '$PackageInstallerPath' does not exist"
}

$tokens = @{
    id = $PackageName
    version = $PackageVersion
    title = $PackageName
    authors = $Authors
    description = $Description
    tags = $PackageName
}

# create directory for package

$packageOutputPath = "packages\$($PackageName)_$($PackageVersion)"
Write-Output $packageOutputPath

New-Item -ItemType Directory -Force -Path $packageOutputPath
New-Item -ItemType Directory -Force -Path $packageOutputPath\tools

# create nuspec file
New-Template "template\package.nuspec.j2" $tokens "$packageOutputPath\$PackageName.nuspec"

# copy installer to package directory
Copy-Item -Path $PackageInstallerPath -Destination $packageOutputPath\tools\

# create installer
$fileType = $PackageInstallerPath.Substring($PackageInstallerPath.LastIndexOf('.') + 1)
$fileName = $PackageInstallerPath.Substring($PackageInstallerPath.LastIndexOf('\') + 1)

$sha = Get-FileHash -path $PackageInstallerPath -Algorithm SHA256  | Select-Object -ExpandProperty "Hash"
Write-Host $sha

if ($fileType -eq 'exe')
{
    $validExitCodes = '@(0)'
}
else
{
    $validExitCodes = '@(0, 3010, 1641)'
}

# MSI
#silentArgs    = "/quiet" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
#validExitCodes= @(0, 3010, 1641)
# OTHERS
# Uncomment matching EXE type (sorted by most to least common)
#silentArgs   = '/S'           # NSIS
#silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
#silentArgs   = '/s'           # InstallShield
#silentArgs   = '/s /v"/qn"'   # InstallShield with MSI
#silentArgs   = '/s'           # Wise InstallMaster
#silentArgs   = '-s'           # Squirrel
#silentArgs   = '-q'           # Install4j
#silentArgs   = '-s'           # Ghost
# Note that some installers, in addition to the silentArgs above, may also need assistance of AHK to achieve silence.
#silentArgs   = ''             # none; make silent with input macro script like AutoHotKey (AHK)
                                #       https://community.chocolatey.org/packages/autohotkey.portable
#validExitCodes= @(0) #please insert other valid exit codes here

$tokens = @{
    software_name = $PackageName
    file_name = $fileName
    file_type = $fileType
    silent_args = $SilentArgs
    url = $url
    valid_exit_codes = $validExitCodes
    checksum = $sha
}
New-Template "template\tools\chocolateyInstall.ps1.j2" $tokens "$packageOutputPath\tools\chocolateyInstall.ps1"

# create package
choco pack "$packageOutputPath\$PackageName.nuspec" --outdir ".\packages"

# choco uninstall $PackageName -f

# choco install $PackageName -fd -y -s ".\packages"
