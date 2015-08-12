@echo off
set TARGET=shooter.gb

set OBJ_DIR=.\obj\
set SRC_DIR=.\src\
set BIN_DIR=.\bin\
set MAIN_FILE=main.asm
set OBJ_FILE=main.o
set LINKFILE=linkfile


mkdir %OBJ_DIR% > NUL 2> NUL
.\tools\rgbasm.exe -i%SRC_DIR% -o%OBJ_DIR%%OBJ_FILE% %SRC_DIR%%MAIN_FILE%> NUL

@echo Writing linkfile...
@echo [Objects]> %OBJ_DIR%%LINKFILE%
@echo %OBJ_DIR%%OBJ_FILE%>> %OBJ_DIR%%LINKFILE%
@echo [Output]>> %OBJ_DIR%%LINKFILE%
@echo %BIN_DIR%%TARGET%>> %OBJ_DIR%%LINKFILE%

mkdir %BIN_DIR% > NUL 2> NUL
.\tools\rgblink.exe %OBJ_DIR%%LINKFILE%

.\tools\rgbfix.exe -p0 -v %BIN_DIR%%TARGET%

if %ERRORLEVEL% NEQ 0 PAUSE