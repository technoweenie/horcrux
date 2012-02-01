require 'msgpack'

module Horcrux
  module MessagePackSerializer
    extend self

    def dump(value)
      value.to_msgpack
    end

    def load(str)
      str.force_encoding('BINARY') if str.respond_to?(:force_encoding)
      MessagePack.unpack(str)
    end
  end
end

if Time.now.respond_to?(:to_msgpack)
  raise LoadError, "Time#to_msgpack should not exist"
else
  class Time
    def to_msgpack(*args)
      to_i.to_msgpack(*args)
    end
  end
end

