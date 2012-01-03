require File.expand_path('../helper', __FILE__)

module Horcrux
  class EntityTest < Test::Unit::TestCase
    class Entity
      include Horcrux::Entity

      attr :string, :name
      attr :bool, :admin

      attr :array, :roles

      readonly :string, :type
      readonly :hash, :codes

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

      assert_raises NoMethodError do
        ent.type = 'troll'
      end

      assert_raises NoMethodError do
        ent.codes = 'troll'
      end

      assert_raises TypeError do
        ent.roles = 1
      end
    end

    def test_dumps_entity_to_hash
      hash = entity.to_hash
      assert_equal 'bob', hash[:name]
      assert_equal 'person', hash[:type]
      assert_equal true, hash[:admin]
      assert_equal %w(a b), hash[:roles]
      assert_equal({"a" => 1, "b" => 2}, hash[:codes])
    end

    def test_tracks_attributes
      assert Entity.attributes.include?('name')
      assert Entity.attributes.include?('admin')
      assert Entity.attributes.include?('type')
      assert Entity.attributes.include?('roles')
      assert Entity.attributes.include?('codes')
    end

    def test_tracks_writable_attributes
      assert Entity.writable_attributes.include?('name')
      assert Entity.writable_attributes.include?('admin')
      assert Entity.writable_attributes.include?('roles')
      assert !Entity.writable_attributes.include?('codes')
      assert !Entity.writable_attributes.include?('type')
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
      hash = {:name => 'bob', :type => 'person', :admin => true,
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

