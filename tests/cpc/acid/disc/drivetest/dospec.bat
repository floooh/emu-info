setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
pasmo --bin --equ CPC=0 --equ SPEC=1 drivetest.asm drivetest.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
specaddhead -s 32768 -a drivetest.bin drivetest.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -e format -f "ZX0" spec_drivetest.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_drivetest.dsk -e label "ZX0.lbl"
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_drivetest.dsk -f -b -p drivetest.bin drvtest
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_drivetest.dsk -f -b -p loader.bas loader
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end

