setlocal enableextensions enabledelayedexpansion
SET sol_dir=%~dpf1
SET build_path=%~dpf2

SET PATH=%PATH%;%build_path%

if not exist "%sol_dir%\bindings\java\JavaEvalTest\src\Main.java" (
  echo "The class src\Main.java does not exist"
  EXIT /B 1
)

if not exist "%sol_dir%\bindings\java\Swig\cntk.jar" (
  echo "The class cntk.jar does not exist"
  EXIT /B 1
)

"%JAVA_HOME%\bin\java" -Djava.library.path=%build_path% -classpath "%sol_dir%\bindings\java\JavaEvalTest\src;%sol_dir%\bindings\java\Swig\cntk.jar" Main || (
  echo "Running Java Failed"
  EXIT /B 1
)
