foreach ($directory in @('Public', 'Private')) {
    $path  = Join-Path -Path $PSScriptRoot -ChildPath $directory
    if(Test-Path -Path $path ){
        Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object { . $_.FullName }
    }
}