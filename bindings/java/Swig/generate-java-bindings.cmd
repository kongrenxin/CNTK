setlocal enableextensions enabledelayedexpansion
SET project_dir=%~f1

echo Generating Java binding...
echo The project directory is "%project_dir%"

if not exist "%project_dir%\com\microsoft\CNTK\" mkdir "%project_dir%\com\microsoft\CNTK\"
"%SWIG_PATH%\swig.exe" -c++ -java -DMSC_VER -I%project_dir%\..\..\..\Source\CNTKv2LibraryDll\API -I%project_dir%\..\..\common -package com.microsoft.CNTK -outdir  %project_dir%\com\microsoft\CNTK  %project_dir%\cntk_java.i

cd "%project_dir%"

REM: TODO: add check whether javac/jar exist.
echo Building java

"%JAVA_HOME%\bin\javac" .\com\microsoft\CNTK\*.java
"%JAVA_HOME%\bin\jar" -cvf cntk.jar .\com\microsoft\CNTK\*.class

rd com /q /s

REM build test projects
cd "%project_dir%\..\JavaEvalTest"
echo Building java test projects

"%JAVA_HOME%\bin\javac" -cp "%project_dir%\cntk.jar" src\Main.java || (
  echo "Build Java test project Failed"
  EXIT /B 1
)



