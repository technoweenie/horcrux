module Horcrux
  class Multiple
    include Methods
    def initialize(*adapters)
      @main = adapters.shift
      @readers = adapters
    end

    def key?(key)
      value = nil
      @readers.detect { |r| value = r.key?(key) }
      value || @main.key?(key)
    end

    def get(key)
      value = nil
      @readers.detect { |r| value = r.get(key) }
      value || @main.get(key)
    end

    def set(key, value)
      @main.set(key, value)
    end

    def delete(key)
      result = @main.delete(key)
      @readers.each { |r| r.delete(key) }
      result
    end
  end
end

