# IRB Helper file to be loaded during IRB debugging sessions.

source = Pathname.new("./examples/blog")
dest = source + Henshin::DEFAULTS['dest_suffix']

@site = Henshin::Blog.new({
  'source' => source,
  'dest' => dest
})