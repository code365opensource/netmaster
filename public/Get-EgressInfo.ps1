function Get-EgressInfo {
    # get basic information from ifconfig.me/all.json
    $ifconfigMe = Invoke-RestMethod -Uri "https://ifconfig.me/all.json"
    # get geo information from ipinfo.io
    $ipInfo = Invoke-RestMethod -Uri "https://ipinfo.io/$($ifconfigMe.ip)/json"

    # create a custom object with the information
    Merge-Object -Object1 $ifconfigMe -Object2 $ipInfo

    $ifconfigMe
}