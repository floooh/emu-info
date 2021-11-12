setlocal EnableDelayedExpansion
set PATH=c:\tools;%PATH%
pasmo --bin page1.s page1.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page2.s page2.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page3.s page3.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page4.s page4.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page5.s page5.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page6.s page6.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page7.s page7.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page8.s page8.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page9.s page9.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page10.s page10.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page11.s page11.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page12.s page12.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page13.s page13.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page14.s page14.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page15.s page15.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page16.s page16.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page17.s page17.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page18.s page18.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page19.s page19.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page20.s page20.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page21.s page21.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page22.s page22.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page23.s page23.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page24.s page24.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page25.s page25.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page26.s page26.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page27.s page27.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page28.s page28.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page29.s page29.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page30.s page30.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin page31.s page31.bin
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin test.s test.bin test.lst
if %ERRORLEVEL% NEQ 0 goto :errorend
pasmo --bin boot.s boot.bin boot.lst
if %ERRORLEVEL% NEQ 0 goto :errorend

copy /b boot.bin+page1.bin+page2.bin+page3.bin+page4.bin+page5.bin+page6.bin+page7.bin+page8.bin+page9.bin+page10.bin+page11.bin+page12.bin+page13.bin+page14.bin+page15.bin+page16.bin+page17.bin+page18.bin+page19.bin+page20.bin+page21.bin+page22.bin+page23.bin+page24.bin+page25.bin+page26.bin+page27.bin+page28.bin+page29.bin+page30.bin+page31.bin cart.bin
if %ERRORLEVEL% NEQ 0 goto :errorend

buildcpr cart.bin cart.cpr
if %ERRORLEVEL% NEQ 0 goto :errorend

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end