Function Get-GMSACredential{
    <#
    .SYNOPSIS
    Given a GMSA account, will return a usable PSCredential object
    
    .DESCRIPTION
    Checks AD for the GMSA account information and returns a usable credential. Must be run with an account that has permissions to the password
    
    .PARAMETER GMSAName
    Identity of the GMSA account
    
    .PARAMETER Domain
    Domain logon name of the account
    
    .PARAMETER SearchRoot
    Root to search for the account (most cases can be omitted)
    
    .EXAMPLE
    Get-GMSACredential -GMSAName 'gmsaUser$' -Domain 'Home.Lab'
    
    .NOTES
    .Author: Ryan Ephgrave
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$GMSAName,
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [Parameter(Mandatory=$false)]
        [string]$SearchRoot = $(([adsisearcher]"").Searchroot.path)
    )

    $dEntryRoot = New-Object System.DirectoryServices.DirectoryEntry -ArgumentList $SearchRoot

    $searcher = New-Object System.DirectoryServices.DirectorySearcher -ArgumentList $dEntryRoot
    
    $searcher.Filter = "(&(name=$($GMSAName.TrimEnd('$')))(ObjectCategory=msDS-GroupManagedServiceAccount))"
    [void]$searcher.PropertiesToLoad.Add('Name')
    [void]$searcher.PropertiesToLoad.Add('msDS-ManagedPassword')
   
    $searcher.SearchRoot.AuthenticationType = 'Sealing'
    
    $Accounts = $searcher.FindAll()
    foreach($a in $accounts){
        if($a.Properties.'msds-managedpassword'){
            $pw = $a.Properties.'msds-managedpassword'
            [Byte[]]$byteBlob = $pw.Foreach({$PSItem})
            $MemoryStream = New-Object System.IO.MemoryStream -ArgumentList (,$byteBlob)
            $Reader = New-Object System.IO.BinaryReader -ArgumentList $MemoryStream
            
            # have to move the reader to the pw offset
            $null = $Reader.ReadInt16()
            $null = $Reader.ReadInt16()
            $null = $Reader.ReadInt32()

            $PWOffset = $Reader.ReadInt16()
            $Length = $byteBlob.Length - $PWOffset
            $stringBuilder = New-Object System.Text.StringBuilder -ArgumentList $Length
            for($i = $PWOffset; $i -le $byteBlob.Length; $i += [System.Text.UnicodeEncoding]::CharSize){
                $currentChar = [System.BitConverter]::ToChar($byteBlob, $i)
                if($currentChar -eq [char]::MinValue) { break; }
                [void]$stringBuilder.Append($currentChar)
            }
            return ( New-Object PSCredential -ArgumentList @(
                                    "$($Domain)\$($GMSAName)",
                                    (ConvertTo-SecureString $stringBuilder.ToString() -AsPlainText -Force)
                                    ))
        }
    }
}

