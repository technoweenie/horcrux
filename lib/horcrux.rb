module Horcrux
  VERSION = "0.0.1"

  module Methods
    def self.included(klass)
      klass.send :attr_reader, :client, :serializer
    end

    def initialize(client, serializer = nil)
      @client = client
      @serializer = serializer || StringSerializer.new
    end

    def get_all(*keys)
      keys.map { |k| get(k) }
    end

    def set_all(values)
      values.each do |key, value|
        set key, value
      end
    end

    def delete_all(*keys)
      keys.map { |k| delete(k) }
    end

    def key?(key)
      !get(key).nil?
    end

    def fetch(key)
      get(key) || set(key, yield)
    end

    def key_for(key)
      key.to_s
    end
  end

  class StringSerializer
    def pack(value)
      value.to_s
    end

    def unpack(str)
      str
    end
  end

  class Memory
    include Methods

    def key?(key)
      client.key? key_for(key)
    end

    def get(key)
      serializer.unpack client[key_for(key)]
    end

    def set(key, value)
      client[key_for(key)] = serializer.pack(value)
    end

    def delete(key)
      !client.delete(key_for(key)).nil?
    end
  end
end

