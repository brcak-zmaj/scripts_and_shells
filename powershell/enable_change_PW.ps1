$users = Get-ADUser -Filter * -Properties CannotChangePassword -SearchBase "OU=OUNAME,DC=domain,DC=lan" | where { $_.CannotChangePassword -eq "false" }
foreach( $user in $users){
 Set-ADUser $user -CannotChangePassword $True
}
