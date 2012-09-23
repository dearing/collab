# drop this in your path (like goroot's bin) and use it to cross compile
# example: go-crosscompile "build -o myproject_arm.exe" windows arm

systems = ['windows','linux', 'netbsd','freebsd','openbsd','darwin']
archs 	= ['386','amd64','arm']

if ARGV.length < 3
	puts "requires [CMD] [OS] [ARCH]"
	puts "where [CMD] is within GOBIN dir"
	puts "where [OS] is of #{systems}"
	puts "where [ARCH] is of #{archs}"
	puts "for example: go-crosscompile build linux arm"
	exit
end

cmd = ARGV[0]

if systems.include? ARGV[1]
	os = ARGV[1]
else
	puts "#{ARGV[1]} not of systems #{systems}"
	exit
end

if archs.include? ARGV[2]
	arch = ARGV[2]
else
	puts "#{ARGV[2]} not of architectures #{archs}"
	exit
end

ENV["CGO_ENABLED"] = "0"
ENV["GOOS"] = os
ENV["GOARCH"] = arch

`go #{cmd}`