@echo off

unison . "%1" -auto -ignore "Name *.lnk" -ignore "Name ~$*" -ignore "Name *.bat"
timeout /t 3
