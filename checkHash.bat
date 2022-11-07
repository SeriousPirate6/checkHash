@echo off


@REM -
@REM Constants
@REM -
set curdir=%cd%
set loc=location.txt
set hash_d=hash_dest.txt
set hash_s=hash_source.txt
set hash_fs=full_hash_s.txt
set hash_fd=full_hash_d.txt
set sub=%cd%\[HashedFiles]-


@REM -
@REM Creating location.txt file if not existent
@REM -
if not exist "%loc%" (
    echo Creating location file...
    type NUL > "%loc%"
)


@REM -
@REM Reading from file location.txt
@REM -
set /p dest=< "%loc%"


@REM -
@REM Checking if location.txt is empty
@REM -
if ["%dest%"]==[] (
    echo Location file is empty, you need to specify a path in which you want to copy your files.
    goto :end
)


@REM -
@REM Cheking if destination path is valid
@REM -
if exist "%dest%"\ (
    goto :start
) else if exist "%dest%" (
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
@REM Fixed path example (debug use only)
@REM -
@REM set source=C:\Users\User\ExampleFolder


@REM -
@REM Cheking if source path is valid
@REM -
if not exist "%source%" (
    echo The path entered does not exists.
    goto :end
) else (
    FOR /F "delims=|" %%A IN ("%source%") do set s_folder=%%~nxA
)
echo "%s_folder%"

@REM -
@REM Checking subfolder existance
@REM -
if not exist "%sub%%s_folder%"\ mkdir "%sub%%s_folder%"


@REM -
@REM Creating hash files
@REM -
type NUL > "%sub%%s_folder%"\"%hash_fs%"
type NUL > "%sub%%s_folder%"\"%hash_s%"
type NUL > "%sub%%s_folder%"\"%hash_fd%"
type NUL > "%sub%%s_folder%"\"%hash_d%"


@REM -
@REM Assigning the source folder as working directory
cd "%source%"
echo -
echo Changed directory to: %cd%
echo -


setlocal disableDelayedExpansion


@REM -
@REM Looping through all files in the given path recursively, and extract the relative path of each of them
@REM -
for /f "tokens=*" %%a in ('forfiles /s /m *.* /c "cmd /c echo @relpath"') do (
    set file=%%~a
    set size=%%~za
    @REM -
    @REM Getting the MD5 hash of all files in the selected directory
    @REM -
    setlocal enableDelayedExpansion
    echo -
    echo !file:~2!  -  !size! byte
    echo -
    if !size! gtr 0 (
        certutil -hashfile "!file:~2!" MD5 > %sub%"%s_folder%"\%hash_fs%
        @REM -
        @REM error 0 represents the ordinary execution of the command
        @REM -
        if errorlevel 0 (
            echo SOURCE:    Checksum completed                        "%source%"\"!file:~2!"
            echo -
        ) else (
            echo ->> %sub%"%s_folder%"\%hash_fs%
            echo SOURCE:    Cannot perform the checksum on this file  "%source%"\"!file:~2!"
            echo -
        )
        @REM -
        @REM Performing xcopy of the current file in the dest folder
        @REM Piping F into the xcopy command line to select file by default
        @REM -
        :1
        echo F|xcopy /S /Y /F "%source%"\"!file:~2!" "%dest%"\"%s_folder%"\"!file:~2!" > nul
        echo Copy completed!
        echo -
        certutil -hashfile "%dest%"\"%s_folder%"\"!file:~2!" MD5 > "%sub%%s_folder%"\"%hash_fd%"
        if errorlevel 0 (
            echo DEST:      Checksum completed                        "%dest%"\"%s_folder%"\"!file:~2!"
            echo -
        ) else (
            echo ->> "%sub%%s_folder%"\"%hash_fd%"
            echo DEST:      Cannot perform the checksum on this file  "%dest%"\"%s_folder%"\"!file:~2!"
            echo -
            del "%dest%"\"%s_folder%"\"!file:~2!" >  nul
            echo Deleting "%dest%"\"%s_folder%"\"!file:~2!" because the file is corrupted!
            echo -
            goto 1
        )
        @REM -
        @REM filtering all the lines of the output that not contains ":"
        @REM -
        type "%sub%%s_folder%\%hash_fs%" | findstr /V ":" >> "%sub%%s_folder%\%hash_s%"
        type "%sub%%s_folder%\%hash_fd%" | findstr /V ":" >> "%sub%%s_folder%\%hash_d%"
        @REM -
        @REM Saving last source and destination hashes
        @REM -
        for /F "UseBackQ Delims==" %%A in ("%sub%%s_folder%\%hash_s%") do set "last_source_hash=%%A"
        for /F "UseBackQ Delims==" %%A in ("%sub%%s_folder%\%hash_d%") do set "last_dest_hash=%%A"
        @REM -
        @REM Check if source and destination hashes of the file are equals
        @REM -
        if not "!last_source_hash!"=="!last_dest_hash!" (
            echo ->> "%sub%%s_folder%"\"%hash_fd%"
            echo The calculated hashes results do not match!
            echo -
            echo SOURCE HASH:    -   !last_source_hash!
            echo DEST   HASH:    -   !last_dest_hash! 
            echo -
            del "%dest%"\"%s_folder%"\"!file:~2!" > nul
            echo Deleting "%dest%"\"%s_folder%"\"!file:~2!" because the file is corrupted!
            echo -
            goto 1
        )
    )
    endlocal
)


@REM -
@REM Deleting full_hash files
@REM -
del "%sub%%s_folder%"\"%hash_fs%"
del "%sub%%s_folder%"\"%hash_fd%"


@REM -
@REM Saving the hashes of the list files themselves
@REM -
for /F "tokens=*" %%i in ('certutil -hashfile "%sub%%s_folder%"\"%hash_s%" MD5 ^| findstr /V ":"') do set source_hash=%%i
for /F "tokens=*" %%i in ('certutil -hashfile "%sub%%s_folder%"\"%hash_d%" MD5 ^| findstr /V ":"') do set dest_hash=%%i


@REM -
@REM Checking if the hashes of list files are equals
@REM Proving the whole copy process is gone all right
@REM -
if "%source_hash%"=="%dest_hash%" (
    echo -
    echo Copy completed, the files are ALL CHECKED!
    echo -
    echo SOURCE:    %source_hash%
    echo DEST:      %dest_hash%
    echo -
)


@REM -
@REM Back to the initial working directory
@REM -
cd "%curdir%"


@REM -
@REM Exit point
@REM -
:end


@REM -
@REM Prevents to wipe out the console
@REM -
pause>nul