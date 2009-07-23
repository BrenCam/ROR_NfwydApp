# To change this template, choose Tools | Templates
# and open the template in the editor.

#$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
#require 'scrapetest_one'
require '../lib/subscribefinder'

class ScrapeTest_all < Test::Unit::TestCase
    # fixtures  :tbd??
    # attr_accessor :tbd??
    # Dir.chdir("../../test")

    # Note: In the following test the path is reset
    # so we define a class var to save working directory
    # and restore this after each test (via teardown)
    # (setup and teardown are called implictly for each test)
    # gets set/reset after each test

    @@cwd = Dir.getwd
    #puts "Current Working Directory: " + @@cwd

    def setup
        # add any test init code here
        # applies to all member functions/tests
        #@@cwd = Dir.getwd               # Save current dir - need to reset
        #Dir.chdir("../testfeeds/invalid/")
    end

    def teardown
        # add any post test completion code here
        # applies to all member functions/tests
        # After each test, reset working directory to initial/base value
        Dir.chdir(@@cwd)
    end

    def test_fail_batch
        # Retrieve a set of test files is directory and iterate thru
        # all should fail
        Dir.chdir("../testfeeds/invalid/")
        Dir['*.html'].each do |fname|
            testdoc = File.new(fname)
            data = testdoc.read
            result =SuscribeFinder.new.scrape_document(data)
            #result = nil
            assert_equal nil, result, 'Unexpected Match Found in file: ' + fname
        end
    end

    def test_pass_batch
        # Retrieve a set of test files is directory and iterate thru
        # all should pass
        #cwd = Dir.getwd               # Save current dir - need to reset
        Dir.chdir("../testfeeds/valid/")
        Dir['*.html'].each do |fname|
            #src = '../testfeeds/popseoul.html'
            #puts fname
            testdoc = File.new(fname)
            data = testdoc.read
            result =SuscribeFinder.new.scrape_document(data)
            #puts result
            assert_not_equal nil, result, 'No Match Found in file: ' + fname
        end
    end
  
    def test_pass_single_rss
        # test a specific file for expected results
        # all should pass
        src = '../testfeeds/valid/popseoul.html'
        #src = '../therealadam.com.html'
        slink = 'http://www.mybloglog.com/buzz/members/popseoul/me/rss.xml'
        testdoc = File.new(src)
        data = testdoc.read
        result =SuscribeFinder.new.scrape_document(data)
        assert_equal slink, result, 'Match Found'
    end

    def test_pass_single_atom
        # test a specific file for expected results
        # all should pass
        src = '../testfeeds/valid//therealadam.com.html'
        slink = 'http://therealadam.com/feed/'
        testdoc = File.new(src)
        data = testdoc.read
        result =SuscribeFinder.new.scrape_document(data)
        assert_equal slink, result, 'Match Found'
    end

end

