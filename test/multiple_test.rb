require File.expand_path('../memory_test', __FILE__)

module Horcrux
  class MultipleTest < MemoryTest
    def setup
      @main = Memory.new(@main_hash = {})
      @cache1 = Memory.new(@cache1_hash = {})
      @cache2 = Memory.new(@cache2_hash = {})
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

    def test_calls_on_missing_callback
      called = 0

      @adapter.on_missing do |adapter, values|
        called += 1
        
        case adapter
        when @cache1
          assert_equal 2, values.size
          assert_equal '1', values['a']
          assert_equal '3', values['c']
        when @cache2
          assert_equal 1, values.size
          assert_equal '3', values['c']
        else
          fail "Bad adapter: #{adapter.inspect}"
        end

      end

      @cache2.set 'a', '1'
      @cache1.set 'b', '2'
      @main.set 'c', '3'

      assert_equal %w(1 2 3), @adapter.get_all('a', 'b', 'c')
      assert_equal 2, called
    end

    def test_skips_missing_callback_on_perfect_get_all
      called = 0

      @adapter.on_missing do |adapter, values|
        called += 1
      end

      @cache1.set_all 'a' => '1', 'b' => '2', 'c' => '3'

      assert_equal %w(1 2 3), @adapter.get_all('a', 'b', 'c')
      assert_equal 0, called
    end

    def test_ignores_errors
      called = false

      @adapter.on_error do |err, obj|
        called = true
        assert_kind_of RuntimeError, err
        assert_equal @cache1, obj[:adapter]
        assert_equal :get, obj[:method]
        assert_equal %w(a), obj[:args]
      end

      hash = @cache1_hash
      def hash.[](*args) raise end

      @cache1.set 'a', '1'
      @cache2.set 'a', '2'

      assert_equal '2', @adapter.get('a')
      assert called
    end
  end
end

