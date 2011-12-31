# Horcrux

A Horcrux is a powerful object in which a Dark wizard or witch has hidden a
fragment of his or her soul for the purpose of attaining immortality.

The Horcrux ruby gem is an abstract key/value store adapter library.  

Horcrux adapters are shims around key/value systems.  They need to define at
least these three methods:

    def get(key)
      client[key]
    end

    def set(key, value)
      client[key] = value
      true
    end

    def delete(key)
      client.delete(key) ? true : false
    end

See Horcrux::Memory for a simple example.

They should also include the Horcrux::Methods module.  If the underlying
key/value system can perform some operations more efficiently, they can 
be overridden:

    # using a redis client
    def set_all(*keys)
      args = keys.to_a
      args.flatten!
      client.mset *args
      Array.new(keys.size, true) # redis set always succeeds
    end

Adapters can also choose a Serializer object.  A Serializer is any object that
responds to #pack and #unpack.  Here's what a simple JSON one might look like:

    module YajlSerializer
      def self.pack(value)
        Yajl.dump(value)
      end

      def self.unpack(str)
        Yajl.load(str, :symbolize_keys => true)
      end
    end

You can then pass this in while creating your Horcrux adapter:

    @adapter = Horcrux::Memory.new({}, YajlSerializer)

## ToyStore Adapter

A lot of these ideas came from [the Adapter gem][adapter].  It ties into a rad
[Toystore ORM][toystore].  Check them out... if they work for you, use them!

Horcrux differs in a few areas:

* Focus on batch get/set/delete operations.
* Serializers are a separate object.  BYOS.
* Boring test/unit tests.  
* Ruby 1.8.7 and Ruby 1.9.x compatibility.

[adapter]: https://github.com/newtoy/adapter
[toystore]: https://github.com/newtoy/toystore

## Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version
   unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have
   your own version, that is fine but bump version in a commit by itself I can
   ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

