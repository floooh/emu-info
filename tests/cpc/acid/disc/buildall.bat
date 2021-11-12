setlocal EnableDelayedExpansion
color


pushd fdc
if !ERRORLEVEL! NEQ 0 goto :errorend
call build
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd drivetest
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend


pushd fdc_hang
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd fdc_lowlevel
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd fdc_poweron
if !ERRORLEVEL! NEQ 0 goto :errorend
call make
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd fdc_read
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend


pushd fdc_seek
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd fdc_wp
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd fdc_write
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend


pushd fdc_gen
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend



pushd fdctest3
if !ERRORLEVEL! NEQ 0 goto :errorend
call do
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

goto :ok
:errorend
color c7
%COMSPEC% /C exit 1 >nul
goto :end
:ok
color a7

%COMSPEC% /C exit 0 >nul
:end
