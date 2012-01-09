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
  end
end


