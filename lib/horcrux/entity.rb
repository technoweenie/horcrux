require File.expand_path('../../horcrux', __FILE__)
require 'set'
require 'time'

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
        method = "build_#{type}_attr"
        if respond_to?(method)
          send method, keys, false
        else
          raise TypeError, "Type #{type.inspect} not recognized."
        end
      end

      # Public
      def readonly(type, *keys)
        method = "build_#{type}_attr"
        if respond_to?(method)
          send method, keys, true
        else
          raise TypeError, "Type #{type.inspect} not recognized."
        end
      end

      # Public
      def from(hash = {})
        hash.respond_to?(@default_attribute) ? hash : new(hash)
      end

      def build_string_attr(keys, is_readonly)
        attr_reader *keys

        build_attrs(keys, is_readonly) do |key_s|
          ivar_key = "@#{key_s}"
          define_method "#{key_s}=" do |value|
            instance_variable_set ivar_key, value
          end
        end
      end

      def build_bool_attr(keys, is_readonly)
        attr_reader *keys

        build_attrs(keys, is_readonly) do |key_s|
          ivar_key = "@#{key_s}"

          define_method "#{key_s}?" do
            !!instance_variable_get(ivar_key)
          end

          define_method "#{key_s}=" do |value|
            instance_variable_set ivar_key, case value
              when Integer then value > 0
              when /t|f/i  then value =~ /t/i ? true : false
              else !!value
            end
          end
        end
      end

      def build_array_attr(keys, is_readonly)
        build_class_attr(Array, keys, is_readonly)
      end

      def build_hash_attr(keys, is_readonly)
        build_class_attr(Hash, keys, is_readonly)
      end

      def build_time_attr(keys, is_readonly)
        attr_reader *keys

        build_attrs(keys, is_readonly) do |key_s|
          ivar_key = "@#{key_s}"
          define_method "#{key_s}=" do |value|
            instance_variable_set ivar_key,
              value.respond_to?(:utc) ? 
                value :
                Time.at(value.to_i).utc
          end
        end
      end

      def build_class_attr(klass, keys, is_readonly)
        build_attrs(keys, is_readonly) do |key_s|
          ivar_key = "@#{key_s}"
          define_method key_s do
            instance_variable_get(ivar_key) ||
              instance_variable_set(ivar_key, klass.new)
          end

          define_method "#{key_s}=" do |value|
            unless value.nil? || value.is_a?(klass)
              raise TypeError, "#{key_s} should be a #{klass}: #{value.inspect}"
            end
            instance_variable_set(ivar_key, value)
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
      update_attrs(hash, all = true)
    end

    # Public: Updates multiple attributes.
    #
    # hash - A Hash containing valid attributes.
    #
    # Returns this Entity.
    def update_attrs(hash, all = false)
      attr = all ? self.class.attributes : self.class.writable_attributes
      hash.each do |key, value|
        key_s = key.to_s
        
        if !attr.include?(key_s)
          raise ArgumentError, "Invalid property: #{key.inspect}"
        end

        send "#{key_s}=", value
      end

      self
    end

    # Public
    def each_attr(writable_only = false)
      attr_method = writable_only ? :writable_attributes : :attributes
      self.class.send(attr_method).each do |key|
        if value = send(key)
          yield key, value
        end
      end
      self
    end

    # Public
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

