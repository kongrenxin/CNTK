setlocal enableextensions enabledelayedexpansion
SET project_dir=%~f1
SET output_dir=%~f2

echo Generating Java binding...
echo The project directory is "%project_dir%"
echo The output directory is "%output_dir%"

if not exist "%project_dir%com\microsoft\CNTK\" mkdir "%project_dir%com\microsoft\CNTK\"
"%SWIG_PATH%\swig.exe" -c++ -java -DMSC_VER -I"%project_dir%..\..\..\Source\CNTKv2LibraryDll\API" -I"%project_dir%..\..\common" -package com.microsoft.CNTK -outdir  "%project_dir%com\microsoft\CNTK"  "%project_dir%cntk_java.i" || (
  echo Running SWIG for Java binding failed!
  EXIT /B 1
)

cd "%project_dir%"

REM: TODO: add check whether javac/jar exist.
echo Building java.

"%JAVA_HOME%\bin\javac" .\com\microsoft\CNTK\*.java || (
  echo Building Java binding failed!
  EXIT /B 1
)
"%JAVA_HOME%\bin\jar" -cvf cntk.jar .\com\microsoft\CNTK\*.class || (
  echo Creating cntk.jar failed!
  EXIT /B 1
)

rd com /q /s || (
  echo Deleting com directory failed!
  EXIT /B 1
)

REM build test projects
cd "%project_dir%..\JavaEvalTest"
echo Building java test projects.

"%JAVA_HOME%\bin\javac" -cp "%project_dir%cntk.jar" src\Main.java || (
  echo Building Java test project failed!
  EXIT /B 1
)

REM Copy java classes to output directory
echo Copy Java classes to "%output_dir%java"
if not exist "%output_dir%" (
  echo The output directory "%output_dir%" does not exist!
  EXIT /B 1
)
if not exist "%output_dir%java" (
  mkdir "%output_dir%java" || (
    echo Creating directory "%output_dir%java" failed!
    EXIT /B 1
  )
)
xcopy /Y "%project_dir%cntk.jar" "%output_dir%java\" || (
  echo Copying "%project_dir%cntk.jar" to "%output_dir%java" failed!
  EXIT /B 1)
xcopy /Y "%project_dir%..\JavaEvalTest\src\Main.class" "%output_dir%java\" || (
  echo Copying "%project_dir%..\JavaEvalTest\src\Main.class" to "%output_dir%java" failed!
  EXIT /B 1
)


