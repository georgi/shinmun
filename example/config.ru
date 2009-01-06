require 'shinmun'

use Rack::Session::Cookie
use Rack::Reloader

run Shinmun::Blog.new(File.dirname(__FILE__))
