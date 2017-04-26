setlocal enableextensions enabledelayedexpansion
SET build_path=%~dpf1

SET PATH=%PATH%;%build_path%

if not exist "%build_path%\java\Main.class" (
  echo "%build_path%\java\Main.class" does not exist!
  EXIT /B 1
)

if not exist "%build_path%\java\cntk.jar" (
  echo "%build_path%\java\cntk.jar" does not exist!
  EXIT /B 1
)

"%JAVA_HOME%\bin\java" -Djava.library.path=%build_path% -classpath "%build_path%\java;%build_path%\java\cntk.jar" Main || (
  echo Running Java test failed!
  EXIT /B 1
)
