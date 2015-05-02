require 'getoptlong'
counter=0

def get_image_extension(local_file_path)
  png = Regexp.new("\x89PNG".force_encoding("binary"))
  jpg = Regexp.new("\xff\xd8\xff\xe0\x00\x10JFIF".force_encoding("binary"))
  jpg2 = Regexp.new("\xff\xd8\xff\xe1(.*){2}Exif".force_encoding("binary"))
  bmp = Regexp.new("\x42\x4d".force_encoding("binary"))
  case IO.read(local_file_path, 10)
  when /^GIF8/
    '.gif'
  when /^#{jpg2}/
    '.jpg'
  when /^#{png}/
    '.png'
  when /^#{jpg}/
	'.jpg'
  when /^#{bmp}/
	'.bmp'
	else
		'others'
  end  
end

def rename_file_extension(source, extension)  
  dirname  = File.dirname(source)  
  basename = File.basename(source, ".*")  
  extname  = File.extname(source)  
  if extname == ""  
    if basename[0,1]=="."  
      target = dirname + extension  
    else  
      target = source + extension  
    end  
  else  
    target = dirname + "/" + basename + extension  
  end  
  File.rename(source, target)  
  target  
end  

opts = GetoptLong.new(
	[ "-f", "--file", GetoptLong::REQUIRED_ARGUMENT],
	[ "-F", "--Folder", GetoptLong::REQUIRED_ARGUMENT],
	[ "-h", "--help", GetoptLong::NO_ARGUMENT]
)

opts.each{|o,a|
	case o
	when '-f', "--file"
		filename = a
		fileext = get_image_extension(filename)
		if fileext != 'others'
			if  fileext != filename
				rename_file_extension(filename,fileext)
				puts("[Edit]: #{filename}")
			end
		end
		
	when '-F', '--folder'
		log = File.open("./imagechecker.log","wb")
		folder_path = a
		Dir.glob(folder_path + "/**/*.*").sort.each do |filename|
			fileext = get_image_extension(filename)
				if fileext != 'others'
					if fileext != filename
						rename_file_extension(filename,fileext)
						log.puts("[Edit#{counter+=1}]: #{filename}")
					end
				end
		end
		log.close
		
	when '-h', '--help'
		 puts <<-EOF
		 
-h, --help:
  Show help

-f filename.* , --file filename.*:
  Check single file with extension name change

-F directory , --folder directory:
  Check all file inside folder and sub-folder with extension name change
  
		EOF
	end
}
