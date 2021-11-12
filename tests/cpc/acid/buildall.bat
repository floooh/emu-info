setlocal EnableDelayedExpansion
color

FOR /F %%A IN (dirs.txt) DO (
pushd %%A
if !ERRORLEVEL! NEQ 0 goto :errorend
call build
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend
)
pushd devices
if !ERRORLEVEL! NEQ 0 goto :errorend
call buildall
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd cpc\power_on_low_rom
if !ERRORLEVEL! NEQ 0 goto :errorend
call build
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd cpc\power_on_low_rom\visual
if !ERRORLEVEL! NEQ 0 goto :errorend
call build
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd cpc\mode3
if !ERRORLEVEL! NEQ 0 goto :errorend
call mode3
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd disc
if !ERRORLEVEL! NEQ 0 goto :errorend
call buildall
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd plus\power_on_test_cart
if !ERRORLEVEL! NEQ 0 goto :errorend
call make
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd plus\power_on_test_cart\visual
if !ERRORLEVEL! NEQ 0 goto :errorend
call make
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend


pushd crtc_detect
if !ERRORLEVEL! NEQ 0 goto :errorend
call make
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend


pushd z80tests\patrik_z80test\cpc\z80test-1.0\src
if !ERRORLEVEL! NEQ 0 goto :errorend
call make
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

pushd z80tests\woody\z80tests
if !ERRORLEVEL! NEQ 0 goto :errorend
call z80tests
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend

goto :ok
:errorend
color c0
%COMSPEC% /C exit 1 >nul
goto :end
:ok
color a0

%COMSPEC% /C exit 0 >nul
:end
