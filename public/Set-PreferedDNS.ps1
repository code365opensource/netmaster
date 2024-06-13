function Set-PreferedDNS {
    [CmdletBinding()]
    param ()

    $DNSServers = ("1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001");
    $Dohtemplate = "https://cloudflare-dns.com/dns-query"

    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object { 
        Set-DnsClientServerAddress -InterfaceAlias $_.interfacealias -Addresses $DNSServers;
        $interfaceGUID = $_.InterfaceGuid;

        ("1.1.1.1", "1.0.0.1") | ForEach-Object {
            Set-InterfaceSpecificParameters -InterfaceGuid $interfaceGUID -DNSServer $_ -DohFlags 5 -Dohtemplate $Dohtemplate;
        }

        ("2606:4700:4700::1111", "2606:4700:4700::1001") | ForEach-Object {
            Set-InterfaceSpecificParameters -InterfaceGuid $interfaceGUID -DNSServer $_ -DohFlags 5 -Dohtemplate $Dohtemplate -ipv6;
        }

    }
    
}

function Set-InterfaceSpecificParameters {
    param(
        [string]$InterfaceGuid,
        [string]$DNSServer,
        [string]$DohFlags,
        [string]$Dohtemplate,
        [switch]$ipv6
    )

    $RegistryPath = "HKLM:\System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\$InterfaceGuid\DohInterfaceSettings\$(if($ipv6){"Doh6"}else{"Doh"})\$DNSServer"

    If (-NOT (Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }  

    New-ItemProperty -Path $RegistryPath -Name "DohFlags" -Value $DohFlags -PropertyType QWORD -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name "DohTemplate" -Value $Dohtemplate -PropertyType String -Force | Out-Null

}