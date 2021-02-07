if($PSVersionTable.PSVersion.Major -lt 6){
    [System.Reflection.Assembly]::LoadWithPartialName("System.Security.Principal.Windows")
    $null = Add-Type -Path "$PSScriptRoot\refs\net46\SimpleImpersonation.dll"
}
else{
    $null = Add-Type -Path "$PSScriptRoot\refs\netstandard2.0\SimpleImpersonation.dll"
    $null = Add-Type -Path "$PSScriptRoot\refs\netstandard2.0\System.Security.Principal.Windows.dll"
}

. "$PSScriptRoot\Commands\Get-GMSACredential.ps1"
. "$PSScriptRoot\Commands\Invoke-GMSACommand.ps1"


Export-ModuleMember -Function @('Get-GMSACredential','Invoke-GMSACommand')