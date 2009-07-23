# To change this template, choose Tools | Templates
# and open the template in the editor.

# image processing and handling related methods.


class Image

  ############## Class Methods #################
  class << self

  # Returns image location if an image should be displayed in news feeds, false otherwise. Returns new_location
  # if there was a 301, nil otherwise. Need to screen
  # smaller feedburner images like the "email this" icon and advertisements by looking at
  # the size of the image.  Also looks for a known ad network name.  Can't check if the image
  # is on the same hostname, since people frequently include images on flickr or other
  # location in blogs.
  def image_qualifies(uri)
    # use openuri if image needs to be downloaded, but for now just check if the image
    # has a uri that's not on feedburner as feedburner is the source of the little icons
    escaped_uri = URI.escape(uri)
    if URI.parse(escaped_uri).host =~ /feeds.feedburner.com|
                        feedproxy.feedburner.com|
                        feedproxy.google.comgoogleadservices|pheedo.com/ then
    end
		return nil, nil
	end  # image doesn't qualify
     # if image is not a jpg or png, its probably not something we want (GIF tend to be logos...)
    unless escaped_uri =~ /\.jpg\z|\.png\z|\.jpeg\z/i then return nil, nil end
    # download image and check if size is big enough.
    size, new_location = image_size_sufficient(escaped_uri)  # returns size of image in bytes or false (only call this once!)
    return size, new_location
  rescue Exception => e # parsing raises an error
    log_it :info, "In image.rb, exception was : #{e}"
    return nil, nil
  end


  # download an image embedded in a blog and get its size, return the size to caller
  # does not retain the image.  uri argument is the value of the src= attribute in the <img tag
  # Returns the image size in bytes if image is big enough, or nil if image too smnll or if
  # response was not "200".  If getting the image involved a perm redirect, returns the
  # new location as the second return value, which should be stored instead of the uri.
  def image_size_sufficient(uri)
   # see lib/shared/shared_utilities for this customzation of Net::HTTP
   body, new_location = Net::HTTP.get_with_timeout_redirect(uri, 2)  # second argument is the timeout in seconds
   if !body.nil?
     # TODO: replace Net::HTTP with http://github.com/taf2/curb/tree/master if speed is required.
     if body.size >= Nfwyd::Constants::MIN_IMAGE_SIZE  # in bytes, so 10KB minimum
       return body.size, new_location
     end
   else
     log_it :info, "got no content trying to download image=#{uri}\n    should happend occasionally.  Throwing away image"
   end
   return nil, nil
  end

  end # end class methods

end
