require 'rexml/document'
require 'activerecord'  # need it access Rails logger
require 'net/http'
require 'uri'
require 'htmlentities/string'

##################################################################################
########## Global methods - accessible to every class as class methods ###########
########## should automatically be accessible everywhere by virtue of  ###########
########## this file being required into every rails file by environment.rb ###########
##################################################################################

unless defined?(__method__) # already defined in ruby 1.9
  # returns the name of the current method(the caller of this method)
  def __method__
    caller[0][/`([^']*)'/, 1].to_sym
  end
  alias __callee__ __method__
end

# wrap the ActiveRecord::Base logger method to allow it to be referenced outside AR classes and
# shorten the syntax.  The valid values for level are :debug, :info, :warn, :fatal, :error
# This is also necessary because the standard logger's files are predefined at the level of the
# project, while we have 
# multiple processes like event_processor and source_updater sharing the same project, so need to
# have different file names for them.
def log_it(level, msg)
  string_to_log = "#{level}:#{caller[0][/`([^']*)'/, 1]}: #{msg} at #{Time.now.utc}"
  ActiveRecord::Base.logger.send level, string_to_log  # level is the method ...
  # TODO: delete line below if no need for separate app logger found in test mode.
  # $app_logger.send level, string_to_log   # note must use send not add, because add requires the level to be a integer
end


########## include these in your class if needed #############################
# USAGE:
#
#  class GroupController < ActiveController::Base
#     include Nfwyd
#
#     def whatever
#       SharedUtilities.get_OPML_feeds(...)
#     end

module Nfwyd
  module SharedUtilities
    include REXML

    def SharedUtilities.create_updated_at
      Time.now.utc.xmlschema
    end
  
    # given a string, parse out the values for each 'xmlUrl' key in each <outline>
    # element.  return an array of all the xmlUrl strings.
    # use like get_OPML_feeds(File.read('my_feeds.opml').
    # Note that the OPML standard is pretty vague, so the attributes containing
    # the feed URL could be anything - the below works for Google Reader, Bloglines
    # and the CNN opml feed list.
    def SharedUtilities.get_OPML_feeds(string)
      feeds = []
      opml = REXML::Document.new(string)
      opml.elements.each("//outline") do |e|
        if e.attributes["xmlUrl"]
          feeds << e.attributes["xmlUrl"] 
        elsif e.attributes["url"]  
          feeds << e.attributes["url"]
        end   
      end     
      return feeds  
    end  
  
  end
end

class String
  
  # remove any open or partial anchor tags from a String obect that may contain un-escaped html
  def remove_open_anchors
    self.gsub!(/<a[^<>]*?>[^<>]*\z/,'') # remove open anchors - a start element with no end element
    # now that we know there are no open anchors, remove partial start or end anchors like "blah is the <a href"
    # or ""</"" ...
    self.gsub!(/<[^>]*?\z/, '')
  end
  
  
  # used to encode all user-bound content destined for both XML and XHTML formats (feeds and display)
  # Strategy:
  #   1. encode only the five chars required by XML: encode_entities(:basic)  does this
  #   2. because of IE, have to convert &apos; to &#39; because &apos; not technically part of XHTML.
  # See http://www.w3.org/International/questions/qa-escapes  for more.
  def standard_encode
    encode_entities(:basic).gsub(/&apos;/, '&#39;')
  end
  
end

  
class Net::HTTP
  
  
  class RedirectTooDeep < StandardError; 
  end
  
  # HTTP.get with timeout handling and follows redirects.  If redirect is permanent, 
  # also returns the location of the permanent redirect so it may be stored. 
  # Details:
  #   body: a string with the response body - nil if empty.  
  #
  #   location: the final location pointed to by the perm redirect.  Note that temp redirects are followed
  #             but are not returned nor do they affect this return value.  Nil if code != '301'
  #             If there were multiple perm redirects returns the last one.
  #   code : a "200", "301", or "302", or nil
  def self.get_with_timeout_redirect(uri, timeout, limit=5, location=nil)
    raise RedirectTooDeep, 'HTTP redirect too deep' if limit == 0
    response = self.get_with_timeout(uri, timeout)
    case response
      when Net::HTTPSuccess 
        return response.body, location, "200" # return new_location if passed in during last recursion 
      when Net::HTTPRedirection 
        location = response['location'] if response.code == '301' 
        body, location = self.get_with_timeout_redirect(response['location'], timeout, limit - 1, location)
        return body, location, response.code
      else
        return nil, nil,  nil
    end
  end


  # returns response code Net::HTTP object
  # or nil if fails for any reason
  # handles timeouts which plain get does not
  # Argument is full URI of target
  def self.get_with_timeout(uri, timeout)
    #puts '<----------------------------------- processing request - get_with_timeout --------------------------------->'
    url = URI.parse(uri)
    http = Net::HTTP.new(url.host, url.port)
    #puts url.host
    #puts url.port
    #puts url.path
    
    http.read_timeout = timeout
    http.open_timeout = timeout
    return http.get(url.path)   # Net::HTTP response object  http://www.ruby-doc.org/core-1.8.6/classes/Net/HTTPResponse.html
  rescue Timeout::Error
    puts 'Timeout Error'  
    return nil
  rescue Exception
    puts 'Exception'
    log_it :warn, "Net::HTTP.get_with_timeout in utilities.rb received #{$!} with uri=#{uri}\n    this could just be a bad URI in which case ignore this error"
    return nil
  end 
  
   
end  # Net::HTTP


