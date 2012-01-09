module Horcrux
  class Multiple
    include Methods

    attr_reader :rescuable_exceptions
    attr_reader :error_handlers, :missing_handlers

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
      @missing_handlers = []
      @rescuable_exceptions = [StandardError]
    end

    # Public: Adds the given block to the chain of handlers to call for a
    # raised exception while accessing one of the adapters.
    #
    #     @adapter.on_error do |err, obj|
    #       obj[:adapter]
    #       obj[:method]
    #       obj[:args]
    #     end
    #
    # Returns nothing.
    def on_error(&block)
      @error_handlers << block
      nil
    end

    # Public: Adds the given block to the chain of handlers to call when a 
    # secondary adapter is missing one or more keys.
    #
    #     @adapter.on_missing do |adapter, values|
    #       adapter.set_all(values)
    #     end
    #
    # Returns nothing.
    def on_missing(&block)
      @missing_handlers << block
      nil
    end

    ## HORCRUX METHODS
   
    def get_all(*keys)
      original = keys.dup
      adapter_missing = {}
      values = {}

      @adapters.each do |adapter|
        found, missing = get_from_adapter(adapter, keys)
        values.update(found)

        if !missing.empty?
          adapter_missing[adapter] = missing
        end

        keys = missing
      end

      found, missing = get_from_adapter(@main, keys)
      values.update(found)

      call_missing_handlers(values, adapter_missing)

      original.map { |key| values[key] }
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

    # Gets all keys from the adapter.
    #
    # adapter - A Horcrux adapter.
    # keys    - Array of String keys to fetch.
    #
    # Returns an Array tuple with a Hash of found keys/values, and an Array of
    # missing keys.
    def get_from_adapter(adapter, keys)
      missing = []
      found = {}

      adapter.get_all(*keys).each_with_index do |value, index|
        key = keys[index]

        if value
          found[key] = value
        else
          missing << key
        end
      end unless keys.empty?

      [found, missing]
    end

    # Call the on_missing callbacks for the handlers that were missing keys.
    # This gives you a chance to set those values in the secondary adapters.
    #
    # values  - A Hash of all of the found keys => values.
    # missing - A Hash of Adapter => Array of missing keys.
    #
    # Returns nothing.
    def call_missing_handlers(values, missing)
      return if @missing_handlers.empty?
      missing.each do |adapter, keys|
        missing_values = {}
        keys.each do |key|
          missing_values[key] = values[key]
        end

        @missing_handlers.each do |handler|
          handler.call adapter, missing_values
        end
      end
    end
  end
end

