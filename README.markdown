# Henshin

So this will be a static site generator, similar in idea to Jekyll. But the whole point of this is that it won't have the problems Jekyll has because it will be new! Features it needs are:
- Ability to (re-)generate only changed files, will probably use a dotfile `.updates` or something to keep track of times and stuff.
- Better defaults so that I can just create a site from a set of text files without creating templates.
- Tags and categories should be better implemented and easier to use.
- Archive pages should be __easy__
- Shouldn’t be coupled as tightly to the file naming.
- Should be able to add an option that shows how file names are parsed
- A plugin system would be nice, so that other parsers for markup languages, sass, coffeescript, etc, could be easily added.

## Note on Patches/Pull Requests

- Fork the project
- Make your feature addition or bug fix
- Add tests for it. This is important so I don't break it in a
  future version unintentionally.
- Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
- Send me a pull request. Bonus points for topic branches.

## License

Copyright (c) 2010 Joshua Hawxwell. See LICENSE for details.