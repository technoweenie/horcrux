module Horcrux
  class Multiple
    include Methods
    def initialize(*adapters)
      @main = adapters.shift
      @readers = adapters
    end

    def key?(key)
      read_cache :key?, key
    end

    def get(key)
      read_cache :get, key
    end

    def set(key, value)
      write_through :set, key, value
    end

    def set_all(values)
      write_through :set_all, values
    end

    def delete(key)
      write_through :delete, key
    end

    def delete_all(*keys)
      write_through :delete_all, *keys
    end

    def write_through(method, *args)
      result = @main.send(method, *args)
      @readers.each { |r| r.send(method, *args) }
      result
    end

    def read_cache(method, *args)
      value = nil
      @readers.detect { |r| value = r.send(method, *args) }
      value || @main.send(method, *args)
    end
  end
end

