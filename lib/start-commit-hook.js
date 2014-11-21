var fs = WScript.CreateObject("Scripting.FileSystemObject");

var path = WScript.Arguments(0);
var msgfile = WScript.Arguments(1);
var cwd = WScript.Arguments(2);

var refname = (function(){
    var file = cwd + "\\.git\\HEAD";
    if (fs.fileExists(file) == false) {
        return "";
    }
    var stream = fs.OpenTextFile(file, 1, false);
    var line = stream.ReadLine();
    stream.Close();
    stream = null;
    return line;
}());

if (refname.length == 0) {
    WScript.Quit(0);
}

var issues = (function(){
    var arr = refname.split(/[-+\/]/);
    var len = arr.length;
    var ret = [];
    for (var i=0; i<len; i++) {
        if (/^\d+$/.test(arr[i])) {
            ret.push("#" + arr[i]);
        }
    }
    return ret;
}());

if (issues.length == 0) {
    WScript.Quit(0);
}

var msg = [];

if (fs.fileExists(msgfile)) {
    (function(){
        var stream = fs.OpenTextFile(msgfile, 1, false);
        while (stream.AtEndOfLine == false) {
            msg.push(stream.ReadLine());
        }
        stream.Close();
        stream = null;
    }());
}

if (msg.length == 0) {
    msg = [""];
}

msg[0] += " refs " + issues.join(" ");

(function(){
    var stream = fs.OpenTextFile(msgfile, 2, true);
    stream.Write(msg.join("\n"));
    stream.Close();
    stream = null;
}());
