bmp2cpc m1.txt lotus.bmp lotus.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos intlace.asm intlace.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfs -nd intlace.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfs intlace.dsk -f -p intlace.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end

