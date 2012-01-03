require File.expand_path('../../horcrux', __FILE__)
require 'set'

module Horcrux
  module Entity
    def self.included(base)
      class << base
        attr_accessor :attributes, :writable_attributes, :default_attribute
      end

      base.attributes = Set.new
      base.writable_attributes = Set.new
      base.extend ClassMethods
    end

    module ClassMethods
      # Public
      def attr(type, *keys)
        send "build_#{type}_attr", keys, false
      end

      # Public
      def readonly(type, *keys)
        send "build_#{type}_attr", keys, true
      end

      # Public
      def from(hash = {})
        hash.respond_to?(@default_attribute) ? hash : new(hash)
      end

      def build_string_attr(keys, is_readonly)
        attr_reader *keys

        build_attrs(keys, is_readonly) do |key_s|
          next if is_readonly

          ivar_key = "@#{key_s}"
          define_method "#{key_s}=" do |value|
            instance_variable_set ivar_key, value
          end
        end
      end

      def build_attrs(keys, is_readonly)
        keys.each do |key|
          key_s = key.to_s
          @default_attribute ||= key_s
          @attributes << key_s
          @writable_attributes << key_s unless is_readonly
          yield key_s
        end
      end
    end

    # Public
    def initialize(hash = {})
      update_attrs(hash)
    end

    # Public: Updates multiple attributes.
    #
    # hash - A Hash containing valid attributes.
    #
    # Returns this Entity.
    def update_attrs(hash)
      attr = self.class.attributes
      hash.each do |key, value|
        key_s = key.to_s
        if !attr.include?(key_s)
          raise ArgumentError, "Invalid property: #{key.inspect}"
        end

        instance_variable_set "@#{key_s}", value
      end

      self
    end

    def each_attr(writable_only = false)
      attr_method = writable_only ? :writable_attributes : :attributes
      self.class.send(attr_method).each do |key|
        if value = send(key)
          yield key, value
        end
      end
      self
    end

    def ==(other)
      default_attr = self.class.default_attribute
      other.class == self.class && other.send(default_attr) == send(default_attr)
    end

    # Public: Converts the valid attributes into a Hash of Symbol key and Object
    # value.
    #
    # Returns a Hash.
    def to_hash(writable_only = false)
      hash = {}
      each_attr(writable_only) do |key, value|
        hash[key.to_sym] = value
      end
      hash
    end
  end
end

