@echo off

@REM -
@REM Constants
@REM -
set sub=Output
set loc=location.txt
set hash=hash.txt

@REM -
@REM Checking param files existance
@REM -
if not exist %sub% mkdir %sub%
if not exist %sub%\%loc% type NUL > %sub%\%loc%

type NUL > %sub%\%hash%

set /p "source=Directory to copy and get every file checked with hash MD5: "

set /p pro=< %loc%

@REM -
@REM Getting the MD5 hash of all files in the selected directory
@REM -
For /R .\%sub% %%G IN (*.*) do (
    @REM -
    @REM filtering all the lines of the output that not contains ":"
    @REM -
    certutil -hashfile "%%G" MD5 | findstr /V ":">> %sub%\%hash%
    @REM -
    @REM error 0 represents the ordinary execution of the command
    @REM -
    if errorlevel 0 (
        echo Checksum completed!
	) else echo Cannot perform the checksum on this file!
)

pause>nul