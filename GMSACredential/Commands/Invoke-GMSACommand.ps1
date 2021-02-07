Function Invoke-GMSACommand{
    <#
    .SYNOPSIS
    Helper command to invoke a scriptblock with credentials (especially helpful with GMSA creds)
    
    .DESCRIPTION
    Will use the open source library SimpleImpersonation to invoke a ScriptBlock with the provided credentials
    
    .PARAMETER ScriptBlock
    Script block to invoke
    
    .PARAMETER ArgumentList
    Argument list for the scriptblock
    
    .PARAMETER Credential
    Credential object (intended to be GMSA credentials, but can be any)
    
    .PARAMETER LogonType
    LogonType Enum - New Credentials are good for most cases. Enum help is here: https://github.com/mj1856/SimpleImpersonation/blob/master/src/LogonType.cs
    
    .EXAMPLE
    Invoke-GMSACommand -ScriptBlock {Write-Host 'test'} -Credential ( Get-GMSACredential -GMSAName 'MyGMSA' -Domain 'test.Domain' )
    
    .NOTES
    .Author: Ryan Ephgrave
    #>
    Param(
        [ScriptBlock]$ScriptBlock,
        [Object[]]$ArgumentList,
        [PSCredential]$Credential,
        [SimpleImpersonation.LogonType]$LogonType = [SimpleImpersonation.LogonType]::NewCredentials
    )
    $script:CommandOutput = $null
    $SCred = [SimpleImpersonation.UserCredentials]::new($Credential.GetNetworkCredential().Domain,$Credential.GetNetworkCredential().UserName, $Credential.GetNetworkCredential().Password)
    [SimpleImpersonation.Impersonation]::RunAsUser(
            $SCred,
            $LogonType, 
            [System.Action]{ $Script:CommandOutput = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList }
    )
    $script:CommandOutput
    $script:CommandOutput = $null
}