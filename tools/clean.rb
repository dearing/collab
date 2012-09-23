# simple script to clear out binaries and such things from build.rb

Dir.chdir '..'

Dir["collab_*"].each do |file|
	File.delete file
end
