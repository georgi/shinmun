require 'shinmun'

use Rack::Session::Cookie
use Rack::Reloader

blog = Shinmun::Blog.new(File.dirname(__FILE__))

blog.config = {
  :language => 'en',
  :title => "Shinmun Blog",
  :author => "Shinmun Team",
  :categories => ["Ruby", "Javascript"],
  :description => "A lightweight file-based blog engine"
}

run blog
