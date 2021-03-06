require 'abstract_unit'
require 'active_support/ordered_hash'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/string/output_safety'

class ToQueryTest < ActiveSupport::TestCase
  def test_simple_conversion
    assert_query_equal 'a=10', :a => 10
  end

  def test_cgi_escaping
    assert_query_equal 'a%3Ab=c+d', 'a:b' => 'c d'
  end

  def test_html_safe_parameter_key
    assert_query_equal 'a%3Ab=c+d', 'a:b'.html_safe => 'c d'
  end

  def test_html_safe_parameter_value
    assert_query_equal 'a=%5B10%5D', 'a' => '[10]'.html_safe
  end

  def test_nil_parameter_value
    empty = Object.new
    def empty.to_param; nil end
    assert_query_equal 'a=', 'a' => empty
  end

  def test_nested_conversion
    assert_query_equal 'person%5Blogin%5D=seckar&person%5Bname%5D=Nicholas',
      :person => Hash[:login, 'seckar', :name, 'Nicholas']
  end

  def test_multiple_nested
    assert_query_equal 'account%5Bperson%5D%5Bid%5D=20&person%5Bid%5D=10',
      Hash[:account, {:person => {:id => 20}}, :person, {:id => 10}]
  end

  def test_array_values
    assert_query_equal 'person%5Bid%5D%5B%5D=10&person%5Bid%5D%5B%5D=20',
      :person => {:id => [10, 20]}
  end

  def test_array_values_are_not_sorted
    assert_query_equal 'person%5Bid%5D%5B%5D=20&person%5Bid%5D%5B%5D=10',
      :person => {:id => [20, 10]}
  end

  def test_nested_empty_hash
    assert_equal '',
      {}.to_query
    assert_query_equal 'a=1&b%5Bc%5D=3&b%5Bd%5D=',
      { a: 1, b: { c: 3, d: {} } }
    assert_query_equal 'b%5Bc%5D=false&b%5Be%5D=&b%5Bf%5D=&p=12',
      { p: 12, b: { c: false, e: nil, f: '' } }
    assert_query_equal 'b%5Bc%5D=3&b%5Bf%5D=&b%5Bk%5D=',
      { b: { c: 3, k: {}, f: '' } }
    assert_query_equal 'a%5B%5D=&b=3',
      {a: [], b: 3}
  end

  private
    def assert_query_equal(expected, actual)
      assert_equal expected.split('&'), actual.to_query.split('&')
    end
end
