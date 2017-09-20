@echo off
setlocal

:parseargs
if [%1]==[] (
	SET "GIT_REPO="
) ELSE (
	set "GIT_REPO=%1"
)

:displayhint
if [%GITHUB_USERNAME%]==[] (
	echo.
	echo set/export ENVIRONMENT variables GITHUB_USERNAME and GITHUB_PASSWORD to be used as default
	echo.
	pause
	echo.
)


REM offer to set project name first
goto setrepo
REM check if repo set 
:checkrepo
echo ENTER NPM PROJECT NAME - USE "%GIT_REPO%" ? (press ENTER to confirm)
set /p input_ok=^>

if [%input_ok%]==[] (
	echo.
	echo OK.
	echo.
	goto checkuser
) else (
	set GIT_REPO=%input_ok%
	set "input_ok="
	goto checkrepo
) 

:checkuser
if [%GIT_USER%]==[] (
	goto setuser
)
:checkpassword
if [%GIT_PASS%]==[] (
	goto setpassword
)
goto mainprocess
REM ---------------------
:setrepo
echo.
if NOT DEFINED GIT_REPO ( 
	echo ENTER NPM PROJECT NAME  
) else (
	goto checkrepo
)
set /p input_git_repo=^> 

if NOT [%input_git_repo%]==[] (
	set "GIT_REPO=%input_git_repo%"
	set "input_git_repo="
	goto checkrepo
) 
goto setrepo
REM ---------------------
:setuser
echo.
echo env:GITHUB_USERNAME  (default: %GITHUB_USERNAME%)
set /p input_git_user=user: 
if [%input_git_user%]==[] (
		set "GIT_USER=%GITHUB_USERNAME%"
	) else (
		set "GIT_USER=%input_git_user%"
	)
goto checkuser
REM ------------------
:setpassword
echo.
echo env:GITHUB_PASSWORD  (default: %GITHUB_PASSWORD%)
set /p input_git_password=pass: 
if [%input_git_password%]==[] (
		set "GIT_PASS=%GITHUB_PASSWORD%"
	) else (
		set "GIT_PASS=%input_git_password%"
	)
goto checkuser

REM MAIN
REM ===================
REM echo {"projectname":"ea-lib"} | mustache - package.json
REM -------------------
:mainprocess
echo.
echo OK.
echo.
goto render 

:render
echo {"projectname":"%GIT_REPO%"} | mustache - scripts/package.json.mustache > package.json
echo {"projectname":"%GIT_REPO%"} | mustache - scripts/README.md.mustache > README.md
type package.json
type README.md
pause 
goto createrepo


REM Remember replace USER with your username and REPO with your repository/application name!
:createrepo
echo on
REM curl -u '%GIT_USER%:%GIT_PASS%' https://api.github.com/user/repos -d '{"name":"%GIT_REPO%"}'
@echo off
curl -u '%GIT_USER%:%GIT_PASS%' https://api.github.com/user/repos -d '{"name":"%GIT_REPO%"}' > backup/repository.json
if [%ERRORLEVEL%]==[0] (
	git remote add origin git@github.com:%GIT_USER%/%GIT_REPO%.git
	echo echo CREATE REMOTE ORIGIN GIT REPOSITORY / git add remote orgin 
	echo echo -----------------------------------------------------------
	echo.
	echo curl -u '%GIT_USER%:%GIT_PASS%' https://api.github.com/user/repos -d '{"name":"%GIT_REPO%"}' ^> backup/repository.json
	echo.
	echo echo repository created: https://github.com/%GIT_USER%/%GIT_REPO%.git
	echo. 
	echo git remote add origin git@github.com:%GIT_USER%/%GIT_REPO%.git
	echo git add -A
	echo git commit -m "first commit"
	echo git push origin master
	echo.
	echo.
	pause
) else (
 echo ERROR: could not create repository
)
git remote add origin git@github.com:%GIT_USER%/%GIT_REPO%.git

goto end

:err
echo USAGE: gitaddremote [RepositoryName]

:end
endlocal