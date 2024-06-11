function Get-ModulePath {
    [CmdletBinding()]
    Param()

    # Get the full path of the currently executing script
    $scriptPath = $PSCommandPath

    # Extract the directory part of the path
    $moduleDirectory = Split-Path -Path $scriptPath -Parent
    $test = $MyInvocation.MyCommand.Module.ModuleBase
    # Return the directory path
    Return $test
}
