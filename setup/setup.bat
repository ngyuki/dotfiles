@echo off

cd /d "%~dp0"
bash --norc --noprofile 01-bash.sh
bash --norc --noprofile 02-git.sh
call %~dp0\link.bat

pause
