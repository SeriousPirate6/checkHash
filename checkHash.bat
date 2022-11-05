@echo off

@REM -
@REM Constants
@REM -
set sub=Output
set loc=location.txt
set hash_fs=full_hash_s.txt
set hash_ss=slim_hash_s.txt
set hash_fd=full_hash_d.txt
set hash_sd=slim_hash_d.txt


@REM -
@REM Creating location.txt file if not existent
@REM -
if not exist %loc% (
    echo Creating location file...
    type NUL > %loc%
)



@REM -
@REM Reading from file location.txt
@REM -
set /p dest=< %loc%



@REM -
@REM Checking if location.txt is empty
@REM -
if [%dest%]==[] (
    echo Location file is empty, you need to specify a path in which you want to copy your files.
    goto :end
)



@REM -
@REM Cheking if destination path is valid
@REM -
if exist %dest%\ (
    goto :start
) else if exist %dest% (
    echo The path entered correspond to a file. It must correspond to a folder.
    goto :end
) else (
    echo The path entered does not exists.
    goto :end
)



@REM -
@REM Starting standard procedure after have checked dest path
@REM -
:start



@REM -
@REM Asking user for source path
@REM -
set /p "source=Directory to copy and get every file checked with hash MD5: "



@REM -
@REM Cheking if source path is valid
@REM -
if not exist "%source%" (
    echo The path entered does not exists.
    goto :end
) else (
    FOR /F "delims=|" %%A IN ("%source%") do set s_folder="%%~nxA"
)



@REM -
@REM Checking subfolder existance
@REM -
if not exist %sub%_%s_folder%\ mkdir %sub%_%s_folder%



@REM -
@REM Creating hash files
@REM -
type NUL > %sub%_%s_folder%\%hash_fs%
type NUL > %sub%_%s_folder%\%hash_ss%
type NUL > %sub%_%s_folder%\%hash_fd%
type NUL > %sub%_%s_folder%\%hash_sd%


cd %source%

setlocal disableDelayedExpansion


@REM -
@REM Looping through all files in the given path recursively, and extract the relative path of each of them
@REM -
for /f "tokens=*" %%a in ('forfiles /s /m *.* /c "cmd /c echo @relpath"') do (
    @REM -
    @REM Getting the MD5 hash of all files in the selected directory
    @REM -
    certutil -hashfile "%%~pnxa" MD5 >> %sub%_%s_folder%\%hash_fs%
    @REM -
    @REM error 0 represents the ordinary execution of the command
    @REM -
    if errorlevel 0 (
        echo Checksum completed!                        %%~pnxa
        echo -
    ) else (
        echo ->> %sub%_%s_folder%\%hash_fs%
        echo Cannot perform the checksum on this file!  %%~pnxa
        echo -
    )
    :1
    set "file=%%~a"
    setlocal enableDelayedExpansion
    @REM -
    @REM Performing xcopy of the current file in the dest folder
    @REM Piping F into the xcopy command line to select file by default
    @REM -
    echo F|xcopy /S /Y /F %source%\!file:~2! %dest%\%s_folder%\!file:~2!
    certutil -hashfile "%dest%\%s_folder%\!file:~2!" MD5 >> %sub%_%s_folder%\%hash_fd%
    if errorlevel 0 (
        @REM echo Checksum completed!                        %%G
        @REM echo -
    ) else (
        @REM echo ->> %sub%_%s_folder%\%hash_f%
        @REM echo Cannot perform the checksum on this file!  %%G
        @REM echo -
    )
    endlocal
)



@REM -
@REM filtering all the lines of the output that not contains ":"
@REM -
type %sub%_%s_folder%\%hash_fs% | findstr /V ":" > %sub%_%s_folder%\%hash_ss%
type %sub%_%s_folder%\%hash_fd% | findstr /V ":" > %sub%_%s_folder%\%hash_sd%



@REM -
@REM Exit
@REM -
:end



pause>nul