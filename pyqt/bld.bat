:: This mkspec is an artificial one that we create (by copying) in the qt recipe.
:: This PyQt recipe depends on the new vc features specification, or else
:: this makespec will be wrong (or simply missing)
set QMAKESPEC=%LIBRARY_LIB%\qt4\mkspecs\win32-msvc-default

copy "%LIBRARY_BIN%\qt.conf" "%PREFIX%\qt.conf"
if errorlevel 1 exit 1

copy "%LIBRARY_BIN%\moc-qt4.exe" "%LIBRARY_BIN%\moc.exe"
if errorlevel 1 exit 1

%PYTHON% configure-ng.py --verbose ^
                         --confirm-license ^
                         --sysroot=%PREFIX% ^
                         --bindir="%LIBRARY_BIN%" ^
                         --destdir="%SP_DIR%"
if errorlevel 1 exit 1

:: This is necessary because the $< macro isn't appropriate where it gets
:: used (generated by something, qmake maybe).  Compilation hangs on a
:: warning.  This patching must be done AFTER the configure step, NOT
:: as a patch that we apply to the source code.
::
:: This solution copied from http://around-the-corner.typepad.com/adn/2015/05/building-sip-and-pyqt-for-maya-2016.html

pushd pylupdate
del moc_translator.cpp 2> nul
del moc_translator.obj 2> nul
moc.exe -o moc_translator.cpp translator.h
if errorlevel 1 exit 1
popd

nmake
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1

IF NOT EXIST "%PREFIX%\Scripts" (
   mkdir %PREFIX%\Scripts
)

@echo off
echo @echo off > %PREFIX%\Scripts\pyuic.bat
echo "%%~dp0\..\python.exe" "%%~dp0\..\Lib\site-packages\PyQt4\uic\pyuic.py" %%* >> %PREFIX%\Scripts\pyuic.bat

echo @echo off > %PREFIX%\Scripts\pyrcc4.bat
echo "%%~dp0\..\Lib\site-packages\PyQt4\pyrcc4" %%* >> %PREFIX%\Scripts\pyrcc4.bat
@echo on

del "%LIBRARY_BIN%\moc.exe"
