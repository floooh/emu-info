setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
pasmo --alocal --amsdos z80tests.asm bin\z80tests.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -nd z80tests.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw z80tests.dsk -f -p bin\z80tests.bin z80tests
if %ERRORLEVEL% NEQ 0 goto :errorend
goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end
