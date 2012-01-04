require File.expand_path('../helper', __FILE__)

module Horcrux
  class EntityTest < Test::Unit::TestCase
    class Entity
      include Horcrux::Entity

      attr :string, :name
      attr :bool, :admin
      attr :array, :roles
      attr :time, :updated_at

      readonly :string, :type
      readonly :hash, :codes
      readonly :time, :created_at
      
      def initialize(hash)
        super(hash)
        @created_at ||= Time.now.utc
      end

      def type
        @type ||= 'default'
      end
    end

    def test_accesses_attributes
      ent = entity
      assert_equal 'bob', ent.name
      assert_equal 'person', ent.type
      assert_equal true, ent.admin
      assert ent.admin?

      ent.name = 'bobby'
      assert_equal 'bobby', ent.name

      ent.admin = 0
      assert !ent.admin?
      
      ent.admin = 'true'
      assert ent.admin?

      ent.admin = false
      assert !ent.admin?

      ent.roles = %w(c)
      assert_equal %w(c), ent.roles

      assert_equal 2000, ent.created_at.year
      assert_equal 2012, ent.updated_at.year

      ent.updated_at = Time.utc 2010
      assert_equal 2010, ent.updated_at.year

      assert_raises ArgumentError do
        ent.update_attrs :type => 'troll'
      end

      assert_raises ArgumentError do
        ent.update_attrs :codes => 'troll'
      end

      assert_raises ArgumentError do
        ent.update_attrs :created_at => Time.now
      end

      ent.roles = nil
      assert_equal [], ent.roles
      
      ent.codes = nil
      assert_equal({}, ent.codes)

      assert_raises TypeError do
        ent.roles = 1
      end
    end

    def test_initializes_with_default_value
      ent = entity(:created_at => nil)
      assert_equal Time.now.utc.year, ent.created_at.year
    end

    def test_dumps_entity_to_hash
      hash = entity.to_hash
      assert_equal 'bob', hash[:name]
      assert_equal 'person', hash[:type]
      assert_equal true, hash[:admin]
      assert_equal %w(a b), hash[:roles]
      assert_equal({"a" => 1, "b" => 2}, hash[:codes])
      assert_equal 2000, hash[:created_at].year
      assert_equal 2012, hash[:updated_at].year
    end

    def test_tracks_attributes
      assert Entity.attributes.include?('name')
      assert Entity.attributes.include?('admin')
      assert Entity.attributes.include?('type')
      assert Entity.attributes.include?('roles')
      assert Entity.attributes.include?('codes')
      assert Entity.attributes.include?('created_at')
      assert Entity.attributes.include?('updated_at')
    end

    def test_tracks_writable_attributes
      assert Entity.writable_attributes.include?('name')
      assert Entity.writable_attributes.include?('admin')
      assert Entity.writable_attributes.include?('roles')
      assert Entity.writable_attributes.include?('updated_at')
      assert !Entity.writable_attributes.include?('codes')
      assert !Entity.writable_attributes.include?('type')
      assert !Entity.writable_attributes.include?('created_at')
    end

    def test_tracks_default_attribute
      assert_equal 'name', Entity.default_attribute
    end

    def test_convert_hash_to_entity
      data = entity_data :name => "fred"
      ent = entity :name => 'fred'
      assert_equal ent, Entity.from(data)
      assert_equal ent, Entity.from(ent)
    end

    def entity(options = {})
      Entity.new(entity_data(options))
    end

    def entity_data(options = {})
      hash = {:name => 'bob', :type => 'person', :admin => 't',
        :created_at => Time.utc(2000), :updated_at => 1325619163,
        :roles => %w(a b), :codes => {'a' => 1, 'b' => 2}}
      options.each do |key, value|
        if value.nil?
          hash.delete key
        else
          hash[key] = value
        end
      end
      hash
    end
  end
end

