# See the README.md
module Horcrux
  VERSION = "0.1.2"

  # Implements the optional methods of a Horcrux adapter.
  module Methods
    def self.included(klass)
      klass.send :attr_reader, :client, :serializer
    end

    # Public: Sets up an adapter with the client.
    #
    # client     - This is the object that the adapter uses to store and
    #              retrieve data.
    # serializer - An object that responds to #pack and #unpack for
    #              serializing and deserializing values.  Default: a
    #              StringSerializer.
    def initialize(client, serializer = nil)
      @client = client
      @serializer = serializer || StringSerializer
    end

    # Public: Gets all the values for the given keys.
    #
    #     @adapter.get_all('a', 'b')
    #     # => ['1', '2']
    #
    # keys - One or more String keys.
    #
    # Returns an Array of unpacked values in the order of their associated
    # keys.
    def get_all(*keys)
      keys.map { |k| get(k) }
    end

    # Public: Sets the given values.
    #
    #     @adapter.set_all 'a' => '1', 'b' => '2'
    #     # => ['a', 'b']
    #
    # values - A Hash of String keys and Object values.
    #
    # Returns an Array of the successfully written String keys.
    def set_all(values)
      good_keys = []
      values.each do |key, value|
        good_keys << key if set(key, value)
      end
      good_keys
    end

    # Public: Deletes the given keys.
    #
    #     @adapter.delete_all 'a', 'b'
    #     # => [true, false]
    #
    # keys - One or more String keys.
    #
    # Returns an Array of Booleans specifying whether the deletes were
    # successful.
    def delete_all(*keys)
      keys.map { |k| delete(k) }
    end

    # Public: Determines if the key is set.
    #
    # key - A String key.
    #
    # Returns true if the key is set, or false.
    def key?(key)
      !get(key).nil?
    end

    # Public: Either gets the value of the key, or sets it if it doesn't exist.
    #
    #     # if 'some-cache' is not set, call #slow_method
    #     @adapter.fetch('some-cache') { slow_method }
    #
    # key - A String key.
    #
    # Yields if the key does not exist.  The key is set to the return value of
    # the block.
    # Returns the Object value.
    def fetch(key)
      get(key) || begin
        value = yield
        set(key, value)
        value
      end
    end

    # Public: Transforms the given application key to the internal key that
    # the storage system uses.
    #
    # key - The String key.
    #
    # Returns the String internal key for the adapter.
    def key_for(key)
      key.to_s
    end
  end

  # Passes values through Horcrux untouched.
  module NullSerializer
    def self.dump(value)
      value
    end

    def self.load(str)
      str
    end
  end

  # Ensures that Horcrux values are turned to strings.
  module StringSerializer
    def self.dump(value)
      value.to_s
    end

    def self.load(str)
      str
    end
  end

  class Memory
    include Methods

    # Sample Horcrux adapter that stores unmodified values in a ruby Hash.
    #
    # client - Optional Hash.
    def initialize(client = {}, serializer = NullSerializer)
      @client = client
      @serializer = serializer
    end

    # Public: Uses Hash#key? to check the existence of a key.
    #
    # key - String key.
    #
    # Returns true if the key exists, or false.
    def key?(key)
      client.key? key_for(key)
    end

    # Public: Gets the value for the given key.
    #
    # key - The String key.
    #
    # Returns the Object value.
    def get(key)
      serializer.load client[key_for(key)]
    end

    # Public: Sets the value for the given key.
    #
    # key   - The String key.
    # value - The Object value.
    #
    # Returns true if the operation succeeded, or false.
    def set(key, value)
      client[key_for(key)] = serializer.dump(value)
      true
    end

    # Public: Deletes the value for the given key.
    #
    # key - The String key.
    #
    # Returns true if a value was deleted, or false.
    def delete(key)
      !client.delete(key_for(key)).nil?
    end
  end
end
