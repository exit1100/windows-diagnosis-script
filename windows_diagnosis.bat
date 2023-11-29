@echo off
title 윈도우 취약점 진단 프로그램 [02분반 3조]
mode con cols=150 lines=20
echo.
echo.
echo.
echo    888       888 d8b               888                                           888 d8b                                              d8b           
echo    888   o   888 Y8P               888                                           888 Y8P                                              Y8P           
echo    888  d8b  888                   888                                           888                                                                
echo    888 d888b 888 888 88888b.   .d88888  .d88b.  888  888  888 .d8888b        .d88888 888  8888b.   .d88b.  88888b.   .d88b.  .d8888b  888 .d8888b   
echo    888d88888b888 888 888 "88b d88" 888 d88""88b 888  888  888 88K           d88" 888 888     "88b d88P"88b 888 "88b d88""88b 88K      888 88K       
echo    88888P Y88888 888 888  888 888  888 888  888 888  888  888 "Y8888b.      888  888 888 .d888888 888  888 888  888 888  888 "Y8888b. 888  Y8888b.  
echo    8888P   Y8888 888 888  888 Y88b 888 Y88..88P Y88b 888 d88P      X88      Y88b 888 888 888  888 Y88b 888 888  888 Y88..88P      X88 888      X88  
echo    888P     Y888 888 888  888  "Y88888  "Y88P"   "Y8888888P"   88888P'       "Y88888 888 "Y888888  "Y88888 888  888  "Y88P"   88888P' 888  88888P'  
echo                                                                                                     888                                             
echo                                                                                                Y8b d88P                                             
echo                                                                                                 "Y88P"                                               
echo                                                                                                               이예준, 양유나, 정찬하 - TEAM3   
echo                                                                                                              -------------------------------
echo                                                                                                                   %date% %time%
echo.
PAUSE

:: administrator privileges check
bcdedit >>nul 
if %errorlevel% == 1 (
echo Run with administrator privileges!
pause 
exit 
) 

:: ExaminerName
Set ExaminerName="team3(lee,yang,jung)"

:: yyyymmdd set
:: Korea Windows
SET yyyymmdd=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%

REM time set
set "HOUR=%time:~0,2%"
set "MINUTE=%time:~3,2%"
set "SECOND=%time:~6,2%"
if "%HOUR:~0,1%"==" " set "HOUR=0%HOUR:~1,1%"
if "%MINUTE:~0,1%"==" " set "MINUTE=0%MINUTE:~1,1%"
if "%SECOND:~0,1%"==" " set "SECOND=0%SECOND:~1,1%"
set "now=%yyyymmdd%%HOUR%%MINUTE%%SECOND%"


:: root path
Set root=.\diagnosis
Set BASEPATH=%root%\%now%
Set ACTION=%BASEPATH%\action

if not exist %root% (
mkdir %root%
)

:: Create Folder
if not exist %BASEPATH% (
mkdir %BASEPATH%
)
:: Create Action Folder
if not exist %ACTION% (
mkdir %ACTION%
)


:: file set
Set goodFile=%BASEPATH%\good.txt
Set badFile=%BASEPATH%\bad.txt
Set actionFile=%BASEPATH%\action.txt

:: count set
set /a good_cnt=0
set /a bad_cnt=0
set /a hand_cnt=0


:: initialize
set current=%date% %time%
echo %current% > %goodFile%
echo %current% > %badFile%


:: system log
echo currentTime : %current% > %BASEPATH%\info.txt
echo ExaminerName : %ExaminerName% >> %BASEPATH%\info.txt

:: IIS Path Set
set /p has_iis=Do you have IIS Server? (Enter Yes:1, No:0):
if "%has_iis%"=="1" (
    set /p iis_path=Enter IIS Server Path:
    echo You entered: %iis_path%
)

:: FTP Path Set
set /p has_ftp=Do you have FTP? (Enter Yes:1, No:0):
if "%has_ftp%"=="1" (
    set /p ftp_path=Enter FTP Path:
    echo You entered: %ftp_path%
)

:: DNS Server
set /p has_dns=Do you have DNS? (Enter Yes:1, No:0):
if "%has_dns%"=="1" (
    set /p dns_path=Enter DNS Path:
    echo You entered: %dns_path%
)


mode con cols=100 lines=30
timeout /t 2 /nobreak >nul


echo [W-01] Administrator 계정 이름 바꾸기
net user > account.txt
type account.txt | find /i "Administrator" > NUL
if %errorlevel% EQU 0 (
    echo [W-01] Administrator 계정이 존재함 - [취약] >> %badFile%
    echo. >> %ACTION%\W-01.txt
    echo [W-01] Administrator 계정이 존재함 - [취약] >> %ACTION%\W-01.txt
    echo [W-01] 시작 - 프로그램 - 제어판 - 관리도구 - 로컬 보안 정책 - 로컬 정책 - 보안옵션 >> %ACTION%\W-01.txt
    echo [W-01] Administrator 계정 이름 바꾸기를 유추하기 어려운 계정 이름으로 변경 >> %ACTION%\W-01.txt
    set /a bad_cnt+=1
    goto W-01-END
) else (
    echo [W-01] Administrator 계정이 존재하지 않음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-01-END
)
:W-01-END
del account.txt



echo [W-02] Guest 계정 상태
net user guest | find "활성 계정" | find "아니요" > NUL
if %errorlevel% EQU 1 (
    echo [W-02] Guest 계정이 활성화되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-02.txt
    echo [W-02] Guest 계정이 활성화되어 있음 - [취약] >> %ACTION%\W-02.txt
    echo [W-02] 시작 - 실행 - secpol.msc - Local Security Policy - Local Policies - Security Options >> %ACTION%\W-02.txt
    echo [W-02] Guest 계정 비활성화 >> %ACTION%\W-02.txt
    set /a bad_cnt+=1
    goto W-02-END
) else (
    echo [W-02] Guest 계정이 비활성화되어 있음- [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-02-END
)
:W-02-END


echo [W-03] [수동점검] 불필요한 계정 정리
echo [W-03] [수동점검] 불필요한 계정 정리 >> %ACTION%\W-03[수동점검].txt
net user | find /v "accounts for" | find /v "successfully" | find /v "-" >> %ACTION%\W-03[수동점검].txt
set /a hand_cnt+=1



echo [W-04] 계정 잠금 임계값 설정
net accounts | find "임계값" > thres.txt
for /f "tokens=3" %%a in (thres.txt) do set thres=%%a
if not %thres% leq 5 (
    echo [W-04] 임계값이 6 이상으로 설정되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-04.txt
    echo [W-04] 임계값이 6 이상으로 설정되어 있음 - [취약] >> %ACTION%\W-04.txt
    echo [W-04] 시작 - 실행 - secpol.msc - Account Policies - Account Lockout Policy >> %ACTION%\W-04.txt
    echo [W-04] 계정 잠금 임계값을 5번 이하의 값으로 설정 >> %ACTION%\W-04.txt
    set /a bad_cnt+=1
    goto W-04-END
) else (
    echo [W-04] 임계값이 5 이하로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-04-END
) 
:W-04-END
del thres.txt



echo [W-05] 해독 가능한 암호화를 사용하여 암호 저장 해제
secedit /export /cfg secpol.txt | find /v "작업을 성공적" | find /v "자세한 정보는" > NUL
type secpol.txt | find /I "ClearTextPassword" | find "0" > NUL
if %errorlevel% EQU 1 (
    echo [W-05] "사용"으로 설정되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-05.txt
    echo [W-05] "사용"으로 설정되어 있음 - [취약] >> %ACTION%\W-05.txt
    echo [W-05] 시작 - 실행 - secpol.msc - Account Policies - Password Policy >> %ACTION%\W-05.txt
    echo [W-05] ‘해독 가능한 암호화를 사용하여 암호 저장‘ 을 ‘사용 안 함＇으로 설정 >> %ACTION%\W-05.txt
    set /a bad_cnt+=1
    goto W-05-END
) else (
    echo [W-05] "사용 안 함"으로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-05-END
)
:W-05-END
del secpol.txt



echo [W-06] 관리자 그룹에 최소한의 사용자 포함
net localgroup Administrators | find /v "설명" > group.txt
set "userCount=0"
for /f "skip=6 delims=" %%i in (group.txt) do (
    set "line=%%i"
    set /a "userCount+=1"
)
if %userCount% gtr 2 (
    echo [W-06] 관리자 그룹에 최소한의 사용자 포함 - [취약] >> %badFile%
    echo. >> %ACTION%\W-06.txt
    echo [W-06] 관리자 그룹에 최소한의 사용자 포함 - [취약] >> %ACTION%\W-06.txt
    echo [W-06] Administrators 그룹에 포함된 불필요한 계정 제거 >> %ACTION%\W-06.txt
    echo [W-06] 시작 - 실행 - compmgmt.msc - Local Users and Groups - Groups >> %ACTION%\W-06.txt
    set /a bad_cnt+=1
    goto W-06-END
) else (
    echo [W-06] 관리자 그룹에 최소한의 사용자 포함 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-06-END
)
:W-06-END
del group.txt



echo [W-07] Everyone 사용 권한을 익명 사용자에게 적용
secedit /export /cfg LocalSecurityPolicy.txt > NUL
type LocalSecurityPolicy.txt | find /i "EveryoneIncludesAnonymous" | find "4,0" > NUL
if %errorlevel% EQU 1 (
    echo [W-07] Everyone 사용 권한을 익명 사용자에게 적용 정책이 "사용"으로 되어있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-07.txt
    echo [W-07] Everyone 사용 권한을 익명 사용자에게 적용 정책이 "사용"으로 되어있음 - [취약] >> %ACTION%\W-07.txt
    echo [W-07] 시작 - 실행 - secpol.msc - 로컬 정책 - 보안 옵션 >> %ACTION%\W-07.txt
    echo [W-07] Everyone 사용 권한을 익명 사용자에게 적용을 "사용 안 함"으로 설정  >> %ACTION%\W-07.txt
    set /a bad_cnt+=1
    goto W-07-END
) else (
    echo [W-07] Everyone 사용 권한을 익명 사용자에게 적용 정책이 "사용 안 함"으로 되어있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-07-END
)
:W-07-END
del LocalSecurityPolicy.txt



echo [W-08] 계정 잠금 기간 설정
net accounts | findstr /I /C:"잠금 기간" >> 1-08-LockTime.txt
for /f "tokens=1-6" %%a IN (1-08-LockTime.txt) DO SET LockTime=%%d
net accounts | findstr /I /C:"잠금 관찰 창" >> 1-08-LockReTime.txt
for /f "tokens=1-6" %%a IN (1-08-LockReTime.txt) DO SET LockReTime=%%e
set /a LockTime=%LockTime%
set /a LockReTime=%LockReTime%
if not %LockTime% EQU 60 (
    goto W-08-BAD
)
if not %LockReTime% EQU 60 (
    :W-08-BAD
    echo [W-08]"계정 잠금 기간" 및 "계정 잠금 기간 원래대로 설정 기간"이 설정되지 않음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-08.txt
    echo [W-08]"계정 잠금 기간" 및 "계정 잠금 기간 원래대로 설정 기간"이 설정되지 않음 - [취약] >> %ACTION%\W-08.txt
    echo [W-08] 시작 - 실행 - secpol.msc - 계정 정책 - 계정 잠금 정책 >> %ACTION%\W-08.txt
    echo [W-08] "계정 잠금 기간" 및 "계정 잠금 기간 원래대로 설정 기간"을 설정  >> %ACTION%\W-08.txt
    set /a bad_cnt+=1
    goto W-08-END
) else (
    echo [W-08]"계정 잠금 기간" 및 "계정 잠금 기간 원래대로 설정 기간"이 설정 되어있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-08-END
)
:W-08-END
del 1-08-LockTime.txt
del 1-08-LockReTime.txt



echo [W-09] 패스워드 복잡성 설정
secedit /export /cfg LocalSecurityPolicy.txt > NUL
TYPE LocalSecurityPolicy.txt | find /i "PasswordComplexity" | find "0" > NUL
if %errorlevel% EQU 0 (
    echo [W-09] "암호는 복잡성을 만족해야 함" 정책이 "사용 안 함"으로 되어있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-09.txt
    echo [W-09] "암호는 복잡성을 만족해야 함" 정책이 "사용 안 함"으로 되어있음 - [취약] >> %ACTION%\W-09.txt
    echo [W-09] 시작 - 실행 - secpol.msc - 계정 정책 - 암호 정책 >> %ACTION%\W-09.txt
    echo [W-09] "암호는 복잡성을 만족해야 함" 정책을 "사용"으로 설정 >>  %ACTION%\W-09.txt
    set /a bad_cnt+=1
    goto W-09-END
) else (
    echo [W-09] "암호는 복잡성을 만족해야 함" 정책이 "사용"으로 되어있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-09-END
)
:W-09-END
del LocalSecurityPolicy.txt



echo [W-10] 패스워드 최소 암호 길이
secedit /export /cfg LocalSecurityPolicy.txt > NUL
TYPE LocalSecurityPolicy.txt | find /i "MinimumPasswordLength" | find "MinimumPasswordLength =" > passwd.txt
for /f "tokens=1-3" %%a IN (passwd.txt) DO SET passwd_length=%%c
if %passwd_length% LSS 8 (
    echo [W-10] "최소 암호 길이"가 설정되지 않았거나 "8문자" 미만으로 설정되어 있음  - [취약] >> %badFile%
    echo. >> %ACTION%\W-10.txt
    echo [W-10] "최소 암호 길이"가 설정되지 않았거나 "8문자" 미만으로 설정되어 있음  - [취약] >> %ACTION%\W-10.txt
    echo [W-10] 시작 - 실행 - secpol.msc - 계정 정책 - 암호 정책 >> %ACTION%\W-10.txt
    echo [W-10] "최소 암호 길이"를 "8문자" 이상으로 설정 >>  %ACTION%\W-10.txt
    set /a bad_cnt+=1
    goto W-10-END
) else (
    echo [W-10] "최소 암호 길이"가 "8문자" 이상으로 설정 되어있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-10-END
)
:W-10-END
del LocalSecurityPolicy.txt
del passwd.txt



echo [W-11] 패스워드 최대 사용 기간
secedit /Export /cfg LocalSecurityPolicy.txt > NUL
TYPE LocalSecurityPolicy.txt | find /i "MaximumPasswordAge" | find /v "\" > NUL
TYPE LocalSecurityPolicy.txt | find "MaximumPasswordAge = " > passwd.txt
for /f "tokens=1-3" %%a IN (passwd.txt) DO SET passwd_length=%%c
if %passwd_length% GTR 90 (
    echo [W-11] "최대 암호 사용 기간"이 설정되지 않았거나 "90일"을 초과하는 값으로 설정되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-11.txt
    echo [W-11] "최대 암호 사용 기간"이 설정되지 않았거나 "90일"을 초과하는 값으로 설정되어 있음 - [취약] >> %ACTION%\W-11.txt
    echo [W-11] 시작 - 실행 - secpol.msc - 계정 정책 - 암호 정책 >> %ACTION%\W-11.txt
    echo [W-11] "최대 암호 사용 기간"을 "90일" 이하로 설정 >>  %ACTION%\W-11.txt
    set /a bad_cnt+=1
    goto W-11-END
) else (
    echo [W-11] "최대 암호 사용 기간"이 "90일" 이하로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-11-END
)
:W-11-END 
del LocalSecurityPolicy.txt
del passwd.txt 



echo [W-12] 패스워드 최소 사용 기간
secedit /Export /cfg LocalSecurityPolicy.txt > NUL
TYPE LocalSecurityPolicy.txt | find /i "MinimumPasswordAge" > NUL
TYPE LocalSecurityPolicy.txt | find "MinimumPasswordAge = " > passwd.txt
for /f "tokens=1-3" %%a IN (passwd.txt) DO SET passwd_minage=%%c
if %passwd_minage% EQU 0 (
    echo [W-12] "최소 암호 사용 기간"이 0으로 설정되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-12.txt
    echo [W-12] "최소 암호 사용 기간"이 0으로 설정되어 있음 - [취약] >> %ACTION%\W-12.txt
    echo [W-12] 시작 - 실행 - secpol.msc - 계정 정책 - 암호 정책 >> %ACTION%\W-12.txt
    echo [W-12] "최소 암호 사용 기간"을 0 이상으로 설정 >>  %ACTION%\W-12.txt
    set /a bad_cnt+=1
    goto W-12-END 
) else (
    echo [W-12] "최소 암호 사용 기간"이 0보다 큰 값으로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-12-END 
)
:W-12-END 
del LocalSecurityPolicy.txt
del passwd.txt



echo [W-13] 마지막 사용자 이름 표시 안함
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername | find "dontdisplaylastusername" | find "1" > NUL
if %errorlevel% NEQ 0 (
    echo [W-13] "마지막 사용자 이름 표시 안 함" 이 "사용 안 함"으로 설정되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-13.txt
    echo [W-13] "마지막 사용자 이름 표시 안 함" 이 "사용 안 함"으로 설정되어 있음 - [취약] >>%ACTION%\W-13.txt
    echo [W-13] 시작 - 실행 - secpol.msc - 로컬 정책 - 보안 옵션 >> %ACTION%\W-13.txt
    echo [W-13] "대화형 로그온 : 마지막 사용자 이름 표시 안 함" - "사용"으로 변경 >> %ACTION%\W-13.txt
    set /a bad_cnt+=1
    goto W-13-END 
) else (
    echo [W-13] "마지막 사용자 이름 표시 안 함" 이 "사용"으로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-13-END 
)
:W-13-END 


echo [W-14] 로컬 로그인 허용
secedit /EXPORT /CFG LocalSecurityPolicy.txt > NUL
type LocalSecurityPolicy.txt | findstr /I "SeinteractiveLogonRight" > SeinteractiveLogonRight.txt
for /f "tokens=1-3" %%a in (SeinteractiveLogonRight.txt) do set user_list=%%c
for /f "tokens=1-3 delims=," %%a in ("!user_list!") do (
    set "aFlag=0"
    set "bFlag=0"
    set "cFlag=0"
    if "%%a" equ "*S-1-5-32-544" (
        set "aFlag=1"
    ) else if "%%a" equ "*S-1-5-17" (
        set "aFlag=1"
    ) else if "%%a" equ "" (
        set "aFlag=1"
    )
    if "%%b" equ "*S-1-5-32-544" (
        set "bFlag=1"
    ) else if "%%b" equ "*S-1-5-17" (
        set "bFlag=1"
    ) else if "%%b" equ "" (
        set "bFlag=1"
    )
    if "%%c" equ "*S-1-5-32-544" (
        set "cFlag=1"
    ) else if "%%c" equ "*S-1-5-17" (
        set "cFlag=1"
    ) else if "%%c" equ "" (
        set "cFlag=1"
    )
    if !aFlag! equ 0 (
        goto W-14-BAD
    )
    if !bFlag! equ 0 (
        goto W-14-BAD
    )
    if !cFlag! equ 0 (
        goto W-14-BAD
    )
    echo [W-14] 로컬 로그인 허용 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-14-END
    :W-14-BAD
    echo [W-14] 로컬 로그인 허용 - [취약] >> %badFile%
    echo. >> %ACTION%\W-14.txt
    echo [W-14] 로컬 로그인 허용 - [취약] >> %ACTION%\W-14.txt
    echo [W-14] 시작 - 실행 - secpol.msc - 로컬 정책 - 사용자 권한 할당 >> %ACTION%\W-14.txt
    echo [W-14] Administrator, IUSR_외 다른 계정 및 그룹의 로컬 로그온 제한 >> %ACTION%\W-14.txt
    set /a bad_cnt+=1
    goto W-14-END
)
:W-14-END
del LocalSecurityPolicy.txt
del SeinteractiveLogonRight.txt
endlocal


echo [W-15] 익명 SID/이름 변환 허용 해제
secedit /EXPORT /CFG LocalSecurityPolicy.txt > NUL
type LocalSecurityPolicy.txt | findstr /I "LSAAnonymousNameLookup" > W-15-tmp.txt
for /f "tokens=1-3" %%a IN (W-15-tmp.txt) DO SET value=%%c
if %value% NEQ 0 (
    echo [W-15] 익명 SID/이름 변환 허용 해제 - [취약] >> %badFile%
    echo. >> %ACTION%\W-15.txt
    echo [W-15] 익명 SID/이름 변환 허용 해제 - [취약] >> %ACTION%\W-15.txt
    echo [W-15] 시작 - 실행 - secpol.msc - 로컬 정책 - 보안옵션 >> %ACTION%\W-15.txt 
    echo [W-15] 네트워크 액세스 : 익명 SID/이름 변환 허용 - 사용 안함 >> %ACTION%\W-15.txt
    set /a bad_cnt+=1
    goto W-15-END
) else (
    echo [W-15] 익명 SID/이름 변환 허용 해제 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-15-END
)
:W-15-END
del LocalSecurityPolicy.txt
del W-15-tmp.txt



echo [W-16] 최근 암호 기억
secedit /EXPORT /CFG LocalSecurityPolicy.txt > NUL
type LocalSecurityPolicy.txt | findstr /I "PasswordHistorySize" > passwd.txt
for /f "tokens=1-3" %%a in (passwd.txt) do set passwd_hsize=%%c
if %passwd_hsize% lss 12 (
    echo [W-16] 최근 암호 기억 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-16-END
) else (
    echo [W-16] 최근 암호 기억 - [취약] >> %badFile%
    echo. >> %ACTION%\W-16.txt
    echo [W-16] 최근 암호 기억 - [취약] >> %ACTION%\W-16.txt
    echo [W-16] 시작 - 실행 - secpol.msc - 암호정책 >> %ACTION%\W-16.txt
    echo [W-16] 최근 암호 기억을 12개 암호로 설정 >> %ACTION%\W-16.txt
    set /a bad_cnt+=1
    goto W-16-END
)
:W-16-END
del LocalSecurityPolicy.txt
del passwd.txt



echo [W-17] 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한
set tempFile=temp.txt
secedit /export /cfg LocalSecurityPolicy.txt > NUL
type LocalSecurityPolicy.txt | find /i "LimitBlankPasswordUse" > %tempFile%
for /f "tokens=3" %%i in (%tempFile%) do (
    set limitSetting=%%i
)
if "!limitSetting!" EQU "4,1" (
    echo [W-17] 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-17-END
) else (
    echo [W-17] 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 - [취약] >> %badFile%
    echo. >> %ACTION%\W-17.txt
    echo [W-17] 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 - [취약] >> %ACTION%\W-17.txt
    echo [W-17] 시작 - 실행 - secpol.msc - 로컬 정책 - 보안 옵션 >> %ACTION%\W-17.txt
    echo [W-17] 계정 : 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 - 사용 >> %ACTION%\W-17.txt
    set /a bad_cnt+=1
    goto W-17-END
)
:W-17-END
del LocalSecurityPolicy.txt
del %tempFile%



echo [W-18] 원격터미널 접속 가능한 사용자 그룹 제한
echo. > Remote.txt
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" | find /i "fDenyTSConnections" | findstr "0x0" > nul
if %errorlevel% EQU 0 (
    GOTO :Remote
) else (
    echo [W-18] 원격 설정이 "이 컴퓨터에 대한 원격 연결 허용 안 함"으로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    GOTO :W-18-END
)
:Remote
net localgroup "Remote Desktop Users" | findstr /v "명령"> Remote.txt
set "userCount=0"
for /f "skip=6" %%i in (Remote.txt) do (
    set /a "userCount+=1"
)
if %userCount% equ 0 (
    echo [W-18] 원격터미널 접속 가능한 사용자 그룹 제한 - [취약] >> %badfile%
    echo. >> %ACTION%\W-18.txt
    echo [W-18] 원격터미널 접속 가능한 사용자 그룹 제한 - [취약] >> %ACTION%\W-18.txt
    echo [W-18] 원격접속이 가능한 별도의 계정이 존재하지 않음 >> %ACTION%\W-18.txt
    echo [W-18] 제어판 - 사용자 계정 - 계정 관리 - 관리자 계정 이외의 계정 생성 후 >> %ACTION%\W-18.txt
    echo [W-18] 제어판 - 시스템 - 원격 설정 - [원격] 탭 - [원격 데스크톱] 메뉴 선택 >> %ACTION%\W-18.txt
    echo [W-18] "이 컴퓨터에 대한 원격 연결 허용"에 체크 - "사용자 선택"에서 원격 사용자 지정 후 확인 >> %ACTION%\W-18.txt
    set /a bad_cnt+=1
    goto W-18-END  
) else (
    echo [W-18] 원격터미널 접속 가능한 사용자 그룹 제한 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-18-END  
)
:W-18-END    
del Remote.txt


echo [W-19] 공유 권한 및 사용자 그룹 설정
if not exist share_folder.txt (
    echo. > share_folder_authority.txt
)
net share | find /v "$" | find /v "명령" > share_folder.txt
FOR /F "tokens=2 skip=4" %%j IN (share_folder.txt) DO IF EXIST "%%j" icacls %%j >> share_folder_authority.txt
type share_folder_authority.txt | find /I "Everyone" >  Nul
if %errorlevel% EQU 0 (
    echo [W-19] 공유 권한 및 사용자 그룹 설정 - 공유 디렉토리 내 Everyone 권한 존재 - [취약] >> %badFile%
    echo. >> %ACTION%\W-19.txt
    echo [W-19] 공유 권한 및 사용자 그룹 설정 - 공유 디렉토리 내 Everyone 권한 존재 - [취약] >> %ACTION%\W-19.txt
    echo [W-19] 공유 디렉토리 접근 권한에서 Everyone 권한 제거 후 필요한 계정 추가 >> %ACTION%\W-19.txt
    echo [W-19] 실행 - FSMGMT.MSC - Shared Folders - Shares >> %ACTION%\W-19.txt
    set /a bad_cnt+=1
    goto W-19-END  
) else (
    echo [W-19] 공유 권한 및 사용자 그룹 설정 - 공유 디렉토리 내 Everyone 권한 없음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-19-END  
)
:W-19-END  
del share_folder.txt
del share_folder_authority.txt



echo [W-20] 하드디스크 기본 공유 제거
reg query "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" | find /i "AutoShareServer" | find "1" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [W-20] 레지스트리의 AutoShareServer가 1이며 기본 공유가 존재함 - [취약] >> %badFile%
    echo. >> %ACTION%\W-20.txt
    echo [W-20] 레지스트리의 AutoShareServer가 1이며 기본 공유가 존재함 - [취약] >> %ACTION%\W-20.txt
    echo [W-20] 실행 - FSMGMT.MSC - 공유 - 기본 공유 선택 - 우클릭 - 공유 중지 >> %ACTION%\W-20.txt
    set /a bad_cnt+=1
    goto W-20-END
)
net share | findstr /I "기본"
if %errorlevel% EQU 0 (
    echo [W-20] 기본 공유가 존재함 - [취약] >> %badFile%
    echo. >> %ACTION%\W-20.txt
    echo [W-20] 실행 - FSMGMT.MSC - 공유 - 기본 공유 선택 - 우클릭 - 공유 중지 >> %ACTION%\W-20.txt
    set /a bad_cnt+=1
    goto W-20-END
)
echo [W-20] 레지스트리의 AutoShareServer가 0이며 기본 공유가 존재하지 않음 - [양호] >> %goodFile%
set /a good_cnt+=1
:W-20-END


echo [W-21] [수동점검] 불필요한 서비스 제거
echo. >> %ACTION%\W-21[수동점검].txt
echo [W-21] [수동점검] 불필요한 서비스 제거 >> %ACTION%\W-21[수동점검].txt
echo [W-21] 불필요한 서비스 중지 후 "사용 안 함" 설정 >> %ACTION%\W-21[수동점검].txt
echo [W-21] 일반적으로 불필요한 서비스 : Alerter, Automatic Updates, Clipbook, Computer Browser, Cryptographic Service, DHCP Client, DNS Client 등..  >> %ACTION%\W-21[수동점검].txt
net start >> %ACTION%\W-21[수동점검].txt
set /a hand_cnt+=1


::IISVersion Parsing
set "iisRegKey=HKLM\SOFTWARE\Microsoft\InetStp"
for /f "tokens=3*" %%v in ('reg query "%iisRegKey%" /v "VersionString" ^| find "REG_SZ"') do (
    set "iisVersion=%%w")

echo [W-22] IIS 서비스 구동 점검
if defined iisVersion (
    @REM echo [W-22] IIS 버전: %iisVersion%
    if %iisVersion% geq 6 (
        echo [W-22] IIS 6.0 이상 버전 해당 사항 없음 - [양호] >> %goodFile%
        set /a good_cnt+=1
        goto W-22-END
    ) else (
        echo [W-22] IIS 5.0 이하 버전 - IIS 서비스 구동 점검 >> %ACTION%\W-22.txt
        reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters /s | find /i "1" > nul
        if %errorlevel% EQU 0 (
            echo [W-22] IIS 5.0 버전에서 해당 레지스트리 값이 1임 - [취약] >> %badFile%
            echo [W-22] IIS 5.0 버전에서 해당 레지스트리 값이 1임 - [취약] >> %ACTION%\W-22.txt
            echo [W-22] 시작 - 실행 - REGEDIT - HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters 검색 >> %ACTION%\W-22.txt
            echo [W-22] DWORD - SSLEnableCmdDirective 값이 0으로 입력 >> %ACTION%\W-22.txt
            set /a bad_cnt+=1
            goto W-22-END
        ) else (
            echo [W-22] IIS 5.0 버전에서 해당 레지스트리 값이 0이거나 IIS 6.0 버전 이상임 - [양호] >> %goodFile%
            set /a good_cnt+=1
            goto W-22-END
        )
    )
) else (
    echo [W-22] IIS 버전 정보를 찾을 수 없음. 설치X - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-22-END
)
:W-22-END
endlocal



echo [W-23] IIS 디렉토리 리스팅 제거
%systemroot%\System32\inetsrv\appcmd list config | find /i "directoryBrowse enabled=" | find /i "true" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [W-23] "디렉터리 검색" 이 "사용"으로 되어있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-23.txt
    echo [W-23] "디렉터리 검색" 이 "사용"으로 되어있음 - [취약] >> %ACTION%\W-23.txt
    echo [W-23] 사용하지 않는 경우 IIS 서비스 중지 >> %ACTION%\W-23.txt
    echo [W-23] 사용할 경우 디렉터리 검색 체크 해제 >> %ACTION%\W-23.txt
    echo [W-23] 제어판 - 관리도구 - 인터넷 정보 서비스 관리 - 해당 웹 사이트 - IIS - "디렉토리 검색" - "사용 안 함" >> %ACTION%\W-23.txt
    set /a bad_cnt+=1
    goto W-23-END
) else (
    echo [W-23] "디렉터리 검색" 이 "사용 안 함"으로 되어있음  - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-23-END
)
:W-23-END
endlocal


echo [W-24] IIS CGI 실행 제한
if exist C:\inetpub\scripts (
    goto cgi_authority
) else (
    goto W-24-GOOD
)
:cgi_authority
icacls "C:\Inetpub\scripts" | findstr /i "Everyone" | findstr /i "F" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [W-24] 해당 디렉토리에 Everyone에 모든 권한, 수정 권한, 쓰기 권한이 부여됨 - [취약] >> %badFile%
    echo. >> %ACTION%\W-24.txt
    echo [W-24] 해당 디렉토리에 Everyone에 모든 권한, 수정 권한, 쓰기 권한이 부여됨 - [취약] >> %ACTION%\W-24.txt
    echo [W-24] 사용하지 않는 경우 IIS 서비스 중지 >> %ACTION%\W-24.txt
    echo [W-24] 사용할 경우 탐색기 - 해당 디렉토리 - 속성 - 보안 - Everyone의 모든 권한, 수정 권한, 쓰기 권한 제거 >> %ACTION%\W-24.txt
    set /a bad_cnt+=1
    goto W_24_END
) else (
    :W-24-GOOD
    echo [W-24] 해당 디렉토리에 Everyone에 모든 권한, 수정 권한, 쓰기 권한이 부여되지 않음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W_24_END
)
:W_24_END
endlocal


echo [W-25] IIS 상위 디렉토리 접근 금지
type %systemroot%\System32\inetsrv\config\applicationHost.config | find /i "asp enableParentPaths" | find /i "true" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [W-25] 상위 패스 기능을 제거하지 않음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-25.txt
    echo [W-25] 상위 패스 기능을 제거하지 않음 - [취약] >> %ACTION%\W-25.txt
    echo [W-25] 사용하지 않는 경우 IIS 서비스 중지 >> %ACTION%\W-25.txt
    echo [W-25] 사용할 경우 제어판 - 관리도구 - 인터넷 정보 서비스 관리자 - 해당 웹사이트 - IIS - ASP 선택 - "부모 경로 사용" - "False" >> %ACTION%\W-25.txt
    set /a bad_cnt+=1
    goto W_25_END
) else (
    echo [W-25] 상위 패스 기능 제거되어 있음 - [양호]  >> %goodFile%
    set /a good_cnt+=1
    goto W_25_END
)
:W_25_END
endlocal


echo [W-26] IIS 불필요한 파일 제거
if defined iisVersion (
    if %iisVersion% geq 7 (
        echo [W-26] IIS 7.0 이상 버전 해당 사항 없음 - [양호] >> %goodFile%
        set /a good_cnt+=1
        goto W-26-END
    ) else (
        echo [W-26] IIS 6.0 이하 버전 - IIS 불필요한 파일 제거 >> %ACTION%\W-26.txt
        set "iisamplesPath=C:\inetpub\iissamples"
        set "iishelpPath=C:\winnt\help\isshelp"
        set "iisamplesExist=0"
        set "iishelpExist=0"
        if exist "!iisamplesPath!\" set "iisamplesExist=1"
        if exist "!iishelpPath!\" set "iishelpExist=1"
        if !iisamplesExist! EQU 1 (
            goto W-26-BAD
        if !iishelpExist! EQU 1 (
            :W-26-BAD
            echo [W-26] IISamples 가상 디렉토리가 존재함 - [취약] >> %badFile%
            echo. >> %ACTION%\W-26.txt
            echo [W-26] IISamples 가상 디렉토리가 존재함 - [취약] >> %ACTION%\W-26.txt
            echo [W-26] Sample 디렉토리 확인 후 삭제>> %ACTION%\W-26.txt
            echo [W-26] 인터넷 정보 서비스[IIS] 관리 - 해당 웹사이트 - 속성 - 홈 디렉토리 - 구성 - [옵션] 탭에서 설정 확인>> %ACTION%\W-26.txt
            echo [W-26] C:\inetpub\iissamples 삭제>> %ACTION%\W-26.txt
            echo [W-26] C:\winnt\help\iishelp 삭제>> %ACTION%\W-26.txt
            echo [W-26] C:\program files\common files\system\msadc\sample 삭제>> %ACTION%\W-26.txt
            echo [W-26] C:\Windows\System32\inetsrv 삭제>> %ACTION%\W-26.txt
            set /a bad_cnt+=1
            goto W-26-END
        )
        echo [W-26] IISamples 가상 디렉토리가 존재하지 않음 - [양호] >> %goodFile%
        set /a good_cnt+=1
        goto W-26-END
        )  
    )
) else (
    echo [W-26] IIS 버전 정보를 찾을 수 없음. 설치X - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-26-END
)
:W-26-END
endlocal



echo [W-27] IIS 웹 프로세스 권한 제한
if exist "%iis_path%\web.config" (
    icacls "%iis_path%\web.config" | find /i "nobody" | find /i "F" > nul
    if %errorlevel% NEQ 0 (
        goto W-27-BAD
    )
)
icacls "C:\inetpub\wwwroot" | find /i "nobody" | find /i "F" > nul
if %errorlevel% NEQ 0 (
    :W-27-BAD
    echo [W-27] 웹 프로세스가 관리자 권한이 부여된 계정으로 구동됨 - [취약] >> %badFile%
    echo. >> %ACTION%\W-27.txt
    echo [W-27] 웹 프로세스가 관리자 권한이 부여된 계정으로 구동됨 - [취약] >> %ACTION%\W-27.txt
    echo [W-27] IIS 웹 프로세스 권한 제한 - [취약] >> %ACTION%\W-27.txt
    echo [W-27] 시작 - 제어판 - 관리 도구 - 컴퓨터 관리 - 로컬 사용자 및 그룹 - 사용자 선택 - nobody 계정 추가 >> %ACTION%\W-27.txt
    echo [W-27] 시작 - 제어판 - 관리 도구 - 로컬 보안 정책 - 로컬 정책 - 사용자 권한 할당 선택, "서비스 로그온" 에 "nobody" 계정 추가>> %ACTION%\W-27.txt
    echo [W-27] 시작 - 프로그램 - 윈도우 탐색기 - IIS가 설치된 폴더 속성 - [보안] 탭에서 nobody 계정 추가하고 모든 권한 체크  >> %ACTION%\W-27.txt
    set /a bad_cnt+=1
    goto W-27-END
) else (
    echo [W-27] 웹 프로세스가 웹 서비스 운영에 필요한 최소한 권한으로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-27-END
)
:W-27-END


echo [W-28] [수동점검] IIS 링크 사용금지
echo. >> %ACTION%\W-28[수동점검].txt
echo [W-28] [수동점검] IIS 링크 사용금지 >> %ACTION%\W-28[수동점검].txt
echo [W-28] [수동점검] 실행 - INETMGR - 사이트 - 해당 웹페이지 - 기본설정 - 실제 경로[홈 디렉터리] 확인 >> %ACTION%\W-28[수동점검].txt
echo [W-28] [수동점검] 등록된 웹 사이트의 홈 디렉토리에 있는 심볼릭 링크, aliases, 바로가기 파일 삭제 >> %ACTION%\W-28[수동점검].txt
set /a hand_cnt+=1


echo [W-29] IIS 파일 업로드 및 다운로드 제한
type c:\Windows\System32\Inetsrv\config\applicationHost.config | findstr /i "RequestEntityAllowed" > nul
type c:\Windows\System32\Inetsrv\config\applicationHost.config | findstr /i "BufferingLimit" > nul
if %errorlevel% NEQ 0 (
    echo [W-29] 웹 프로세스의 서버 자원을 관리하지 않음[용량 미 제한] - [취약] >> %badFile%
    echo. >> %ACTION%\W-29.txt
    echo [W-29] 웹 프로세스의 서버 자원을 관리하지 않음[용량 미 제한] - [취약] >> %ACTION%\W-29.txt
    echo [W-29] 실행 - INETMGR - 사이트 - 해당 웹페이지 - ASP - 제한 속성 확인 >> %ACTION%\W-29.txt
    echo [W-29] 응답 버퍼링 제한 [다운로드 용량], 최대 요청 엔터티 본문 제한 [업로드 용량] >> %ACTION%\W-29.txt
    set /a bad_cnt+=1
    goto :W-29-END
) else (
    echo [W-29] 웹 프로세스의 서버 자원 관리를 위해 업로드 및 다운로드 용량을 제한함 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto :W-29-END
)
:W-29-END


echo [W-30] IIS DB 연결 취약점 점검
type %systemroot%\System32\inetsrv\config\applicationHost.config | findstr /i ".asa" >> W_30_RESULT.txt
if exist "%iis_path%\web.config" (
    type %iis_path%\web.config | findstr /i ".asa" >> W_30_RESULT.txt
)
type W_30_RESULT.txt | findstr /I "true" > NUL
if %errorlevel% EQU 0 (
    :W-30-BAD
    echo [W-30] IIS DB 연결 취약점 점검 - [취약] >> %badFile%
    echo. >> %ACTION%\W-30.txt
    echo [W-30] IIS DB 연결 취약점 점검 - [취약] >> %ACTION%\W-30.txt
    echo [W-30] 사용하기 않는 경우 IIS 서비스 중지 >> %ACTION%\W-30.txt
    echo [W-30] 사용할 경우 .asa 매핑을 특정 동작만 가능하도록 추가 - IIS 6.0 >> %ACTION%\W-30.txt
    echo [W-30] asa 설정을 false 함 - IIS 7.0, 8.0 >> %ACTION%\W-30.txt
    set /a bad_cnt+=1
    goto W-30-END
) else (
    echo [W-30] IIS DB 연결 취약점 점검 - [양호] >> %goodFile%	
    set /a good_cnt+=1
    goto W-30-END
)
:W-30-END
del W_30_RESULT.txt > nul


echo [W-31] IIS 가상 디렉터리 삭제 
set "iisRegKey=HKLM\SOFTWARE\Microsoft\InetStp"
for /f "tokens=3*" %%v in ('reg query "%iisRegKey%" /v "VersionString" ^| find "REG_SZ"') do (
    set "iisVersion=%%w")
if defined iisVersion (
    if %iisVersion% geq 6 (
        echo [W-31] IIS 6.0 이상 버전 해당 사항 없음 - [양호] >> %goodFile%
        set /a good_cnt+=1
        goto W-31-END
    ) else (
        echo [W-31] IIS 5.0 이하 버전 - IIS 가상 디렉터리 확인 >> %ACTION%\W-31.txt
        set "iisAdminExist=0"
        set "iisAdminpwdExist=0"
        appcmd list vdir "Default Web Site" | find /i "IISAdmin" > NUL
        if %errorlevel% EQU 0 (
            set "iisAdminExist=1"
        )
        appcmd list vdir "Default Web Site" | find /i "IISAdminpwd" > NUL
        if %errorlevel% EQU 0 (
            set "iisAdminpwdExist=1"
        )
        if !iisAdminExist! EQU 1 (
            goto W-31-BAD
        )
        if !iisAdminpwdExist! EQU 1 (
            :W-31-BAD
            echo [W-31] 해당 웹 사이트에 IIS Adminpwd 가상 디렉터리가 존재함 - [취약] >> %badFile%
            echo [W-31] 해당 웹 사이트에 IIS Adminpwd 가상 디렉터리가 존재함 - [취약] >> %ACTION%\W-31.txt
            echo [W-31] 시작 - 실행 - INETMGR - 웹 사이트 - IISAdmin, IISAdminpwd 선택 - 삭제 >> %ACTION%\W-31.txt
            set /a bad_cnt+=1
            goto W-31-END
        ) else (
            echo [W-31] 해당 웹 사이트에 IIS Adminpwd 가상 디렉터리가 존재하지 않음 - [양호] >> %goodFile%
            set /a good_cnt+=1
            goto W-31-END
        )
    )
) else (
    echo [W-31] IIS 버전 정보를 찾을 수 없음. 설치X - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-31-END
)
:W-31-END
endlocal


echo [W-32] [수동점검] IIS 데이터 파일 ACL 적용
echo. >> %ACTION%\W-32[수동점검].txt
echo [W-32] [수동점검] IIS 데이터 파일 ACL 적용 >> %ACTION%\W-32[수동점검].txt
echo [W-32] [수동점검] 실행 - INETMGR - 사이트 - 해당 웹페이지 - 기본설정 - 실제 경로[홈 디렉터리] 확인 >> %ACTION%\W-32[수동점검].txt
echo [W-32] [수동점검] 탐색기 - 홈 디렉터리 등록 정보 - [보안] 탭에서 Everyone 권한 확인 >> %ACTION%\W-32[수동점검].txt
echo [W-32] [수동점검] 불필요한 Everyone 권한 제거 >> %ACTION%\W-32[수동점검].txt
set /a hand_cnt+=1


echo [W-33] [수동점검] IIS 미사용 스크립트 매핑 제거
echo. >> %ACTION%\W-33[수동점검].txt
echo [W-33] [수동점검] IIS 미사용 스크립트 매핑 제거 >> %ACTION%\W-33[수동점검].txt
echo [W-33] [수동점검] 실행 - INETMGR - 사이트 - 해당 페이지 - 처리기 매핑 선택 - 취약한 매핑 제거 >> %ACTION%\W-33[수동점검].txt
set /a hand_cnt+=1


echo [W-34] IIS Exec 명령어 쉘 호출 진단
set "iisRegKey=HKLM\SOFTWARE\Microsoft\InetStp"
for /f "tokens=3*" %%v in ('reg query "%iisRegKey%" /v "VersionString" ^| find "REG_SZ"') do (
    set "iisVersion=%%w"
)
if defined iisVersion (
    @REM echo [W-34] IIS Exec 명령어 쉘 호출 진단: %iisVersion%
    if %iisVersion% geq 6 (
        echo [W-34] IIS 6.0 이상 버전 해당 사항 없음 N/A - [양호] >> %goodFile%
        set /a good_cnt+=1
        goto W-34-END
    ) else (
        @REM echo [W-34] IIS 5.0 이하 버전 - IIS Exec 명령어 쉘 호출 진단
        reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters" /v SSIEnableCmdDirective > nul
        if %errorlevel% EQU 0 (
            for /f "tokens=3*" %%x in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters" /v SSIEnableCmdDirective ^| find "REG_DWORD"') do (
                set "cmdDirectiveValue=%%y"
            )
            if !cmdDirectiveValue! EQU 1 (
                echo [W-34] IIS 5.0 버전에서 해당 레지스트리 값이 1인 경우 - [취약] >> %badFile%
                echo. >> %ACTION%\W-34.txt
                echo [W-34] IIS 5.0 버전에서 해당 레지스트리 값이 1인 경우 - [취약] >> %ACTION%\W-34.txt
                echo [W-34] 실행 - REGEDIT - HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters 검색 >> %ACTION%\W-34.txt
                echo [W-34] DWORD - SSIEnableCmdDirective 값 0으로 입력 >> %%ACTION%\W-34.txt
                set /a bad_cnt+=1
                goto W-34-END
            ) else (
                echo IIS 5.0 버전에서 해당 레지스트리 값이 0이거나, IIS 6.0 버전 이상인 경우 - [양호] >> %goodFile%
                set /a good_cnt+=1
                goto W-34-END
            )
        ) else (
            echo 레지스트리 값이 없거나 액세스할 수 없음 >> %ACTION%\W-34.txt
        )
    )
) else (
    echo [W-34] IIS 버전 정보를 찾을 수 없음. 설치X - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-34-END
)
:W-34-END
endlocal


echo [W-35] [수동점검] IIS WebDAV 비활성화
echo. >> %ACTION%\W-35[수동점검].txt
echo [W-35] [수동점검] IIS WebDAV 비활성화 >> %ACTION%\W-35[수동점검].txt
echo [W-35] [수동점검] 인터넷 정보 서비스 관리자 - 서버 선택 - IIS - "ISAPI 및 CGI 제한" 선택 >> %ACTION%\W-35[수동점검].txt
echo [W-35] [수동점검] WebDAV 사용 여부 확인 - 허용될 경우 취약 >> %ACTION%\W-35[수동점검].txt
echo [W-35] [수동점검] 인터넷 정보 서비스 관리자 - 서버 선택 - IIS - "ISAPI 및 CGI 제한" 선택 >> %ACTION%\W-35[수동점검].txt
echo [W-35] [수동점검] WebDAV 항목 선택 - [작업]에서 제거하거나 편집 - "확장 경로 실행 허용(A)" 체크 해제 >> %ACTION%\W-35[수동점검].txt
set /a hand_cnt+=1


echo [W-36] NetBIOS 바인딩 서비스 구동 점검
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /s /v ServiceName | find /v "검색"  >> W-36_RESULT.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" /s >> W-36_RESULT.txt
find "0x1" W-36_RESULT.txt > nul
if %errorlevel% equ 0 (
    echo [W-36] TCP/IP와 NetBIOS 간의 바인딩이 제거 되어있지 않음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-36.txt
    echo [W-36] TCP/IP와 NetBIOS 간의 바인딩이 제거 되어있지 않음 - [취약] >> %ACTION%\W-36.txt
    echo [W-36] 시작 - 실행 - ncpa.cpl - 로컬 영역 연결 - 속성 - TCP/IP4 - [일반] >> %ACTION%\W-36.txt
    echo [W-36] [고급] - [WINS] - TCP/IP - "NetBIOS 사용 안 함" >> %ACTION%\W-36.txt
    echo [W-36] 또는 "NetBIOS over TCP/IP 사용 안 함" 선택 >> %ACTION%\W-36.txt
    echo. >> %ACTION%\W-36.txt
    set /a bad_cnt+=1
    goto W-36-END
) else (
    echo [W-36] TCP/IP와 NetBIOS 간의 바인딩이 제거 되어있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-36-END
)
:W-36-END
del W-36_RESULT.txt
endlocal


echo [W-37] FTP 서비스 구동 점검
net start | find "Microsoft FTP Service" > nul
if %errorlevel% EQU 0 (
    echo [W-37] FTP 서비스를 사용함 - [취약] >> %badFile%
    echo. >> %ACTION%\W-37.txt
    echo [W-37] FTP 서비스를 사용함 - [취약] >> %ACTION%\W-37.txt
    echo [W-37] 시작 - 실행 - SERVICES.MSC - FTP Publishing Service - 속성 - [일반] >> %ACTION%\W-37.txt
    echo [W-37] "시작 유형"을 "사용 안 함"으로 설정한 후, FTP 서비스 중지 >> %ACTION%\W-37.txt
    set /a bad_cnt+=1
    goto W-37-END
) else (
    echo [W-37] FTP 서비스를 사용하지 않음 또는 FTP 서비스를 사용함 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-37-END
)
:W-37-END
endlocal


echo [W-38] FTP 디렉터리 접근 금지 권한 설정
net start | find "FTP" > nul
IF %ERRORLEVEL% EQU 1 (
    GOTO :DIRACL-FTP-DISABLE
) ELSE (
    GOTO :DIRACL-FTP-ENABLE
)
:DIRACL-FTP-DISABLE
echo [W-38] FTP 서비스가 비활성화되어 있음 - [양호] >> %goodFile%
set /a good_cnt+=1
GOTO W-38-END
:DIRACL-FTP-ENABLE
if exist "%ftp_path%" (
    icacls %ftp_path% | find /i "Everyone" > nul
    if %ERRORLEVEL% EQU 0 (
        goto W-38-BAD
    )
)
icacls "C:\Inetpub\ftproot" | find /i "Everyone" > nul
if %ERRORLEVEL% EQU 0 (
    :W-38-BAD
    echo [W-38] FTP 홈 디렉토리에 Everyone 권한이 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-38.txt
    echo [W-38] FTP 홈 디렉토리에 Everyone 권한이 있음 - [취약] >> %ACTION%\W-38.txt
    echo [W-38] 인터넷 정보 서비스 관리 - FTP 사이트 - 해당 FTP 사이트 - 속성 - "홈 디렉토리" >> %ACTION%\W-38.txt
    echo [W-38] FTP 홈 디렉토리 확인 >> %ACTION%\W-38.txt
    set /a bad_cnt+=1
    goto W-38-END
) else (
    echo [W-38] FTP 홈 디렉토리에 Everyone 권한이 없음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-38-END
)
:W-38-END
endlocal


echo [W-39] Anonymous FTP 금지
type %systemroot%\System32\inetsrv\config\applicationHost.config | findstr /I "<anonymousAuthentication enable=" | findstr /v "userName" > NUL
if %errorlevel% EQU 0 (
    echo [W-39] FTP 서비스를 사용함 또는 "익명 연결 허용"이 설정되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-39.txt
    echo [W-39] FTP 서비스를 사용함 또는 "익명 연결 허용"이 설정되어 있음 - [취약] >> %ACTION%\W-39.txt
    echo [W-39] 인터넷 정보 서비스 IIS 관리 - FTP 사이트 - FTP 인증 - "익명 인증" 사용 안 함 >> %ACTION%\W-39.txt
    set /a bad_cnt+=1
    goto W-39-END
) else ( 
    echo [W-39] FTP 서비스를 사용하지 않음 또는 "익명 연결 허용"이 설정되어 있지 않음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-39-END
)
:W-39-END
endlocal


echo [W-40] [수동점검] FTP 접근 제어 설정
echo. >> %ACTION%\W-40[수동점검].txt
echo [W-40] [수동점검] FTP 접근 제어 설정 >> %ACTION%\W-40[수동점검].txt
echo [W-40] [수동점검] 실행 - INETMGR - 사이트 - 해당 웹페이지 - FTP IP 주소 및 도메인 제한 >> %ACTION%\W-40[수동점검].txt
echo [W-40] [수동점검] [작업]의 허용 항목 추가에서 FTP 접속을 허용할 IP 입력 >> %ACTION%\W-40[수동점검].txt
echo [W-40] [수동점검] [작업]의 지능 설정 편집에서 지정되지 않은 클라이언트에 대한 액세스를 거부 선택 >> %ACTION%\W-40[수동점검].txt
set /a hand_cnt+=1


echo [W-41] DNS Zone Transfer 설정
tasklist | findstr /I dns.exe > nul
if %errorlevel% EQU 1 (
    echo [W-41] DNS 서비스 미사용 - [양호]  >> %goodFile%
    set /a good_cnt+=1
    goto W-41-END
)
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones\%dns_path%" > NUL 2>&1
if %errorlevel% EQU 1 (
    echo [W-41] DNS 서비스 관련 설정 값 존재 X - [양호]  >> %goodFile%
    set /a good_cnt+=1
    goto W-41-END
)
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones\%dns_path%" /v SecureSecondaries | find "2" > nul
if %ERRORLEVEL% EQU 0 (
    echo [W-41] DNS Zone Transfer 설정 - [양호]  >> %goodFile%
    set /a good_cnt+=1
    goto W-41-END
) else (
    echo [W-41] DNS Zone Transfer 설정 - [취약] >> %badFile%
    echo. >> %ACTION%\W-41.txt
    echo [W-41] DNS Zone Transfer 설정 취약- [취약] >> %ACTION%\W-41.txt
    echo [W-41]시작 - 실행 - DNSMGMT.MSC - 각 조회 영역 - 해당 영역 - 속성 - 영역 전송 >> %ACTION%\W-41.txt
    echo “다음 서버로만“ 선택 후 전송할 서버 IP 추가 >> %ACTION%\W-41.txt
    echo 불필요 시 해당 서비스 제거  >> %ACTION%\W-41.txt
    echo 시작 - 실행 - SERVICES.MSC - DNS서버 - 속성 [일반] 탭에서 “시작 유형”을 “사용 안 함＂으로 설정 후 >> %ACTION%\W-41.txt
    echo DNS 서비스 중지 >> %ACTION%\W-41.txt
    set /a bad_cnt+=1
    goto W-41-END
)
:W-41-END


echo [W-42] RDS(RemoteDataService) 제거
set "isVulnerable=0"
set "winRegKey=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
for /f "tokens=3*" %%v in ('reg query "%winRegKey%" /v "ProductName" ^| find "REG_SZ"') do (
    set "winVersion=%%w"
)
if defined winVersion (
    @REM echo [W-42] Windows 버전: %winVersion%
    if "%winVersion%" geq "2008" (
        echo [W-42] Windows 2008 이상 해당 사항 없음 N/A - [양호] >> %goodFile%
        set /a good_cnt+=1
        goto W-42-END
    ) else (
        reg query "HKLM\System\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch\RDSServer.DataFactory" > nul
        if %errorlevel% EQU 0 (
            set "isVulnerable=1"
        )
        reg query "HKLM\System\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch\Advanced.DataFactory" > nul
        if %errorlevel% EQU 0 (
            set "isVulnerable=1"
        )
        reg query "HKLM\System\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch\VbBusObj.VbBusObjCls" > nul
        if %errorlevel% EQU 0 (
            set "isVulnerable=1"
        )
        if %isVulnerable% EQU 1 (
            echo [W-42] 레지스트리 키가 존재함 - [취약] >> %badFile%
            echo. >> %ACTION%\W-42.txt
            echo [W-42] 레지스트리 키가 존재함 - [취약] >> %ACTION%\W-42.txt
            echo [W-42] 다음의 레지스트리 키, 디렉터리 제거 >> %ACTION%\W-42.txt
            echo [W-42] 'HKLM\System\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch\RDSServer.DataFactory' >> %ACTION%\W-42.txt
            echo [W-42] 'HKLM\System\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch\Advanced.DataFactory' >> %ACTION%\W-42.txt
            echo [W-42] 'HKLM\System\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch\VbBusObj.VbBusObjCls' >> %ACTION%\W-42.txt
            set /a bad_cnt+=1
            goto W-42-END
        ) else (
            echo [W-42] 레지스트리 키가 존재하지 않음 - [양호] >> %goodFile%
            set /a good_cnt+=1
            goto W-42-END
        )
    )
) else (
    echo [W-42] Windows 버전 정보를 찾을 수 없음 >> %ACTION%\W-42.txt
)
:W-42-END
endlocal



echo [W-43] 최신 서비스팩 적용
for /f "tokens=2 delims==" %%a in ('wmic os get ServicePackMajorVersion /value ^| find /i "ServicePackMajorVersion"') do SET "major=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get ServicePackMinorVersion /value ^| find /i "ServicePackMinorVersion"') do SET "minor=%%a"
if %major% EQU 0 if %minor% EQU 0 (
    echo [W-43] 최신 서비스팩 적용 안함 - [취약] >> %badFile%
    echo. >> %ACTION%\W-43.txt
    echo [W-43] 최신 서비스팩 적용 안함 - [취약] >> %ACTION%\W-43.txt
    echo [W-43] 실행 - "winver" 입력 - Windows 정보 확인 >> %ACTION%\W-43.txt
    echo [W-43] 서비스팩 확인 후 최신 버전이 아닐 경우 다운로드 후 설치 >> %ACTION%\W-43.txt
    set /a bad_cnt+=1
    goto W-43-END
) else (
    echo [W-43] 최신 서비스팩 적용 완료 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-43-END
)
:W-43-END


echo [W-44] 최신 HOT FIX 적용
wmic QFE Get HotFixID, InstalledOn > nul 2>&1
if %errorlevel% NEQ 0 (
    echo [W-44] 최신 HOT FIX 적용 - [취약]>> %badFile%
    echo [W-44] 최신 HOT FIX가 있는지 주기적으로 모니터링되지 않거나 최신 HOT FIX가 반영되지 않음 >> %ACTION%\W-44.txt
    echo [W-44] PMS Agent가 설치되어있지 않거나 설치되어있으나 자동패치배포가 적용되지 않음 >> %ACTION%\W-44.txt
    echo [W-44] [최신 HOT FIX 수동 설치] >> %ACTION%\W-44.txt
    echo [W-44] http://technet.microsoft.com/ko-kr/security/ - 접속 - 수동 설치 >> %ACTION%\W-44.txt
    echo [W-44] Windows Update - [비고] >> %ACTION%\W-44.txt
    echo [W-44] 보안 패치 및 HOT FIX 패치 적용 후, 시스템 재 시작을 요하는 경우가 많음 >> %ACTION%\W-44.txt
    echo [W-44] 관리자는 서비스에 지장이 없는 시간대에 적용하는 것을 권장 >> %ACTION%\W-44.txt
    echo [W-44] HOT FIX는 수행되고 있는 OS 프로그램 및 특히 개발되거나 구매한 Application에 영향을 줄 수 있음 >> %ACTION%\W-44.txt
    set /a bad_cnt+=1
    goto W-44-END
) else (
    echo [W-44] 최신 HOT FIX가 있는지 주기적으로 모니터링하고 반영되거나 PMS Agent가 설치되어 자동 패치 배포가 적용됨 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-44-END
)
:W-44-END



echo [W-45] [수동점검] 백신 프로그램 업데이트
echo. >> %ACTION%\W-45[수동점검].txt
echo [W-45] [수동점검] 백신 프로그램 업데이트 >> %ACTION%\W-45[수동점검].txt
echo [W-45] [수동점검] 백신 환경설정 메뉴를 통해 DB 및 엔진의 최신 업데이트를 하도록 설정 >> %ACTION%\W-45[수동점검].txt
echo [W-45] [수동점검] 담당자를 통해 바이러스 백신을 설치 후 엔진 업데이트를 설정 >> %ACTION%\W-45[수동점검].txt
set /a hand_cnt+=1


echo [W-46] [수동점검] 로그의 정기적 검토 및 보고
echo. >> %ACTION%\W-46[수동점검].txt
echo 시작 - 시스템 및 보안 - 관리도구 - 이벤트 로그 보기 >> %ACTION%\W-46[수동점검].txt
echo 응용 프로그램 로그, 보안 로그, 시스템 로그 분석 >> %ACTION%\W-46[수동점검].txt
set /a hand_cnt+=1


echo [W-47] 원격으로 액세스할 수 있는 레지스트리 경로
net start | find /I "Remote Registry" > nul
if %errorlevel% EQU 0 (
    echo [W-47] Remote Registry Service가 사용 중임 - [취약] >> %badFile%
    echo. >> %ACTION%\W-47.txt
    echo [W-47] Remote Registry Service가 사용 중임 - [취약] >> %ACTION%\W-47.txt
    echo [W-47] 불필요 시 서비스 중지 및 사용 안 함으로 설정 >> %ACTION%\W-47.txt
    echo [W-47] 실행 - SERVICES.MSC - Remote Registry 속성 - 시작 유형 - "사용 안 함", 서비스 상태 - 중지 >> %ACTION%\W-47.txt
    set /a bad_cnt+=1
    goto W-47-END
) else (
    echo [W-47] Remote Registry Service가 중지되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W-47-END
)
:W-47-END


echo [W-48] [수동점검] 백신 프로그램 설치
echo. >> %ACTION%\W-48[수동점검].txt
echo [W-48] [수동점검] 백신 프로그램 설치 >> %ACTION%\W-48[수동점검].txt
echo [W-48] 바이러스 백신 프로그램이 설치되어 있지 않음 >> %ACTION%\W-48[수동점검].txt
echo [W-48] 안철수 연구소: http://www.ahnlab.com >> %ACTION%\W-48[수동점검].txt
echo [W-48] 하우리: http://www.hauri.co.kr >> %ACTION%\W-48[수동점검].txt
echo [W-48] 노턴라이프락[구 시만텍]: https://kr.norton.com/ >> %ACTION%\W-48[수동점검].txt
echo [W-48] 한국트렌드마이크로: http://www.trendmicro.co.kr >> %ACTION%\W-48[수동점검].txt
echo [W-48] 알약: https://www.estsecurity.com/ >> %ACTION%\W-48[수동점검].txt
echo [W-48] 위 목록에 나열되지 않은 백신에 대해서도 인지도, 효과성 등을 검토하여 설치할 수 있음 >> %ACTION%\W-48[수동점검].txt
set /a hand_cnt+=1


echo [W-49] SAM 파일 접근 통제 설정 
set "SAMFile=SAM.txt"
echo. > SAM.txt
cacls %systemroot%\system32\config\SAM | findstr /I "F" > %SAMFile%
for /f %%A in ('type %SAMFile% ^| find /c /v ""') do set "Count=%%A"
if %Count% equ 2 (
    goto W_49_test
) else (
    goto W-49-BAD
)
:W_49_test
findstr /I "system" SAM.txt > nul
set "systemFound=%errorlevel%"
findstr /I "admin" SAM.txt > nul
set "adminFound=%errorlevel%"
if %systemFound% equ 0 if %adminFound% equ 0 (
    echo [W-49] SAM 파일 접근권한에 Administrator, System 그룹만 모든 권한으로 설정되어있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W_49_END
) else (
    :W-49-BAD
    echo [W-49] SAM 파일 접근권한에 Administrator, System 그룹 외 다른 그룹에 권한이 설정되어있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-49.txt
    echo [W-49] SAM 파일 접근권한에 Administrator, System 그룹 외 다른 그룹에 권한이 설정되어있음 - [취약] >> %ACTION%\W-49.txt
    echo [W-49] %systemroot%\system32\config\SAM-속성-보안 >> %ACTION%\W-49.txt
    echo [W-49] Administrator, System 그룹 외 다른 사용자 및 그룹 권한 제거 >> %ACTION%\W-49.txt
    set /a bad_cnt+=1
    goto W_49_END
)
:W_49_END
del %SAMFile%


echo [W-50] 화면보호기 설정
:: 화면보호기 실행 확인
reg query "HKEY_CURRENT_USER\Control Panel\Desktop" | findstr /I "SCRNSAVE.EXE" >nul
if %errorlevel% EQU 1 (
    goto W-50-BAD
) else (
    goto ScreenSaveTimeOut
)
:ScreenSaveTimeOut
:: ScreenSaveTimeOut 확인
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\Desktop" ^| findstr /I "ScreenSaveTimeOut"') do (
    set ScreenSaveTimeOut=%%a
)

if %ScreenSaveTimeOut% gtr 600 (
    goto W-50-BAD
) else (
    goto ScreenSaverIsSecure
)
:ScreenSaverIsSecure
:: ScreenSaverIsSecure 확인
reg query "HKEY_CURRENT_USER\Control Panel\Desktop" | findstr /I "ScreenSaverIsSecure" | findstr "0" > NUL
if %errorlevel% EQU 0 (
    :W-50-BAD
    echo [W-50] 화면보호기 설정 - [취약] >> %badFile%
    echo. >> %ACTION%\W-50.txt
    echo [W-50] 화면보호기 설정 - [취약] >> %ACTION%\W-50.txt
    echo [W-50] 화면 보호기가 설정되지 않았거나 화면 보호기 대기 시간이 10분을 초과함 >> %ACTION%\W-50.txt
    echo [W-50] "다시 시작할 때 로그온 화면 표시" 설정이 안 되어있음 >> %ACTION%\W-50.txt
    echo [W-50] 제어판 - 디스플레이 - 화면보호기 변경 - "다시 시작할 때 로그온 화면 표시" 체크>> %ACTION%\W-50.txt
    echo [W-50] "대기 시간" 10분 이하의 값으로 설정 >> %ACTION%\W-50.txt
    set /a bad_cnt+=1
    goto W_50_END
) else (
    echo [W-50] 화면보호기 설정 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W_50_END
)
:W_50_END


echo [W-51] 로그온하지 않고 시스템 종료 허용
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find /I "shutdownwithoutlogon" | find /I "1" > nul 2>&1
if %errorlevel% EQU 0 (
    echo [W-51] "로그온하지 않고 시스템 종료가 허용" 이 "사용"으로 설정되어 있음 - [취약] >> %badFile%
    echo. >> %ACTION%\W-51.txt
    echo [W-51] "로그온하지 않고 시스템 종료가 허용" 이 "사용"으로 설정되어 있음 - [취약] >> %ACTION%\W-51.txt
    echo [W-51] 시작 - 실행 - SECPOL.MSC - 로컬 정책 - 보안 옵션 >> %ACTION%\W-51.txt
    echo [W-51] "시스템 종료 : 로그온 하지 않고 시스템 종료 허용" 을 "사용 안 함"으로 설정 >> %ACTION%\W-51.txt
    set /a bad_cnt+=1
    goto W_51_END
) else (
    echo [W-51] "로그온하지 않고 시스템 종료가 허용" 이 "사용 안 함"으로 설정되어 있음 - [양호] >> %goodFile%
    set /a good_cnt+=1
    goto W_51_END
)
:W_51_END


echo [W-52] 원격 시스템에서 강제로 시스템 종료 
secedit /export /cfg secpol.txt > NUL
find /I "SeRemoteShutdownPrivilege" secpol.txt > SeRemoteShutdownPrivilege.txt
set "file=SeRemoteShutdownPrivilege.txt"
set "searchChar=,"
set "count=0"
for /f %%a in ('type "%file%" ^| find /c "%searchChar%"') do (
    set "count=%%a"
)
if %count% == 0 (
    type SeRemoteShutdownPrivilege.txt | findstr /I "*S-1-5-32-544" > NUL
    if %errorlevel% equ 0 (
        echo [W-52] "원격 시스템에서 강제로 시스템 종료" 정책에 "Administrators"만 존재함 - [양호] >> %goodFile% 
        set /a good_cnt+=1
        goto W_52_END
    ) else (
        goto W-52-BAD
    )
) else (
    :W-52-BAD
    echo [W-52] "원격 시스템에서 강제로 시스템 종료" 정책에 "Administrators"외 다른 계정 및 그룹이 존재함 - [취약] >> %badFile%
    echo. >> %Action%\W-52.txt
    echo [W-52] "원격 시스템에서 강제로 시스템 종료" 정책에 "Administrators"외 다른 계정 및 그룹이 존재함 - [취약] >> %Action%\W-52.txt
    echo [W-52] 시작 - 실행 - SECPOL.MSC - 로컬 정책 - 사용자 권한 할당 >> %Action%\W-52.txt
    echo [W-52] "원격 시스템에세 강제로 시스템 종료"정책에 Administrators 외 다른 계정 및 그룹 제거>> %Action%\W-52.txt
    set /a bad_cnt+=1
    goto W_52_END
) 
:W_52_END
del secpol.txt 
del SeRemoteShutdownPrivilege.txt


echo.
PAUSE

set /a total_cnt = good_cnt + bad_cnt + hand_cnt
set folder_open=0
mode con cols=60 lines=25
echo.
echo  ==========================================================
echo.
echo              Windows Server Diagnosis Complite
echo.
echo  ----------------------------------------------------------
echo.
echo     [*] 총 항목 : %total_cnt% 
echo.
echo     [*] 양호 : %good_cnt%  
echo.                   
echo     [*] 취약 : %bad_cnt%  
echo.                    
echo     [*] 수동점검 : %hand_cnt%    
echo.
echo     [*] 저장 폴더 경로 : %BASEPATH%
echo.
echo  ----------------------------------------------------------
echo     [*] 폴더를 여시겠습니까 [ Yes: 1 / No: 0 ] 
echo.
echo  ==========================================================
set /p choice=">> "
if %choice%==1 (
    start %BASEPATH%
)