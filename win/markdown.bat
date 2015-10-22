@echo off

rem ConEmu /cmd bash -c 'markdown $@' -- %*
markdown-preview -m -h github -c "%~dp0\..\lib\markdown.css" %*
