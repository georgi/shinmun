require 'kontrol'
require 'bluecloth'
require 'git_store'

class GitApp < Kontrol::Application

  def initialize(path)
    super
    @store = GitStore.new(path)
  end
  
  map do
    page '/(.*)' do |name|
      text BlueCloth.new(@store[name]).to_html
    end
  end
end

run GitApp.new
