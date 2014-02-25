var args = WScript.Arguments;

if (args.length != 1)
{
    WScript.Echo("Invalid argument count");
    WScript.Quit(1);
}

var fn = args(0);

try
{
    var wsh = WScript.CreateObject("WScript.Shell");
    var lnk = wsh.CreateShortCut(fn);

    if (lnk.TargetPath.length == 0)
    {
        WScript.Echo("File is not shortcut ... " + fn);
        WScript.Quit(2);
    }
    else
    {
        WScript.Echo(lnk.TargetPath);
        WScript.Quit(0);
    }
}
catch (ex)
{
    WScript.Echo(ex.message);
    WScript.Quit(3);
}
