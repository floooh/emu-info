pasmo --equ CPC=1 --equ SPEC=0 --amsdos checkdrv.asm checkdrv.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

rem pasmo --equ CPC=1 --equ SPEC=0 --amsdos seektest.asm seektest.bin
rem if %ERRORLEVEL% NEQ 0 goto :errorend

rem pasmo --equ CPC=1 --equ SPEC=0 --amsdos smashhead.asm smashhead.bin
rem if %ERRORLEVEL% NEQ 0 goto :errorend

rem pasmo --equ CPC=1 --equ SPEC=0 --amsdos time.asm time.bin
rem if %ERRORLEVEL% NEQ 0 goto :errorend


cpcxfsw -f -e format -f "DATA" cpc_fdctest.dsk
cpcxfsw cpc_fdctest.dsk -f -b -p checkdrv.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
rem cpcxfsw cpc_fdctest.dsk -f -b -p seektest.bin
rem if %ERRORLEVEL% NEQ 0 goto :errorend
rem cpcxfsw cpc_fdctest.dsk -f -b -p smashhead.bin smashhd.bin
rem if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end

