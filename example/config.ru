require 'shinmun'

Dir.chdir(File.dirname(__FILE__))

use Rack::Session::Cookie
use Rack::Reloader

run Shinmun::Blog.new
