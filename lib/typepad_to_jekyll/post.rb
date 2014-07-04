module TypepadToJekyll
class Comment
  attr_accessor :author, :email, :ip, :url, :date, :body

  def initialize
    @body = ''
  end
end
end


module TypepadToJekyll
class Post
  attr_accessor :author, :title, :status, :allow_comments, :convert_breaks
  attr_accessor :allow_pings, :basename, :unique_url, :date, :body
  attr_accessor :extended_body, :excerpt

  attr_reader   :categories, :keywords, :comments

  def initialize
    @categories = []
    @keywords = []
    @comments = []
    @body = ''
    @extended_body = ''
    @excerpt = ''
  end

  def filename
    "#{date.strftime("%Y-%m-%d")}-#{basename}.html"
  end

  def to_jekyll
    str = []
    str << '---'
    str << 'layout: post'
    str << 'title: ' + clean_yaml(title)
    str << "date: #{date.strftime("%Y-%m-%d %H:%M:%S")}"
    if categories.size == 1
      str << "category: #{categories.first}"
    elsif categories.size > 1
      str << "categories: #{categories.join(' ')}"
    end
    str << '---'
    str << body
    str << extended_body

    return str.join("\n")
  end

  #handle colons, quotes, and double quotes in string
  def clean_yaml(str)
    if str.include?(':') or str.include?("'") or str.include?('"')
      #return "'" + str.gsub(/"/, '\"').gsub(/'/, "''") + "'"
      return "'" + str.gsub(/'/, "''") + "'"
    else
      return str
    end
  end

  def new_comment
    c = Comment.new
    comments << c
    return c
  end

end
end
