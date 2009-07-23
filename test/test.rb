# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'nokogiri'

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test'

class Test < Test::Unit::TestCase
  def test_foo
    assert(false, 'Assertion was false.')
    flunk "TODO: Write test"
    # assert_equal("foo", bar)
  end
end

class Mytest < Test::Unit::TestCase
  def bar
    return -1 unless x == 1
      # comment here
    end
  end

