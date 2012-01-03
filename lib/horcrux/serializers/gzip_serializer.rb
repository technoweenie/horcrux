require 'zlib'
require 'stringio'

module Horcrux
  class GzipSerializer
    def initialize(serializer)
      @serializer = serializer
    end

    def dump(value)
      s = StringIO.new
      z = Zlib::GzipWriter.new(s)
      z.write @serializer.dump(value)
      s.string
    ensure
      z.close if z
    end

    def load(value)
      s = StringIO.new(value)
      z = Zlib::GzipReader.new(s)
      @serializer.load(z.read)
    ensure
      z.close if z
    end
  end
end

