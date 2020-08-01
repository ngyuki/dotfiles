start-process -wait bash -argumentlist "-c '
(
  set -x
  chmod +x ""/c/Program Files/Sublime Text 3/subl.exe""
  chmod +x ""/c/Program Files/Microsoft VS Code/Code.exe""
  chmod +x ""/c/Program Files/Microsoft VS Code/bin/code""
  chmod +x ""/c/Program Files/WinMerge/WinMergeU.exe""
  chmod +x ""/c/ProgramData/chocolatey/bin/unison.exe""
)
sleep 1
'" -verb runas
