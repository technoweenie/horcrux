require File.expand_path('../helper', __FILE__)

module Horcrux
  class SerializerTest < Test::Unit::TestCase
    def test_null_serializer
      assert_equal 1, NullSerializer.dump(1)
      assert_equal 1, NullSerializer.load(1)
    end

    def test_string_serializer
      assert_equal '1', StringSerializer.dump(1)
      assert_equal '1', StringSerializer.load('1')
    end

    def test_gzip_serializer
      data = '0' * 500
      gzip = GzipSerializer.new(NullSerializer)
      zipped = gzip.dump(data)
      assert zipped.size < data.size
      assert_equal data, gzip.load(zipped)
    end
  end
end

