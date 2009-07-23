# Misc code test utils here
require 'Nokogiri'

# parse the nodeset - look for comments etc
src =  '../xmlfeeds/RSSFeeds/RubyInside.xml'
src =  '../xmlfeeds/AtomFeeds/atomcast.xml'

testdoc = File.new(src)
xmldata = testdoc.read
#doc = Nokogiri::HTML(xmldata)
doc = Nokogiri::XML(xmldata)

p ">>> Start <<<<"

# bail out early if not a HTM/??XML?? doc
s = "//link"
s = "//summary"

#doc.xpath(s).each do |item|
#doc.css("summary[@type='html']"[0]).each do |item|
puts doc.css("summary").first.content
doc.css("summary").each do |item|
    puts item.content
end
#    item.css('inner search').each do |jj|
#            puts jj
#    end
#    if doc.css('summary') =~ /HTML/i
#        puts 'HTML Doc found'
#    else
#        puts 'Other Doc found'
#    end
#end

p ">>> End <<<<"


#fnames = Dir.entries("../testfeeds/*.html")
#Dir.chdir("../testfeeds")
#puts Dir.getwd
#
#cwd = Dir.getwd
#Dir.chdir("../testfeeds/invalid")
#Dir['*.html'].each do |fname|
#    puts fname
#end
#puts Dir.getwd
#Dir.chdir(cwd)
#puts Dir.getwd

