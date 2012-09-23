# script to build and package collab for various systems and architectures

Dir.chdir '..'

systems = ['windows','linux', 'netbsd','freebsd','openbsd','darwin']
archs 	= ['386','amd64','arm']

ENV["CGO_ENABLED"] = "0"

def build(template)
	File.delete template if File.exists? template
	puts `go build -o #{template}`
	
	template_zip = "#{template}.tar.gz"
			
	if File.exists? template
		File.delete template_zip if File.exists? template_zip
		`7z a -r -ttar #{template}.tar #{template} www`
		`7z a -tgzip #{template_zip} #{template}.tar`
		File.delete template if File.exists? template
		File.delete "#{template}.tar" if File.exists? "#{template}.tar"
	end
end

def build_windows(template)
	File.delete template if File.exists? "#{template}.exe"
	puts `go build -o #{template}.exe`

	template_zip = "#{template}.7z"

	if File.exists? "#{template}.exe"
		File.delete template_zip if File.exists? template_zip
		`7z a -r -t7z #{template_zip} #{template}.exe www` if File.exists? "#{template}.exe"
		File.delete "#{template}.exe" if File.exists? "#{template}.exe"
	end
end

systems.each do |os|
	archs.each do |arch|
		template = "collab_#{os}_#{arch}"
		ENV["GOOS"] = os
		ENV["GOARCH"] = arch
		puts "building collab - #{os} - #{arch}".upcase
		os == "windows" ? build_windows(template) : build(template)
	end
end
