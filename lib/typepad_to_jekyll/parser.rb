#!/usr/bin/env ruby

require 'pp'
require 'date'

module TypepadToJekyll

# Convert Typepad Backup (MTIF Format) to 
# Jekyll posts.  MTIF -> Jekyll _posts
class Parser

  attr_accessor   :source_filename
  attr_reader     :import_status, :current_line, :last_line
  attr_reader     :current_post, :posts
  attr_reader     :current_comment

  def initialize
    setup
  end

  def process
    setup
    process_typepad_file
  end

  private

  def process_typepad_file
    new_post
    File.open(source_filename,'r') do |file|
      file.each do |line|
        @last_line = current_line
        @current_line = line
        process_line
      end
    end
  end

  def new_post
    @import_status = :post_header  #:post_header, :body, :extended_body, :excerpt, :keywords, :boundary_5
    @current_post = Post.new
  end

  def check_boundary
    @import_status = :boundary_5 if current_line =~ /^-----/
    @import_status = :boundary_7 if current_line =~ /^-------/
  end

  def process_line
    check_boundary
    case import_status
    when :post_header 
      process_header_line
    when :comment_header 
      process_comment_line
    when :comment_body 
      process_comment_body
    when :body
      process_body
    when :extended_body
      process_extended_body
    when :excerpt
      process_excerpt
    when :boundary_7
      #write_post
      posts << current_post
      new_post
    when :boundary_5
      process_boundary5_item
    end
  end

  def process_boundary5_item
    case current_line
    when /^BODY/
      @import_status = :body
    when /^EXTENDED BODY/
      @import_status = :extended_body
    when /^EXCERPT/
      @import_status = :excerpt
    when /^KEYWORDS/
      @import_status = :keywords
    when /^COMMENT/
      @import_status = :comment_header
      @current_comment = current_post.new_comment 
    end
  end

  def process_body
    current_post.body += current_line
  end

  def process_extended_body
    current_post.extended_body += current_line
  end

  def process_excerpt
    current_post.excerpt += current_line if current_line.strip.chomp.size > 0
  end

  def process_comment_body
    current_comment.body += current_line
  end

  def process_comment_line
    return if current_line.strip == ""
    case current_line
    when /^AUTHOR/
      current_comment.author = current_line.split('AUTHOR:').last.strip
    when /^EMAIL/
      current_comment.email = current_line.split('EMAIL:').last.strip
    when /^IP/
      current_comment.ip = current_line.split('IP:').last.strip
    when /^URL/
      current_comment.url = current_line.split('URL:').last.strip
    when /^DATE/
      d_str = current_line.split('DATE:').last.strip
      current_comment.date = DateTime.strptime(d_str, "%m/%d/%Y %I:%M:%S %p")
      @import_status = :comment_body #comment body follows directly after comment date
    end
  end

  def process_header_line
    return if current_line.strip == ""
    case current_line
    when /^AUTHOR/
      current_post.author = current_line.split('AUTHOR:').last.strip
    when /^TITLE/
      current_post.title = current_line.split('TITLE:').last.strip
    when /^STATUS/
      current_post.status = current_line.split('STATUS:').last.strip.downcase.to_sym
    when /^ALLOW COMMENTS/
      current_post.allow_comments = current_line.split('ALLOW COMMENTS:').last.strip == '1' ? true : false
    when /^CONVERT BREAKS/
      current_post.convert_breaks = current_line.split('CONVERT BREAKS:').last.strip
    when /^ALLOW PINGS/
      current_post.allow_pings = current_line.split('ALLOW PINGS:').last.strip == '1' ? true : false
    when /^BASENAME/
      current_post.basename = current_line.split('BASENAME:').last.strip
    when /^CATEGORY/
      category_name = current_line.split('CATEGORY:').last.strip
      current_post.categories << clean_category_name(category_name)
    when /^UNIQUE URL/
      current_post.unique_url = current_line.split('UNIQUE URL:').last.strip
    when /^DATE/
      d_str = current_line.split('DATE:').last.strip
      current_post.date = DateTime.strptime(d_str, "%m/%d/%Y %I:%M:%S %p")
    end
  end

  def clean_category_name(cat)
    cat.downcase.gsub(/ /,'-')
  end

  def setup
    @posts = []
    @current_line = ''
    @last_line = ''
  end

end # class
end # module

__END__


    dirs = [destination_dir, posts_dir, drafts_dir]
    dirs.each do |dir|
      if not File.directory?(dir)
        puts "Not a directory [#{dir}]"
        exit 1
      end
    end





  #write post to _posts directory in jekyll format
  def write_post
    if current_post.status == :publish
      dir = posts_dir
    else
      dir = drafts_dir
    end
    fname = File.join(dir, current_post.filename)
    File.open(fname, 'w') do |file|
      file.puts current_post.to_yaml
    end
  end

