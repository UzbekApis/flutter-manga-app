@echo off
echo ==========================================
echo    GitHub Auto-Uploader for Manga App
echo ==========================================
echo.

:: Check status
git status
echo.

:: Ask for commit message
set /p commitMsg="Enter commit message (Press Enter for 'Auto update'): "
if "%commitMsg%"=="" set commitMsg="Auto update %date% %time%"

:: Add all files
echo.
echo [1/3] Adding files...
git add .

:: Commit
echo.
echo [2/3] Committing...
git commit -m "%commitMsg%"

:: Push
echo.
echo [3/3] Pushing to GitHub...
git push origin main

echo.
echo ==========================================
echo    Done! Code uploaded successfully.
echo ==========================================
pause
