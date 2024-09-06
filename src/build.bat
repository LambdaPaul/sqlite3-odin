@echo off

setlocal EnableDelayedExpansion

where /Q cl.exe || (
	set __VSCMD_ARG_NO_LOGO=1
	for /f "tokens=*" %%i in ('"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.VisualStudio.Workload.NativeDesktop -property installationPath') do set VS=%%i
	if "!VS!" equ "" (
		echo Cannot find VS
		exit /b 1
	)
	call "!VS!\VC\Auxiliary\Build\vcvarsall.bat" amd64 || exit /b 1
)

if "%VSCMD_ARG_TGT_ARCH%" neq "x64" (
	echo x64 mode required
	exit /b 1
)

pushd %~dp0

cl /nologo /Oi /TC /GF /MP /MT /utf-8 /O2 /c ".\sqlite3.c" /DSQLITE_OMIT_DEPRECATED /DSQLITE_OMIT_UTF16 /DSQLITE_OMIT_TEST_CONTROL

if not exist "..\lib" mkdir "..\lib"
lib /nologo sqlite3.obj /out:"..\lib\sqlite3.lib"

del sqlite3.obj

popd
