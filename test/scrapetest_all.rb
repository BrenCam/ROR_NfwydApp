# To change this template, choose Tools | Templates
# and open the template in the editor.

#$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
#require 'scrapetest_one'
require '../lib/subscribefinder'

class ScrapeTest_one < Test::Unit::TestCase
  # fixtures  :tbd??
  # attr_accessor :tbd??
  #Dir.chdir("../../test")

  def test_fail_batch
    # Retrieve a set of test files is directory and iterate thru
    # all should fail
    cwd = Dir.getwd               # Save current dir - need to reset
    Dir.chdir("../testfeeds/invalid/")
    Dir['*.html'].each do |fname|
      testdoc = File.new(fname)
      data = testdoc.read
      result =SuscribeFinder.new.scrape_document(data)
      #result = nil
      assert_equal nil, result, 'Unexpected Match Found in file: ' + fname
    end
    Dir.chdir(cwd)                # Reset working directory
  end  

  def test_pass_batch
    # Retrieve a set of test files is directory and iterate thru
    # all should pass
    cwd = Dir.getwd               # Save current dir - need to reset
    Dir.chdir("../testfeeds/valid/")
    Dir['*.html'].each do |fname|
      #src = '../testfeeds/popseoul.html'
      #puts fname
      testdoc = File.new(fname)
      data = testdoc.read
      result =SuscribeFinder.new.scrape_document(data)
      puts result
      assert_not_equal nil, result, 'No Match Found in file: ' + fname
    end
    Dir.chdir(cwd)
  end
  
  def test_pass_single_rss
    # test a specific file for expected results
    # all should pass
  	src = '../testfeeds/valid/popseoul.html'
    #src = '../therealadam.com.html'
    slink = 'http://www.mybloglog.com/buzz/members/popseoul/me/rss.xml ; Subscribe to RSS feed ; '
    testdoc = File.new(src)
    data = testdoc.read
    result =SuscribeFinder.new.scrape_document(data)
    assert_equal slink, result, 'Match Found'
  end

  def test_pass_single_atom
    # test a specific file for expected results
    # all should pass
  	src = '../testfeeds/valid//therealadam.com.html'
    slink = 'http://therealadam.com/feed/ ; Subscribe to feed ; '
    testdoc = File.new(src)
    data = testdoc.read
    result =SuscribeFinder.new.scrape_document(data)
    assert_equal slink, result, 'Match Found'
  end

end

