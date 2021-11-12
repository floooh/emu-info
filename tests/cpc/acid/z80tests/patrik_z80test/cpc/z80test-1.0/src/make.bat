setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
REM require sjasm 0.42b8
sjasm z80ccf.asm
if %ERRORLEVEL% NEQ 0 goto :errorend
sjasm z80doc.asm
if %ERRORLEVEL% NEQ 0 goto :errorend
sjasm z80docflags.asm
if %ERRORLEVEL% NEQ 0 goto :errorend
sjasm z80flags.asm
if %ERRORLEVEL% NEQ 0 goto :errorend
sjasm z80full.asm
if %ERRORLEVEL% NEQ 0 goto :errorend
sjasm z80memptr.asm
if %ERRORLEVEL% NEQ 0 goto :errorend

copy /y z80ccf.out data.bin 
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos cpc.asm z80ccf.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

copy /y z80doc.out data.bin 
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos cpc.asm z80doc.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

copy /y z80docflags.out data.bin 
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos cpc.asm z80docflags.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

copy /y z80flags.out data.bin 
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos cpc.asm z80flags.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

copy /y z80full.out data.bin 
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos cpc.asm z80full.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

copy /y z80memptr.out data.bin 
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos cpc.asm z80memptr.bin
if %ERRORLEVEL% NEQ 0 goto :errorend


cpcxfsw -f -nd z80ccf.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw z80ccf.dsk -f -p z80ccf.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -nd z80doc.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw z80doc.dsk -f -p z80doc.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -nd z80docflags.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw z80docflags.dsk -f -p z80docflags.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -nd z80flags.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw z80flags.dsk -f -p z80flags.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -nd z80full.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw z80full.dsk -f -p z80full.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw -f -nd z80memptr.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw z80memptr.dsk -f -p z80memptr.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
copy /y *.dsk ..
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end
