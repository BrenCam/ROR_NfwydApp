
require 'test/unit'
require '../lib/urlgrabber'
require 'Nokogiri'

class GrabUrl < Test::Unit::TestCase

  def test_xmlrss

      # Populate ignore list
      domain_url = "semanticallydriven.com"
      # specify document to open - use content here - don't need entire document

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
      data =  doc.css("summary").first.content

#      src =  '../xmlfeeds/RSSFeeds/RubyInside.xml'
#      testdoc = File.new(src)
#      data = testdoc.read
#


      tgbr = UrlGrabber.new(data, domain_url)
      tgbr.addexclude("feedburner.com")
      tgbr.addexclude("feeds.feedburner.com")
      tgbr.addexclude("feeds.conversationsnetwork.org")
      tgbr.addexclude("creativecommons.org")
      tgbr.addexclude("tagaholic.me")
      # should have a list of valid subscription links here
      rlist = tgbr.graburls(data,domain_url)
     	if !rlist.empty?
    	rlist.each do |item|
        puts item + rlist.length.to_s
      end
      #result = nil
      assert_not_equal nil, rlist.length, 'Expected some links - got none'
    end
  end

end
	