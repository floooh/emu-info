setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
set DSK=multiplay.dsk

FOR /F "tokens=1,2 delims=," %%A IN (files.txt) DO (
pasmo --amsdos %%A.asm %%A.bin
if !ERRORLEVEL! NEQ 0 goto :errorend
)

cpcxfsw -f -nd %DSK%
if %ERRORLEVEL% NEQ 0 goto :errorend

FOR /F "tokens=1,2 delims=," %%A IN (files.txt) DO (
cpcxfsw %DSK% -f -p %%A.bin %%B 
if !ERRORLEVEL! NEQ 0 goto :errorend
)

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end