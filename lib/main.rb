require 'nokogiri'

# Define a module
module NfwydNodeSubscribeLinkDetector

  def link_qualifies(element)
		# verify that element is a valid subscription link
		# return either nil or extract href component
		#puts "<------ test ----->" + element.title

		# filter out the garbage - check extensions
		if element['href'] =~ /\.jpg\z|\.png\z|\.jpeg\z/i
			return nil
		end
		# ??Prioritize these feeds??
		if element.text =~ /subscribe|RSS|Atom|Feed/i
			# check valid start chars
			return element['href'] + "; " + element.text if element['href'] =~ /^http/
		end
		# if all else fails - check the title as well
		if element['title'] =~ /RSS/i
			return element['href'] + "; " + element['title'] if  element['href'] =~ /^http/
		end
		# no matches - fall thru
		return nil
    rescue Exception => e # parsing raises an error - ??ignore these??
		#puts  "Parsing Exception"
      puts e
      #log_it :info, "In scrape.rb, exception was : #{e}"
      return nil
	end

  def scrape_document (htmlcontents)
    # use NokoGiri lib to scrape html document
    # add matching results to results array

		result = []
    doc = Nokogiri::HTML(htmlcontents)
    # Locate all the anchor elements on the page and verify
		doc.css('a').each do |item|		
      r = link_qualifies?(item)
      # discard any duplicates
      result << r  unless result.include?(r)  or r== nil
    end
    # ??Return most relevant subscribe link??
    return result[0] unless result.empty?
    # no link found
    return nil
	end

	# To Do:
	# More testing - test for use cases where 'Subscribe' not found - try RSS, Atom, Feed strings
	# If multiple links - remove any duplicates, reject links with 'comments', 'link'in text
	# Reject comments feeds,
	# add some more test blog data
end

class Nokogiri::XML::Node
  include NfwydNodeSubscribeLinkDetector
end
