require File.expand_path('../helper', __FILE__)

module Horcrux
  class MultipleTest < MemoryTest
    def setup
      @main = Memory.new({})
      @cache1 = Memory.new({})
      @cache2 = Memory.new({})
      @adapter = Multiple.new @main, @cache1, @cache2
    end

    def test_reads_cache_before_main
      @main.set 'a', '3'
      @cache1.set 'a', '1'
      @cache2.set 'a', '2'

      assert_equal '1', @adapter.get('a')

      @cache1.delete 'a'

      assert_equal '2', @adapter.get('a')

      @cache2.delete 'a'

      assert_equal '3', @adapter.get('a')
    end

    def test_sets_to_all_caches
      @adapter.set 'a', '5'

      assert_equal '5', @main.get('a')
      assert_equal '5', @cache1.get('a')
      assert_equal '5', @cache2.get('a')
    end

    def test_sets_values_to_all_caches
      @adapter.set_all 'a' => '5'

      assert_equal '5', @main.get('a')
      assert_equal '5', @cache1.get('a')
      assert_equal '5', @cache2.get('a')
    end

    def test_deletes_from_all_caches
      @main.set 'a', '1'
      @cache1.set 'a', '1'
      @cache2.set 'a', '1'

      @adapter.delete 'a'

      assert !@main.key?('a')
      assert !@cache1.key?('a')
      assert !@cache1.key?('a')
      assert !@adapter.key?('a')
    end

    def test_deletes_keys_from_all_caches
      @main.set 'a', '1'
      @cache1.set 'a', '1'
      @cache2.set 'a', '1'

      @adapter.delete_all 'a'

      assert !@main.key?('a')
      assert !@cache1.key?('a')
      assert !@cache1.key?('a')
      assert !@adapter.key?('a')
    end
  end
end

