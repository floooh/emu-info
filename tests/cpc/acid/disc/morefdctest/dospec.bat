pasmo --equ CPC=0 --equ SPEC=1 --plus3dos checkdrv.asm checkdrv.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -e format -f "ZX0" spec_fdctest.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_fdctest.dsk -e label "ZX0.lbl"
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw spec_fdctest.dsk -f -b -p checkdrv.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end

