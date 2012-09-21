:: windows batch file to tool up a go installation for cross compilation
:: only need to run this whenever you update your main go source tree 
:: so maybe once a year? dunno.
:: it is here to support the build script
@ECHO off
CD %GOROOT%
SET CGO_ENABLED=0

:: tools
FOR %%O in (a c g l) do (
	FOR %%A in (8 6 5) do (
		TITLE tooling %%O/%%A
		go tool dist install -v cmd/%%A%%O
		)
)

:: runtimes
FOR %%O in (darwin linux windows freebsd netbsd openbsd) do (
	SET GOOS=%%O
	FOR %%A in (386 amd64 arm) do (
		SET GOARCH=%%A
		TITLE building %%O/%%A
		go tool dist install -v pkg/runtime
		go install -v -a std
		)
)
