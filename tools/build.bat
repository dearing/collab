:: BATCH script to compile various binaries and package them with the web documents
:: Why not use a scripting language? I don't fucking know why I did this to myself.
@ECHO off
SET CGO_ENABLED=0
FOR %%O in (darwin linux windows freebsd netbsd openbsd) do (
	SET GOOS=%%O
	FOR %%A in (386 amd64 arm) do (
		SET GOARCH=%%A
		TITLE building %%O/%%A
		IF %%O == windows (
			go build -o collab_%%O_%%A.exe
			IF EXIST collab_%%O_%%A.exe (
				IF EXIST collab_%%O_%%A.7z (DEL collab_%%O_%%A.7z)
				7z a -r -t7z collab_%%O_%%A.7z collab_%%O_%%A.exe www
				)
			) ELSE (
			go build -o collab_%%O_%%A
			IF EXIST collab_%%O_%%A (
				IF EXIST collab_%%O_%%A.tar.gz (DEL collab_%%O_%%A.tar.gz)
				7z a -r -ttar collab_%%O_%%A.tar collab_%%O_%%A www
				7z a -tgzip collab_%%O_%%A.tar.gz collab_%%O_%%A.tar
				IF EXIST collab_%%O_%%A.tar.gz (DEL collab_%%O_%%A.tar)
				)
			)
		)
	)
