require_relative '../helper'

describe Henshin::Site do

  subject { Henshin::Site }
  let(:site) { test_site }

  describe '.file' do
    it 'adds the file to the list' do
      klass = subject.dup
      klass.file :a, :b
      klass.file_list.must_include :a
      klass.file_list.must_include :b
    end
  end

  describe '.files' do
    it 'adds the files to the list' do
      klass = subject.dup
      klass.files :a, :b
      klass.files_list.must_include :a
      klass.files_list.must_include :b
    end
  end

  describe '#initialize' do
    let(:klass) {
      k = subject.dup
      k.any_instance.stubs(:config).returns({:ignore => 'a'})
      k
    }

    it 'creates a reader' do
      obj = klass.new(test_path)
      obj.instance_variable_get(:@reader).must_be_kind_of Henshin::Reader
    end

    it 'sets the source' do
      obj = klass.new(test_path.to_s)
      obj.instance_variable_get(:@source).must_equal test_path
    end

    it 'sets ignored paths' do
      obj = klass.new(test_path)
      obj.instance_variable_get(:@reader).ignore?(test_path + 'a').must_equal true
    end
  end

  describe '#dest' do
    it 'returns the build path' do
      site.dest.must_equal (Pathname.pwd + 'site' + 'build')
    end

    it 'uses the destination set in the config' do
      site.stubs(:config).returns({:build => 'different'})
      site.dest.must_equal (Pathname.pwd + 'site' + 'build')
    end
  end

  describe '#root' do
    it 'returns the url root' do
      site.root.must_equal Pathname.new('/')
    end
  end

  describe '#config' do
    it 'combines the loaded config.yml with the defaults' do
      site.config.author.must_equal "You"
      site.config.md.superscript.must_equal true
    end

    it 'is a Hashie::Mash' do
      site.config.must_be_kind_of Hashie::Mash
    end
  end

  describe '#script' do
    it 'returns the script package' do
      site.script.must_be_kind_of Henshin::Package::Script
    end
  end

  describe '#style' do
    it 'returns the style package' do
      site.style.must_be_kind_of Henshin::Package::Style
    end
  end

  describe '#posts' do
    it 'returns the posts' do
      site.posts.all? {|p| p.kind_of?(Henshin::File::Post) }.must_equal true
    end
  end

  describe '#files' do
    it 'returns all other files' do
      site.files.map(&:permalink).must_include '/index.html', '/feed.xml'
    end
  end

  describe '#all_files' do
    it 'returns all files' do
      site.all_files.sort.must_equal [site.style, site.script, site.posts, site.files].flatten.sort
    end
  end

  describe '#templates' do
    it 'returns all templates' do
      site.templates.map(&:name).must_include 'default', 'post'
    end
  end

  describe '#method_missing' do
    it 'gets the value from the yaml' do
      site.author.must_equal "You"
    end
  end

  describe '#write' do
    it 'writes all the files' do
      writer = Object.new
      a, b = mock(:write => writer), mock(:write => writer)
      site.expects(:all_files).returns([a, b])

      site.write(writer)
    end
  end

  describe '#template' do
    it 'finds the template' do
      default = site.template('default')
      default.must_be_kind_of Henshin::File::Template
      default.name.must_equal 'default'
    end

    it 'returns the EmptyTemplate if not found' do
      temp = site.template('non-existent')
      temp.must_be_kind_of Henshin::File::EmptyTemplate
    end
  end

end
