setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
pasmo --bin --equ CPC=0 --equ SPEC=1 fdctest.asm fdctest.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
specaddhead -s 32768 -a fdctest.bin fdctest.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -e format -f "ZX0" spec_fdctest.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_fdctest.dsk -e label "ZX0.lbl"
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_fdctest.dsk -f -b -p fdctest.bin fdctest
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_fdctest.dsk -f -b -p loader.bas loader
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end

