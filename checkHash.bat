@echo off

@REM -
@REM Constants
@REM -
set sub=Output
set loc=location.txt
set hash_f=full_hash.txt
set hash_s=slim_hash.txt
set already_checked=false



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
type NUL > %sub%_%s_folder%\%hash_f%
type NUL > %sub%_%s_folder%\%hash_s%



@REM -
@REM Getting the MD5 hash of all files in the selected directory
@REM -
For /R "%source%" %%G IN (*.*) do (
    :1
    if "%already_checked%"=="false" (
        certutil -hashfile "%%G" MD5 >> %sub%_%s_folder%\%hash_f%
        @REM -
        @REM error 0 represents the ordinary execution of the command
        @REM -
        if errorlevel 0 (
            echo Checksum completed!                        %%G
            echo -
        ) else (
            echo ->> %sub%_%s_folder%\%hash_f%
            echo Cannot perform the checksum on this file!  %%G
            echo -
        )
        set already_checked=true
        echo %already_checked%
    )
    echo %source%\%%G   -   %dest%\%s_folder%\%%G
    if errorlevel 0 (
        @REM echo Checksum completed!                        %%G
        @REM echo -
    ) else (
        @REM echo ->> %sub%_%s_folder%\%hash_f%
        @REM echo Cannot perform the checksum on this file!  %%G
        @REM echo -
    )
)


@REM -
@REM filtering all the lines of the output that not contains ":"
@REM -
type %sub%_%s_folder%\%hash_f% | findstr /V ":" > %sub%_%s_folder%\%hash_s%



@REM -
@REM Exit
@REM -
:end



pause>nul