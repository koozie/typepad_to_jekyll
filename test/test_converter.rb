gem 'minitest'
require 'minitest/autorun'
require 'typepad_to_jekyll'

class ParserTestOne < Minitest::Test

  def setup
    @fn = File.join(File.dirname(__FILE__),'data','typepad_one_post.txt')
    @app = TypepadToJekyll::Parser.new
    @app.source_filename = @fn
    @app.process
  end

  def test_one_post_front_matter
    assert_equal @fn, @app.source_filename

    post = @app.posts.first
    assert_equal 'Chris', post.author
    assert_equal 'First Post', post.title
    assert_equal :draft, post.status
    assert_equal 'http://www.example.org/2003/05/first_post.html', post.unique_url
    assert_equal '05/29/2003 01:02:06 AM', post.date.strftime("%m/%d/%Y %I:%M:%S %p")
  end

  def test_comment_one_post
    post = @app.posts.first
    assert_equal 1, post.comments.size
    comment = post.comments.first
    assert_equal 'Troy Aikman', comment.author
    assert_equal 'troy@example.com', comment.email
    assert_equal '208.201.230.101', comment.ip
    assert_equal '05/30/2003 01:32:14 PM', comment.date.strftime("%m/%d/%Y %I:%M:%S %p")
    assert_equal "Easy, ain't it? :)\nlaters\n", comment.body
  end
end

class ParserTestMultilePosts < Minitest::Test
  def setup
    @fn = File.join(File.dirname(__FILE__),'data','typepad_multiple_posts.txt')
    @app = TypepadToJekyll::Parser.new
    @app.source_filename = @fn
    @app.process
  end

  def test_last_post_front_matter
    post = @app.posts.last
    assert_equal 'John Franklin McEnroe', post.author
    assert_equal 'Home Wi-Fi', post.title
    assert_equal :publish, post.status
    assert_equal 'http://blog.example.org/2003/01/home_wifi.html', post.unique_url
    assert_equal '01/10/2003 01:39:35 PM', post.date.strftime("%m/%d/%Y %I:%M:%S %p")
  end

  def test_all_comments_parse_last_post
    post = @app.posts.last
    assert_equal 5, post.comments.size
  end

  def test_last_comment_from_last_post
    post = @app.posts.last
    comment = post.comments.last
    assert_equal 'Jerry McGuire', comment.author
    assert_equal 'blog@example.net', comment.email
    assert_equal '81.86.172.239', comment.ip
    assert_equal '08/13/2003 04:00:09 AM', comment.date.strftime("%m/%d/%Y %I:%M:%S %p")
    assert_equal "I had something similar - a LONG piece of cable through a hole drilled in the ceiling from the upstairs office into the living room and then coiled in a big loop so it would reach anywhere downstairs if stretched across the room....that changed when I got married :-)\n", comment.body
  end
end


# Tests for checking blog post title where ' or " or : appears in title
require 'yaml'
class ParserTestPostTileYamlIssues < Minitest::Test
  def setup
    @fn = File.join(File.dirname(__FILE__),'data','typepad_posts_yaml.txt')
    @app = TypepadToJekyll::Parser.new
    @app.source_filename = @fn
    @app.process
  end

  def test_first_post_front_matter
    post = @app.posts.first
    assert_equal 'Junk Faxes: Redux', post.title
    post_yaml = YAML.load(post.to_jekyll)
    assert_equal post_yaml['title'], post.title
  end

  def test_second_post_front_matter
    post = @app.posts[1]
    assert_equal 'All about Frank\'s "MIDI" Files', post.title
    post_yaml = YAML.load(post.to_jekyll)
    #assert_equal  'All about Frank\'s \"MIDI\" Files' ,post_yaml['title']
    assert_equal  'All about Frank\'s "MIDI" Files' ,post_yaml['title']
  end
end


# Tests for checking category single or categories multiple
require 'yaml'
class ParserTestCategories < Minitest::Test
  def setup
    @fn = File.join(File.dirname(__FILE__),'data','typepad_posts_yaml.txt')
    @app = TypepadToJekyll::Parser.new
    @app.source_filename = @fn
    @app.process
  end

  def test_first_post_category_single
    post = @app.posts.first
    post_yaml = YAML.load(post.to_jekyll)
    key = 'category'
    assert post_yaml.key?(key)
    assert post_yaml[key].split(' ').size == 1
  end

  def test_first_post_category_single
    post = @app.posts[1]
    post_yaml = YAML.load(post.to_jekyll)
    key = 'categories'
    assert post_yaml.key?(key)
    assert post_yaml[key].split(' ').size == 2
  end
end
