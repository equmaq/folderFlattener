rm -r "C:\Program Files\folderFlattener"

regedit.exe /s "%~dp0undoregconf.reg"

taskkill /f /im explorer.exe
start explorer.exe