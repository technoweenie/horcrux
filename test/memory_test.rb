require 'test/unit'
require File.expand_path('../../lib/horcrux', __FILE__)

module Horcrux
  class MemoryTest < Test::Unit::TestCase
    def setup
      @adapter = Memory.new({})
    end

    def test_reads_set_values
      assert_nil @adapter.get('a')
      assert_equal '1', @adapter.set('a', '1')
      assert_equal '1', @adapter.get('a')
    end

    def test_deletes_values
      assert_equal '2', @adapter.set('b', '2')
      assert_equal '2', @adapter.get('b')
      assert_equal '2', @adapter.delete('b')
      assert_nil @adapter.delete('b')
    end

    def test_fetch_sets_fallback
      assert_nil @adapter.get 'c'
      assert_equal '3', @adapter.fetch('c') { '3' }
      assert_equal '3', @adapter.get('c')
      assert_equal '3', @adapter.fetch('c') { '4' }
    end
  end
end
