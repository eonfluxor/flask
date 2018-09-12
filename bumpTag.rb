#!/usr/bin/env ruby
# re

TYPES=['major','minor','patch']

def podSpecFile
	results = Dir.entries(Dir.pwd).select{|file| file.include?'.podspec'}
	raise "cannot find podspec" if results.empty?
	raise "multiple podspecs not supported" if results.count > 1
	results.first
end

def content_of_file file

	file_content = File.read(file)
	if !file_content.valid_encoding?
		file_content = file_content.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
	end
	file_content

end

def increase_version! pod_spec, type=:patch


	type=type.downcase.to_sym

	new_spec = ""
	new_version = "0.0.0"
	pod_spec.each_line do |line|
		# puts "line #{line}"
		clean_line = line.gsub(' ', '')
		
		unless clean_line.start_with?'s.version'
			new_spec = "#{new_spec}#{line}"
		else
			entry = line.split("=")
			raise "s.version format error" unless entry.count == 2
			current_version  = entry.last
			current_version.gsub!("'","")
			current_version.gsub!('"',"")
			parts =  current_version.split(".")
			
			puts "parts #{parts} #{parts.count}"

			parts = parts.map{|a|a.to_i}

			puts "parts #{parts} #{parts.count}"

			raise "s.version value format error" unless parts.count == 3

			major = parts[0].to_i
			minor = parts[1].to_i
			patch = parts[2].to_i

			current_version = "#{major}.#{minor}.#{patch}"

			case type
			when :major
				major= major.to_i + 1
			when :minor
				minor= minor.to_i + 1
			when :patch
				patch= patch.to_i + 1
			end

			new_version = "#{major}.#{minor}.#{patch}"
			puts "#{current_version} -> #{new_version}"
			new_line = "#{entry.first}= '#{new_version}'"
		

			new_spec = "#{new_spec}#{new_line}\n"
		end
	end
	# puts new_spec
	return new_spec, new_version
end

type =ARGV[0] || "patch"

if TYPES.include?type
	puts "Will increase `#{type.upcase}`"
else
	raise "Unsupported type. Please use #{TYPES}"
end

		

spec_file = podSpecFile
spec =  content_of_file spec_file

new_spec, new_version = increase_version! spec,type

File.open(spec_file, "w") {|file| file.puts new_spec }

command = "git commit -am 'bumpTag v#{new_version}'"
puts "executing `#{command}"
system command

command = "git tag v#{new_version}"
puts "executing `#{command}"
system command

puts "increased  `#{spec_file}` to version `#{new_version}`"
puts "created git tag `v#{new_version}`"
