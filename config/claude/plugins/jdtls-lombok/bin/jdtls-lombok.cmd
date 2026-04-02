@echo off
REM Wrapper for jdtls that adds Lombok javaagent support.
REM Dynamically resolves the latest Lombok jar from Maven local repository.

setlocal enabledelayedexpansion

set "LOMBOK_REPO_DIR=%USERPROFILE%\.m2\repository\org\projectlombok\lombok"

if not exist "%LOMBOK_REPO_DIR%" (
    echo WARN: Lombok not found in Maven cache, starting jdtls without Lombok >&2
    jdtls %*
    exit /b %ERRORLEVEL%
)

set "LOMBOK_JAR="
for /f "delims=" %%f in ('dir /b /s /o:n "%LOMBOK_REPO_DIR%\lombok-*.jar" 2^>nul ^| findstr /v /i "sources javadoc"') do (
    set "LOMBOK_JAR=%%f"
)

if not defined LOMBOK_JAR (
    echo WARN: No Lombok jar found in %LOMBOK_REPO_DIR%, starting jdtls without Lombok >&2
    jdtls %*
    exit /b %ERRORLEVEL%
)

jdtls --jvm-arg="-javaagent:%LOMBOK_JAR%" %*
exit /b %ERRORLEVEL%
