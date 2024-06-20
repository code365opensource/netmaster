function Set-PreferredDNS {
    [CmdletBinding()]
    param (
        [string[]]$DNSServers_ipv4 = ("1.1.1.1", "1.0.0.1"),
        [string[]]$DNSServers_ipv6 = ("2606:4700:4700::1111", "2606:4700:4700::1001"),
        [string]$Dohtemplate = "https://cloudflare-dns.com/dns-query"
    )


    Clear-DnsClientCache

    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object { 
        Set-DnsClientServerAddress -InterfaceAlias $_.interfacealias -Addresses ($DNSServers_ipv4 + $DNSServers_ipv6);
        $interfaceGUID = $_.InterfaceGuid;

        $DNSServers_ipv4 | ForEach-Object {
            Set-InterfaceSpecificParameters -InterfaceGuid $interfaceGUID -DNSServer $_ -DohFlags 5 -Dohtemplate $Dohtemplate;
        }

        $DNSServers_ipv6 | ForEach-Object {
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