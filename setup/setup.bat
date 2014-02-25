@echo off

call %~dp0\link.bat

cd /d "%~dp0"
bash --norc --noprofile fix.sh

pause
