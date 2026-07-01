@echo off
REM Sync BestFishBuddy to E:\projects\
REM Run this as Administrator from Windows to mount E: first.
REM Or just copy files using robocopy.

echo Syncing BestFishBuddy to E:\projects\...
robocopy "\\wsl.localhost\Ubuntu\home\louis\BestFishBuddy" "E:\projects\BestFishBuddy" /MIR /XD .git build .dart_tool /NP /NJH /NJS
echo Done!
pause
