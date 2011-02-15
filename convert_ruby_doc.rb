=begin
  * Convert RubyDoc
=end
require 'fileutils'

def createTOC path, trace
	puts ">>> started TOC creation <<<"
  newlines = Hash.new("")
  aIndex = [0 ,0]
  
  File.open("#{path}\\fr_method_index.html", 'r') do |f|
    lines = f.readlines
    lines.each do |it|
      newlines.merge!($3 =>   [$2 => "\", \"" + $1]){|key, old, new| old + new} if it =~ /<a href=\"([\w|\W]+)">([\w|\W]+\(([\w|\W]+)\))<\/a><br \/>/
    end
  end
  
  newlines = newlines.sort
  
  File.open("#{path}\\tocTab.js", 'w') do |f|
    f.print "var tocTab = new Array();\n"
    f.print "tocTab[0] = new Array (\"0\", \"RubyDoc\", \"first_page.html\");\n"
    newlines.each do |key, val|
      aIndex[0] = aIndex[0] += 1
      aIndex[1] = aIndex[1] += 1
      aIndex[2] = 0
      f.print "tocTab[#{aIndex[0]}] = new Array (\"#{aIndex[1]}\", \"#{key}\", \"classes/#{key.gsub(/::+/, "/")}.html\");\n"
      puts "#{aIndex[0]}: >#{aIndex[1]} - #{key}" if trace
      val.each do |key2, val2|
        aIndex[0] = aIndex[0] += 1
        aIndex[2] = aIndex[2] += 1
        f.print "tocTab[#{aIndex[0]}] = new Array (\"#{aIndex[1]}.#{aIndex[2]}\", \"#{key2}\");\n"
        puts "#{aIndex[0]}: >>#{aIndex[1]}.#{aIndex[2]} - #{key2}" if trace
      end
    end
    f.print "var nCols = #{aIndex.size - 1};"
    f.print 'var variant = "";'
  end
  puts ">>> TOC created <<<"
end

def fixHTML path, trace
	puts ">>> started fixing HTML <<<"
	
  # if file dir not *.src
  
  Dir.chdir(path)
  rbfiles = File.join("**", "*.html")
  Dir.glob(rbfiles).each do |file|
    p ">>> processing file: #{file}" if trace
    newlines = []
    bWrite = false
    File.open(file, 'r') do |f|
    
      lines = f.readlines
      lines.each do |it|
      
        #unless file  =~ /([\w|\W]+).src\/([\w|\W]+)/
        
        ## ADD before "</head>". fix path "../js"
        # <script src="../js/src/prettify.js" type="text/javascript"></script>
        # <link rel="stylesheet" type="text/css" href="../js/src/prettify.css"/>
        ##
        if it =~ /<\/head>/
          it = "<script src=\"#{"../"*(file.count("/"))}js/src/prettify.js\" type=\"text/javascript\"></script>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"#{"../"*(file.count("/"))}js/src/prettify.css\"/>\n</head>"
          bWrite = true
        end
        
        ## CHANGE "<pre>"
        # <pre class="prettyprint rb-java" id="rb_lang" style="border-style: none">
        ##
        if it =~ /<pre>/
          lang = file  =~ /([\w|\W]+).src\/([\w|\W]+)/ ?  "class=\"prettyprint lang-cc\" id=\"Cpp_lang\"" : "class=\"prettyprint rb-java\" id=\"rb_lang\""
          it.gsub!(/<pre>/, "<pre #{lang} style=\"border-style: none\">")
          bWrite = true
        end
        
        ## DEL !!
        # <!DOCTYPE html
        #     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        #     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        ##
        if ((it =~ /<!DOCTYPE html/) or
           (it =~ /iso-8859-1/) or
           (it =~ /     PUBLIC \"-\/\/W3C\/\/DTD XHTML 1.0 Transitional\/\/EN"/) or
           (it =~ /     \"http:\/\/www.w3.org\/TR\/xhtml1\/DTD\/xhtml1-transitional.dtd\">/))
           
          it = ""
          bWrite = true
        end
        
        if it =~ /<body([\w|\W]+)/
          it.gsub!(/<body/, "<body onload=\"prettyPrint()\" ")
          bWrite = true
        end
        
        newlines << it
      end
    end
    
    if bWrite
      File.open(file, 'w') do |f|
        newlines.each { |line| f.print line}
      end
    end
  end
  puts ">>> HTML Fixed <<<"
end

def copyFiles path
	puts ">>> Copy Resources <<<"
	Dir.chdir '..'
	FileUtils.copy_entry 'resources', path
	puts ">>> Resources copied <<<"
end


if ARGV[0].nil?
	puts '-'*40
	puts 'Using: convert_ruby_doc.rb path_to_RubyDoc trace'
	puts 'Where:'
	puts '   - path_to_RubyDoc  - RubyDoc location'
	puts '   - trace            - if trace needed'
  puts '-'*40
else
  path = ARGV[0] 
  trace = ARGV[1] == 'trace' ? true : false
  
  createTOC path, trace
  fixHTML path, trace
  copyFiles path
end









