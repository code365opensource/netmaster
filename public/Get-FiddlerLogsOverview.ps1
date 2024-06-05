function Get-FiddlerLogsOverview {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$file
    )

    $stream = [System.IO.Compression.ZipFile]::OpenRead($file).GetEntry("_index.htm").Open()
    $reader = [System.IO.StreamReader]::new($stream)
    $content = $reader.ReadToEnd()
    $stream.Close()
    $reader.Close()
    # Use regular expressions to extract the content of the table within the body
    $tableContent = [regex]::Match($content, '<table[^>]*>(.*?)</table>', [System.Text.RegularExpressions.RegexOptions]::Singleline).Groups[1].Value

    # Convert the table content to a PowerShell hashtable
    $table = @()
    $tableRows = [regex]::Matches($tableContent, '<tr>(.*?)</tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)

    foreach ($row in $tableRows) {
        $columns = [regex]::Matches($row.Groups[1].Value, '<td>(.*?)</td>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if (!$columns -or $columns.Count -lt 8) {
            continue
        }
        
        $obj = New-Object -TypeName PSCustomObject -Property @{
            "Seq"         = $columns[1].Groups[1].Value
            "Result"      = $columns[2].Groups[1].Value
            "Protocol"    = $columns[3].Groups[1].Value
            "Host"        = $columns[4].Groups[1].Value
            "URL"         = $columns[5].Groups[1].Value
            "Body"        = $columns[6].Groups[1].Value
            "ContentType" = $columns[8].Groups[1].Value
        } -ErrorAction SilentlyContinue

        if ($null -ne $obj) {
            $table += $obj
        }
    }

    # Display the extracted content as a PowerShell hashtable
    $table | Select-Object Seq, Result, Protocol, Host, URL, Body, ContentType
}