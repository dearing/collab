# Script to setup cross compile tool chain for go for calling machine.

# All that is built are tools to compile for other OS/ARCH combinations
# from the calling machine.  From here the calling machine can cross
# compile by setting the GOOS and GOACRCH environment variables before
# building as seen in the runtime step.

# CGO not implemented (need C cross compiling toolchain on host)

# Jacob Dearing 2012

ENV["CGO_ENABLED"] = "0"

Dir.chdir "#{ENV["GOROOT"]}/src" if Dir.exists? "#{ENV["GOROOT"]}/src"

systems = ['windows','linux', 'netbsd','freebsd','openbsd','darwin']
archs 	= ['386','amd64','arm']

#['a','c','g','l'].each do |os|
#	['8','6','5'].each do |arch|
#		puts "tooling #{os}#{arch}..."
#		`go tool dist install -v cmd/#{os}#{arch}`
#	end
#end

systems.each do |os|
	archs.each do |arch|
		ENV['GOOS'] = os
		ENV['GOARCH'] = arch
		`./make.bash --no-clean`
#		puts "building runtime for #{os}/#{arch}..."
#		`go tool dist install -v pkg/runtime`
#		`go install -v -a std`
	end
end
