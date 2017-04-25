setlocal enableextensions enabledelayedexpansion
SET sol_dir=%~dpf1
SET build_path=%~dpf2

SET PATH=%PATH%;%build_path%

cd "%sol_dir%\bindings\java\JavaEvalTest"
"%JAVA_HOME%\bin\javac" -cp "%sol_dir%\bindings\java\Swig\cntk.jar" src\Main.java || (
  echo "Java Compilation Failed"
  EXIT /B 1
)
"%JAVA_HOME%\bin\java" -Djava.library.path=%build_path% -classpath "%sol_dir%\bindings\java\JavaEvalTest\src;%sol_dir%\bindings\java\Swig\cntk.jar" Main || (
  echo "Running Java Failed"
  EXIT /B 1
)
