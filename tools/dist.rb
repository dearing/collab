

ENV["CGO_ENABLED"] = "0"

systems = ['windows','linux', 'netbsd','freebsd','openbsd','darwin']
archs 	= ['386','amd64','arm']

['a','c','g','l'].each do |os|
	['8','6','5'].each do |arch|
		puts "tooling #{os}#{arch}..."
		`go tool dist install -v cmd/#{os}#{arch}`
	end
end

systems.each do |os|
	archs.each do |arch|
		puts "building runtime for #{os}/#{arch}..."
		`go tool dist install -v pkg/runtime`
		`go install -v -a std`
	end
end