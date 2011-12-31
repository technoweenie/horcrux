# Horcrux

A Horcrux is a powerful object in which a Dark wizard or witch has hidden a
fragment of his or her soul for the purpose of attaining immortality.

The Horcrux ruby gem is an abstract key/value store adapter library.  

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

