setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
set DSK=crtc

FOR /F "tokens=1,2 delims=," %%A IN (files.txt) DO (
pasmo --amsdos %%A.asm %%A.bin
if !ERRORLEVEL! NEQ 0 goto :errorend
)


cpcxfsw -f -nd %DSK%1.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -nd %DSK%2.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend

FOR /F "tokens=1,2,3 delims=," %%A IN (files.txt) DO (
cpcxfsw %DSK%%%C.dsk -f -p %%A.bin %%B 
if !ERRORLEVEL! NEQ 0 goto :errorend
)


goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end