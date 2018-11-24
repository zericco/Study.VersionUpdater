﻿[CmdletBinding(SupportsShouldProcess)]
Param(
)

$VersionInfoPath = "${PSScriptRoot}\Properties\AssemblyInfo.cs"
$Project = "VersionUpdater.Target.Acceptance"

function Get-Version($file)
{
    $semverRegex = '';
    $regex = 'assemblyinformationalversion\(\s*"(?<version>(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+))"';

	$version = [regex]::match((Get-Content $file),$regex, "IgnoreCase").Groups["version"].Value
	Write-Verbose "found version v$version"
	return $version
}

if (Test-Path "${Project}.nuspec") {
	nuget pack "${Project}.csproj" -build
}
else {
	Write-Verbose "generate package for ${Project}"
	$version = Get-Version $VersionInfoPath
	Write-Verbose "building ${Project}"
	msbuild "${Project}.csproj"
	nuget pack "${Project}.nuspec" -BasePath "${PSScriptRoot}\bin\Debug\" -Version $version
}