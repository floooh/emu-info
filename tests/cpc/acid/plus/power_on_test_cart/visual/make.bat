setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
pasmo --bin poweron.asm poweron.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
buildcpr poweron.bin poweron.cdt
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end