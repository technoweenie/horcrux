module Horcrux
  class Multiple
    include Methods

    attr_reader :rescuable_exceptions
    attr_reader :error_handlers

    # Sets up an Adapter using a collection of other adapters.  The first is
    # assumed to be the main, while the others are write-through caches.  This
    # is good for caching.
    #
    #     mysql = Horcrux::MysqlAdapter.new ... # fake
    #     memcache = Horcrux::MemcacheAdapter.new ... # fake
    #     adapter = Horcrux::Multiple.new mysql, memcache
    #
    # Reads will hit the secondary adapters before the main.  Writes will hit
    # the main adapter first, before being sent to the secondary adapters.
    #
    # *adapters - One or more Horcrux-compliant adapters.
    def initialize(*adapters)
      if adapters.empty?
        raise ArgumentError, "Need at least 1 adapter."
      end

      @main = adapters.shift
      @adapters = adapters
      @error_handlers = []
      @rescuable_exceptions = [StandardError]
    end

    def on_error(&block)
      @error_handlers << block
      nil
    end

    ## HORCRUX METHODS

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

    ## INTERNAL

    # Writes the data to the main adapter first, and then to the other
    # adapters.
    #
    # method - A Symbol identifying the method to call.
    # *args  - One or more arguments to send to the methods.
    #
    # Returns the result of the method call on the main adapter.
    def write_through(method, *args)
      result = @main.send(method, *args)
      @adapters.each do |adapter|
        call_adapter adapter, method, *args
      end
      result
    end

    # Reads the data from the other adapters before the main adapter.
    #
    # method - A Symbol identifying the method to call.
    # *args  - One or more arguments to send to the methods.
    #
    # Returns the result of the first adapter to respond with a value.
    def read_cache(method, *args)
      value = nil
      @adapters.detect do |adapter| 
        value = call_adapter adapter, method, *args
      end
      value || @main.send(method, *args)
    end

    # Calls the given adapter, swallowing up any error.
    #
    # adapter - A Horcrux adapter.
    # method - A Symbol identifying the method to call.
    # *args  - One or more arguments to send to the methods.
    #
    # Returns the value of the method call.
    def call_adapter(adapter, method, *args)
      adapter.send(method, *args)
    rescue Object => err
      raise unless @rescuable_exceptions.any? { |klass| err.is_a?(klass) }

      if @error_handlers.each do |handler|
        handler.call err, :adapter => adapter, :method => method, :args => args
      end.empty?
        $stderr.puts "#{err.class} Exception for #{adapter.inspect}##{method}: #{err}"
      end
    end
  end
end

