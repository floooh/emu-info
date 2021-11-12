bmp2cpc m1.txt imgtop.bmp imgtop.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
bmp2cpc m1.txt imgbot.bmp imgbot.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos intsync.asm intsync.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfs -nd intsync.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfs intsync.dsk -f -p intsync.bin
if %ERRORLEVEL% NEQ 0 goto :errorend


goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end