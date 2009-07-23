# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'scrapetest_basic'
require '../lib/subscribefinder'


class Scrapetest_basic < Test::Unit::TestCase

    def test_pass_single_RSS
        # test a specific file for expected results
        # all should pass
        #src = '../testfeeds/valid/popseoul.html'
        #slink = 'http://www.mybloglog.com/buzz/members/popseoul/me/rss.xml ; Subscribe to RSS feed ; '
        #src = '../testfeeds/valid/hueniverse.html'
        #slink = 'http://www.hueniverse.com/hueniverse/atom.xml ; Subscribe today! ; '
#        src = '../testfeeds/valid/jaigouk.blogspot.com.html'
#        slink = 'http://jaigouk.blogspot.com/feeds/posts/default ; RSSSyndicate ; '
#        src = '../testfeeds/valid/semanticallydriven.com.html'
#        slink = 'http://feeds2.feedburner.com/semanticallydriven ; Subscribe in a reader ; '
        src = '../testfeeds/valid/nytimes.friedman.html'
        slink = 'http://www.nytimes.com/rss'

        testdoc = File.new(src)
        data = testdoc.read
        result =SuscribeFinder.new.scrape_document(data)
        puts result
        assert_equal slink, result, ' Expected Match Not Found'
    end

end
