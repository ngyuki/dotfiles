@echo off

cd /d %~dp0\..\

if "%HOME%"=="" (
  echo "require %%HOME%%"
  goto END
)

echo.
echo *delete old dotfile ...
del /a "%HOME%\.gitignore"
del /a "%HOME%\.inputrc"

echo.
echo *create symlink ...
mklink "%HOME%\.gitignore" %cd%\gitignore
mklink "%HOME%\.inputrc"   %cd%\inputrc

:END
