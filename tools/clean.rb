Dir.chdir '..'

Dir["collab_*"].each do |file|
	File.delete file
end
