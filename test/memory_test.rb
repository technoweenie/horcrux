require 'test/unit'
require File.expand_path('../../lib/horcrux', __FILE__)

module Horcrux
  class MemoryTest < Test::Unit::TestCase
    def setup
      @adapter = Memory.new({})
    end

    def test_reads_set_values
      assert_nil @adapter.get('a')
      assert_equal 1, @adapter.set('a', 1)
      assert_equal 1, @adapter.get('a')
    end

    def test_deletes_values
      assert_equal 1, @adapter.set('a', 1)
      assert_equal 1, @adapter.get('a')
      assert_equal 1, @adapter.delete('a')
      assert_nil @adapter.delete('a')
    end

    def test_fetch_sets_fallback
      assert_nil @adapter.get 'a'
      assert_equal 1, @adapter.fetch('a') { 1 }
      assert_equal 1, @adapter.get('a')
      assert_equal 1, @adapter.fetch('a') { 2 }
    end

    def test_checks_for_existence_of_key
      assert !@adapter.key?('a')
      assert_equal 1, @adapter.set('a', 1)
      assert @adapter.key?('a')
    end

    def test_multi_get
      @adapter.set 'a', 1
      @adapter.set 'c', 3
      assert_equal [1, nil, 3], @adapter.get_all('a', 'b', 'c')
    end

    def test_multi_set
      assert_nil @adapter.get('a')
      assert_nil @adapter.get('b')

      @adapter.set_all 'a' => 1, 'b' => 2

      assert_equal 1, @adapter.get('a')
      assert_equal 2, @adapter.get('b')
    end

    def test_multi_delete
      @adapter.set_all 'a' => 1, 'b' => 2

      assert_equal 1, @adapter.get('a')
      assert_equal 2, @adapter.get('b')

      @adapter.delete_all('a', 'b', 'c')

      assert_nil @adapter.get('a')
      assert_nil @adapter.get('b')
    end
  end
end
