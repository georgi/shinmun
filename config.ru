require 'shinmun'

use Rack::Session::Cookie
use Rack::Reloader

blog = Shinmun::Blog.new(File.dirname(__FILE__))

blog.config = {
  :language => 'en',
  :title => "Blog Title",
  :author => "The Author",
  :categories => ["Ruby", "Javascript"],
  :description => "Blog description"
}

run blog
