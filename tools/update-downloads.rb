# use the github api to upload packages quickly
# gem install github_api

require 'github_api'

Dir.chdir('..')

project	= "collab"

print "enter github username: "
username = gets.chomp!

print "\nenter github password: "
password = gets.chomp!


github = Github.new basic_auth: "#{username}:#{password}"

list = github.repos.downloads.list username, project

# delete all the present downloads
list.each do |item|
	github.repos.downloads.delete username, project, item.id
end

# create the download 'slot'(?) and then push the data up
Dir["#{project}_*.*z"].each do |file|
	puts "uploading #{file}..."
	resource = github.repos.downloads.create username, project,
		"name" => file,
		"size" => File.size(file),
		"description" => "latest release",
		"content_type" => "application/octet-stream"
    github.repos.downloads.upload resource, file
end
