function Get-ModulePath {
    [CmdletBinding()]
    Param()

    # Get the module base path
    $modulePath = $MyInvocation.MyCommand.Module.ModuleBase

    # Return the directory path
    Return $modulePath
}
