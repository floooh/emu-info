setlocal EnableDelayedExpansion

FOR /F %%A IN (dirs.txt) DO (
pushd %%A
if !ERRORLEVEL! NEQ 0 goto :errorend
call build
if !ERRORLEVEL! NEQ 0 goto :errorend
popd
if !ERRORLEVEL! NEQ 0 goto :errorend
)

goto :ok
:errorend
%COMSPEC% /C exit 1 >nul
goto :end
:ok
%COMSPEC% /C exit 0 >nul
:end

