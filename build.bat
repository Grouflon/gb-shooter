@echo off
set TARGET=shooter.gb

set OBJ_DIR=.\obj\
set SRC_DIR=.\src\
set BIN_DIR=.\bin\
set MAIN_FILE=main.asm
set OBJ_FILE=main.o
set LINKFILE=linkfile

@echo compiling...
mkdir %OBJ_DIR% > NUL 2> NUL
.\tools\rgbasm.exe -i%SRC_DIR% -o%OBJ_DIR%%OBJ_FILE% %SRC_DIR%%MAIN_FILE%> NUL

@echo linking...
mkdir %BIN_DIR% > NUL 2> NUL
.\tools\rgblink.exe -o %BIN_DIR%%TARGET% %OBJ_DIR%%OBJ_FILE%

@echo fixing...
.\tools\rgbfix.exe -p0 -v %BIN_DIR%%TARGET%

if %ERRORLEVEL% NEQ 0 PAUSE