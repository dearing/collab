# script to setup cross compile tool chains for go for calling machine.
# only needed on fresh (or freshly updated) goroot source trees

ENV["CGO_ENABLED"] = "0"

Dir.chdir "#{ENV["GOROOT"]}/src" if Dir.exists? "#{ENV["GOROOT"]}/src"

systems = ['windows','linux', 'netbsd','freebsd','openbsd','darwin']
archs 	= ['386','amd64','arm']

systems.each do |os|
	archs.each do |arch|
		ENV['GOOS'] 	= os
		ENV['GOARCH'] 	= arch
		ENV['OS'] == 'Windows_NT' ? `make.bat --no-clean` : `./make.bash --no-clean`
	end
end
