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

### Setting up gMSAs in the lab

If you want to try this out in your lab, it's real easy to get gMSAs up and running!

First, if you've never set up a KDS root key, you'll want to run this command from a Domain Administrator:

``` powershell
Add-KDSRootKey -EffectiveImmediately
```

Note, effective immediately means it's added immediately but not ready immediately (it always waits for replication). Per the [documentation](https://docs.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/create-the-key-distribution-services-kds-root-key) you can run this instead to make it really effective immediately:

``` powershell
Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))
```

Generally at work we give an AD group permissions to get our passwords and then we can add or remove accounts. So in the lab, since everything's a Domain Admin, let's use that!

Create your account and give Domain Admins permissions to get the password (feel free to change this to any AD group you want):

``` powershell
$ADGroupName = 'Domain Admins'
$GMSAName = 'gMSATest'
$DomainFqdn = 'home.lab'
$ServiceAccount = New-ADServiceAccount -Name 'gMSATest' -DNSHostName "$GMSAName.$($DomainFqdn)" -PrincipalsAllowedToRetrieveManagedPassword $ADGroupName -Enabled $true -PassThru
```

Now you'll have the account "gMSATest$" available to use! Give the account permissions to whatever you want to access, then use it in your scripts with ```Get-GMSACredential```

Please let me know if you have any issues!