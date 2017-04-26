setlocal enableextensions enabledelayedexpansion
SET sol_dir=%~f1

echo "Generating Java binding..."
echo %sol_dir%

if not exist "%sol_dir%\bindings\java\Swig\com\microsoft\CNTK\" mkdir "%sol_dir%\bindings\java\Swig\com\microsoft\CNTK\"
"%SWIG_PATH%\swig.exe" -c++ -java -DMSC_VER -I%SOL_DIR%Source\CNTKv2LibraryDll\API -I%sol_dir%bindings\common -package com.microsoft.CNTK -outdir  %sol_dir%bindings\java\Swig\com\microsoft\CNTK  %sol_dir%bindings\java\Swig\cntk_java.i

cd "%sol_dir%\bindings\java\Swig"

REM: TODO: add check whether javac/jar exist.
echo building java

"%JAVA_HOME%\bin\javac" .\com\microsoft\CNTK\*.java
"%JAVA_HOME%\bin\jar" -cvf cntk.jar .\com\microsoft\CNTK\*.class
rd com /q /s

