@echo off

@REM -
@REM Constants
@REM -
set loc=location.txt

@REM -
@REM Checking param files existance
@REM -
if not exist %loc% type NUL > %loc%

set /p "file=Enter the file you want to copy and check with hash MD5: "

set /p pro=< %loc%