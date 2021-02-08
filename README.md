# gMSA Credential Module

Gets a usable PSCredential for a gMSA.

## Special thanks

This module would not be possible without the helpful open source tools from [DSInternals](https://www.dsinternals.com/en/retrieving-cleartext-gmsa-passwords-from-active-directory/).

## Install instructions

``` powershell
Install-Module GMSACredential
```

## Using This Module

gMSA's are accounts whose password is requested and is not known. Active Directory effectively becomes your password manager and you request the password from an account that has permissions to request it. Generally this is done by Windows and you use these accounts as IIS App Pools or to run services, but there's no reason we can't get a PSCredential and use them in PowerShell!

### The basics

``` powershell
$Cred = Get-GMSACredential -GMSAName 'gMSATest' -Domain 'Home.Lab'
invoke-command -ComputerName localhost -Credential $cred -ScriptBlock { whoami }
```

The above command outputs ```home\gmsatest$``` to prove it is working. gMSA's generally have a $ at the end of the account, but it's not required for this module.  

There's not much to this, the only gotcha is you need to run this as an account with permissions to get the gMSA password

If you want a more in-depth guide including how to set up your environment for gMSAs, please [look at the wiki](https://github.com/Ryan2065/gMSACredentialModule/wiki/PasswordlessPowerShell) - there's a great guide on Passwordless PowerShell.