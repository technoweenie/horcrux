module Horcrux
  VERSION = "0.0.1"

  module Methods
    def self.included(klass)
      klass.send :attr_reader, :client
    end

    def initialize(client)
      @client = client
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
  end

  class Memory
    include Methods

    def key?(key)
      client.key? key
    end

    def get(key)
      client[key]
    end

    def set(key, value)
      client[key] = value
    end

    def delete(key)
      !client.delete(key).nil?
    end
  end
end

