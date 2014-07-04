require 'fileutils'

module TypepadToJekyll

# Convert Typepad Backup (MTIF Format) to 
# Jekyll posts.  MTIF -> Jekyll _posts
class Converter
  attr_reader   :jekyll_base_dir, :posts_dir, :drafts_dir
  attr_reader   :typepad_backup_filename
  attr_accessor :posts

  def initialize(backup_filename, jekyll_base_directory)
    @typepad_backup_filename   = backup_filename
    @jekyll_base_dir           = jekyll_base_directory
    @posts_dir                 = File.join(jekyll_base_dir, '_posts')
    @drafts_dir                = File.join(jekyll_base_dir, '_drafts')
    @posts                     = []
  end

  def process
    setup_sub_dirs
    parse_backup_file
    write_posts
  end

  private

  def parse_backup_file
    app = TypepadToJekyll::Parser.new
    app.source_filename = typepad_backup_filename
    app.process
    @posts = app.posts
  end

  #write post to _posts directory in jekyll format
  def write_posts
    posts.each do |post|
      if post.status == :publish
        dir = posts_dir
      else
        dir = drafts_dir
      end
      fname = File.join(dir, post.filename)
      File.open(fname, 'w') do |file|
        file.puts post.to_jekyll
      end
    end
  end

  def setup_sub_dirs
    dirs = [posts_dir, drafts_dir]
    dirs.each do |dir|
      FileUtils.mkdir_p(dir) if not File.directory?(dir)
    end
  end

end # class
end # module
