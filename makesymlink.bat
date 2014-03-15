ECHO THis will make a symbolic link from \gamemodes to ..\..\gamemodes
PAUSE
CD gamemodes
mklink /D /J "..\..\..\gamemodes\metrostroi" "metrostroi"
CD ..
ECHO Done
PAUSE