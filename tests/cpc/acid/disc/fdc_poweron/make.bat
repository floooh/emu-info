setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
pasmo --bin fdctest.asm game.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin single.asm cart.bin

buildcpr cart.bin cart.cpr
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end