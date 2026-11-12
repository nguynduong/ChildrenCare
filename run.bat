@echo off
setlocal

set "JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.21.21-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ========================================================
echo   CHILDREN CARE SYSTEM - AUTO BUILD & RUNNER
echo ========================================================

cd /d "%~dp0"

echo [1/3] Kiem tra va bien dich Java source...
if not exist "target\classes" mkdir "target\classes"
if not exist "src\main\webapp\WEB-INF\classes" mkdir "src\main\webapp\WEB-INF\classes"

dir /s /b src\main\java\*.java > target\sources.txt
javac -encoding UTF-8 -cp "server-lib/*" -d target\classes @target\sources.txt
if %errorlevel% neq 0 (
    echo.
    echo [LOI] Bien dich source code that bai! Vui long kiem tra code.
    pause
    exit /b %errorlevel%
)

copy /y src\main\resources\database.properties target\classes\ >nul
xcopy /s /y /q target\classes src\main\webapp\WEB-INF\classes >nul

echo [2/3] Khoi dong Embedded Tomcat Server...
echo [3/3] Trinh duyet Brave se tu dong mo tai: http://localhost:8080
echo ========================================================
echo   SERVER DANG CHAY TAI: http://localhost:8080
echo   (Nhan Ctrl + C de dung server bat cu luc nao)
echo ========================================================

java -cp "target\classes;server-lib/*" com.childrencare.ServerRunner
pause
