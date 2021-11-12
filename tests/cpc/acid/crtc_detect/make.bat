set PATH=%PATH%;c:\tools
pasmo --amsdos crtc_12_01_2005_v3_0_offset.asm crtc_12_01_2005_v3_0_offset.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos crtc_amstlive_05_2000_madram.asm crtc_amstlive_05_2000_madram.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos crtc_amstlive_06_2002_madram.asm crtc_amstlive_06_2002_madram.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos batman_begins_rhino.asm batman_begins_rhino.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos crtc_13_04_1991_v1_1_longshot.asm crtc_13_04_1991_v1_1_longshot.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --amsdos crtc_v1_1_longshot.asm crtcv1_1_longshot.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

cpcxfsw -f -nd crtctype.dsk
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw crtctype.dsk -f -p crtc_12_01_2005_v3_0_offset.asm ofstv30.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw crtctype.dsk -f  -p crtc_amstlive_05_2000_madram.asm madram00.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw crtctype.dsk -f  -p crtc_amstlive_06_2002_madram.asm madram02.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw crtctype.dsk  -f -p batman_begins_rhino.asm rhino.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw crtctype.dsk  -f -p crtc_13_04_1991_v1_1_longshot.asm longshot.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
cpcxfsw crtctype.dsk  -f -p crtc_v1_1_longshot.asm longshot2.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end
