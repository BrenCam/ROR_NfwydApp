#require File.dirname(__FILE__) + '../lib/my_xml_node'
require '../lib/subscribefinder'
require 'test/unit'

class ScrapeTest < Test::Unit::TestCase
  # fixtures  :tbd??
  # attr_accessor :tbd??
  #Dir.chdir("../../test")

  def test_setup
    # init/setup the test
    Dir.chdir("../../test")
  end

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
      assert_not_equal nil, result, 'No Match Found in file: ' + fname
    end
    Dir.chdir(cwd)
  end

  def test_pass_single_RSS
    # test a specific file for expected results
    # all should pass
  	src = '../testfeeds/valid/popseoul.html'
    slink = 'http://www.mybloglog.com/buzz/members/popseoul/me/rss.xml'
    testdoc = File.new(src)
    data = testdoc.read
    result =SuscribeFinder.new.scrape_document(data)
    assert_equal slink, result, 'Match Found'
  end

  def test_pass_single_ATOM
    # test a specific file for expected results
    # all should pass
  	src = '../testfeeds/valid/rubyinside.html'
    slink = ''
    testdoc = File.new(src)
    data = testdoc.read
    result =SuscribeFinder.new.scrape_document(data)
    assert_equal slink, result, 'Match Found'
  end

end

