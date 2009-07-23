require 'nokogiri'

# Define a module here 
module NfwydNodeSubscribeLinkDetector

    # Version History/Change Log:
    # Version           Date        By      Comments
    # ---------------------------------------------------------
    # V01           7/22/2009       BC      Initial link parser
    #
    #
    #
    # ---------------------------------------------------------
    #
  	# Open Issues/To Do??:
	# More testing - test for use cases where 'Subscribe' not found - try RSS, Atom, Feed strings
	# If multiple links - remove any duplicates, reject links with 'comments', 'link'in text
	# Reject comments feeds,
	# add some more test blog data
    # 
    # ---------------------------------------------------------

    def link_qualifies(element)
        #
		# verify that element is a valid subscription link
		# return either nil or extract href component
        #

		# filter out the garbage - check extensions
		if element['href'] =~ /\.jpg\z|\.png\z|\.jpeg\z/i
			return nil
		end
		# ??Prioritize these feeds??
		if element.text =~ /subscribe|RSS|Atom|Feed/i
			# check valid start chars
			#return element['href'] +  " ; "  + element.text +  " ; "  if element['href'] =~ /^http/
			return element['href'] if element['href'] =~ /^http/
		end
		# if all else fails - check the title as well
		if element['title'] =~ /RSS/i
			return element['href'] if  element['href'] =~ /^http/
		end

        # ?? other possibilities - check for feed icon without any text 'rss.png; subscribe.png; other' ??
        # (?? add unit test case for this ??)
		# no matches - fall thru
		return nil

    rescue Exception => e # parsing raises an error - ??ignore these??
		#puts  "Parsing Exception"
        puts e
        #log_it :info, "In scrape.rb, exception was : #{e}"
        return nil
	end

    def scrape_document (htmlcontents)
        # verify doctype is valid (i.e. HTML or ??XML??)
        # if valid use NokoGiri lib to scrape html document
        # add matching results to results array
        # return nil if subscription link not found

		results = []
        doc = Nokogiri::HTML(htmlcontents)
        # bail out early if not a HTM/??XML?? doc
        # ?? how to test this- DOCTYPE is not avail via XML/css search
        # ??return nil unless doc.css('DOCTYPE') =~ /HTML/

        # Locate all the anchor elements on the page and verify link
		doc.css('a').each do |item|		
            r = link_qualifies(item)
            # discard any duplicates
            results << r  unless results.include?(r)  or r== nil
        end

        # ??Return only first/most relevant subscribe link??
        # ??Should feed links end in '.xml' or '.rss' ??
        return nil if results.empty?
        return results[0] if results.length == 1

        # ?? If > 1 result - Prioritize '/xml/rss links over other /html links??
        # see NY Times Tets with > ! result
        results.each do |res|
            puts '>>>> testing : ' + res
            if res =~ /\/rss\z|\/xml\z/
                return res
            end
        end
        # Otherwise return first match
        return results[0]
	end

end # end module

class SuscribeFinder
    include NfwydNodeSubscribeLinkDetector
end
