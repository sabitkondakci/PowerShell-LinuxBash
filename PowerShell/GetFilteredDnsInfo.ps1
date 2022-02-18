$emailList='sahibinden.com','hepsiemlak.com','github.com','google.com','gmail.com','yahoo.com','trendyol.com','hepsiburada.com','gittigidiyor.com','haberturk.com','cimri.com','linkedin.com','microsoft.com','whatsapp.com','telegram.com','tumblr.com','yandex.com','mailru.com'


Function Get-FilteredDnsInfo
{
    # [cmdletbinding()] if you wish to enter a value from command line
    Param ( [string[]]$mailList, [string]$nameAdmin,[string]$primaryServer )
    
    Process{

        $mailList =  $mailList | Sort-Object
            
        foreach($mail in $mailList)
        {
            $output = Resolve-DnsName -Name $mail -Type DNAME |
                Select Name,PrimaryServer,NameAdministrator |
                    Where-Object {$_.NameAdministrator.Contains($nameAdmin) -and
                        $_.PrimaryServer.Contains($primaryServer) }

            if($output -ne $null){
                $output
            }
               
        }
    }

}

Get-FilteredDnsInfo -mailList $emailList -nameAdmin "dns" -primaryServer ""

