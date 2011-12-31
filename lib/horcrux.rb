module Horcrux
  VERSION = "0.0.1"

  module Methods
    def self.included(klass)
      klass.send :attr_reader, :client
    end

    def initialize(client)
      @client = client
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

    def encode(value)
      value.to_s
    end

    def decode(value)
      value
    end
  end

  class Memory
    include Methods

    def get(key)
      client[key]
    end

    def set(key, value)
      client[key] = value
    end

    def delete(key)
      client.delete(key)
    end
  end
end

