require File.expand_path('../helper', __FILE__)

module Horcrux
  class EntityTest < Test::Unit::TestCase
    class Entity
      include Horcrux::Entity

      attr :string, :name
      readonly :string, :type

      def type
        @type ||= 'default'
      end
    end

    def test_accesses_attributes
      ent = entity
      assert_equal 'bob', ent.name
      assert_equal 'person', ent.type

      ent.name = 'bobby'
      assert_equal 'bobby', ent.name

      assert_raises NoMethodError do
        ent.type = 'troll'
      end
    end

    def test_dumps_entity_to_hash
      hash = entity.to_hash
      assert_equal 'bob', hash[:name]
      assert_equal 'person', hash[:type]
    end

    def test_tracks_attributes
      assert Entity.attributes.include?('name')
      assert Entity.attributes.include?('type')
    end

    def test_tracks_writable_attributes
      assert Entity.writable_attributes.include?('name')
      assert !Entity.writable_attributes.include?('type')
    end

    def test_tracks_default_attribute
      assert_equal 'name', Entity.default_attribute
    end

    def test_convert_hash_to_entity
      data = entity_data
      assert_equal entity, ent = Entity.from(entity_data)
      assert_equal entity, ent
    end

    def entity(options = {})
      Entity.new(entity_data(options))
    end

    def entity_data(options = {})
      hash = {:name => 'bob', :type => 'person'}
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

