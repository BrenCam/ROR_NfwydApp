#
# Filename: urlgrabber.rb
# Last Modified:    7/21/2009
#
#  UrlGrabberClass to extract subscription links contained in HTML documents
#  The initial document references are  found in XML feeds (ATOM/RSS/Other)
#  Process as follows: 
#  1) Find links to any HTML docs in the XML (passed in)
#  2) Filter out excluded sources 
#  3) Open each remaining doc and find any subscribe link(s)
#  (which tells us its a blog/candidate that might be in Newsforwhatyoudo).
#  Look for: "rss.png" or "subscribe.png", Subscribe text etc.
#  4) Return result set of subscribe link(s) to caller
#
                 
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'htmlentities'
require 'uri'
require 'utilities.rb'
require 'subscribefinder.rb'
                
class UrlGrabber
     
    attr_accessor(:exclusion_list, :xmldoc)
  
	def initialize(xmldoc, domain_url)
        # init instance vars
        @exclusion_list = Array.new
        @exclusion_list << domain_url
        @xmldoc = xmldoc
        # list of possible candidates for further analysis
        # these will be reduced based on exclusion criteria
        @candidates = []
        # final result set
        @results = []
	end
    
    def addexclude(url)
        # add url entry to exlusion list
        @exclusion_list << url
    end

    def  extract_urls(xmlstring)
        # append extracted urls to result set
        # need to extract by doc type (html docs only)
        puts("<---------------- Extract URL's ---------------->")
        #puts string
        li = URI.extract(xmlstring, ['http', 'https'])
        if li.empty?
            puts "No links found"
        else
            puts "links found"
        end
        li.each do |item|
            #puts item
			#escaped_uri = URI.escape(uri)
            # Build candidate list -  Check for and ignore duplicates
			@candidates << item unless @candidates.include?(item)
        end
    rescue Exception => e
        print ">>> Catching Exception <<<"
        print e, "\n "
        #end
    end
    
	def  filter_candidates
        # Remove any URLS matching the exclusion list (based on comparisons with the URL root)
        @exclusion_list.each do |en|
            #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ignoring:  " +  en.to_s
            @candidates.delete_if do |item|
                URI.parse(item).host  == en
            end
        end
        # subselect html docs (ignore everything else)
        @candidates = @candidates.select {|item| item =~ /\.html$/ }
        #puts("<------------------------------ Filtered Results ------------------------------------>")
        #puts @candidates
        #return @candidates
    end

    def get_document(uri)
        # Open each doc and parse for links of interest (e.g. subscription links)
        # add any matches to a final result set
        # Use open with timeout library routine to retrieve body texr
        puts("<----------------   Parsing document : " + uri + "   --------------->")
        body, new_location = Net::HTTP.get_with_timeout_redirect(uri, 2)  # second argument is the timeout in seconds
        if !body.nil?
            return body
        else
            log_it :info, "got no content trying to read data\n  could happen occasionally."
        end
        return nil
    end
                                                        
    def graburls(data,domain_url)
        #
        # build return array of URLS found in an xml document from
        # - content/summary fields for ATOM feeds
        # --or--
        # - description field in RSS feed
        # exclude any self references and excluded domains
        # if no docs links found  return nil 
        # otherwise build and return url candidate list (@candidates)
        # which is then filtered
        #
        extract_urls(xmldoc)
        # remove any self references and return array of URL's to caller
        filter_candidates.each do |item|
            #puts("<------------------------------ Process Filtered Result: " + item + "------------------------------------>")
            htmlcontents = get_document(item)
            # Extract subscription link(s) from each doc
            # (There may be multiple links)
            #@results << SuscribeFinder.new.scrape_document(htmlcontents)
            r =  SuscribeFinder.new.scrape_document(htmlcontents)
            # discard any duplicates
            @results << r  unless @results.include?(r)  or r== nil
        end
        # result set is a list of subscription links
        return @results
    end
end
 