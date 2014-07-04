
dir = File.dirname(__FILE__)
lib = File.join(dir, "lib", "typepad_to_jekyll.rb")
require 'date'

Gem::Specification.new do |gem|
  gem.name    = 'typepad_to_jekyll'
  gem.version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]
  gem.executables << 'typepad_to'
  gem.date    = Date.today.to_s
  
  gem.summary = "'Typepad to Jekyll' is a ruby library and commandline app that converts a Typepad backup file (MTIF format) into Jekyll post files"
  gem.description = "A commandline application to convert Typepad and Moveabletype backup files into Jekyll posts.  Posts to be stored in either the _posts or _drafts directory"

  gem.authors  = ['Chris Stansbury']
  gem.email    = 'Chris@koozie.org'
  gem.homepage = 'https://github.com/koozie/typepad_to_jekyll'
  
  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] #& `git ls-files -z`.split("\0")
  gem.licenses = ['GPL-2', 'Ruby Software License']
end
