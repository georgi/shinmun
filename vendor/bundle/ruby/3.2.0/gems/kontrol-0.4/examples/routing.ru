require 'kontrol'

class Routing < Kontrol::Application
  map do
    pages '/pages/(.*)' do |name|
      text "The path is #{ pages_path name }! "
    end

    archive '/(\d*)/(\d*)' do |year, month|
      text "The path is #{ archive_path year, month }! "
    end
  end
end

run Routing.new
