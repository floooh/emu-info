setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
pasmo --equ CPC=1 --equ SPEC=0 --amsdos drivetest.asm drivetest.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -e format -f "DATA" cpc_drivetest.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw	cpc_drivetest.dsk -f -b -p drivetest.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end
