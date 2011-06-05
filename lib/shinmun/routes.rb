Shinmun::Blog.map do
 
  category '/categories/(.*)' do |name|
    category = find_category(name)
    
    render 'category.rhtml', :category => category, :posts => posts_by_category[category]
  end

  tag '/tags/(.*)' do |tag|
    render 'category.rhtml', :name => "Tag: #{tag}", :posts => posts_by_tag[tag]
  end

  post '/(\d+)/(\d+)/(.*)' do |year, month, name|
    if post = posts_by_date[year.to_i][month.to_i][name]
      render 'post.rhtml', :post => post
    else
      render '404.rhtml', :path => request.path_info
    end
  end

  archive '/(\d+)/(\d+)' do |year, month|
    render('archive.rhtml',
           :year => year.to_i,
           :month => month.to_i,
           :posts => posts_by_date[year.to_i][month.to_i].values)
  end

  feed '/index\.rss' do
    render 'index.rxml', :layout => false, :posts => posts[0, 20]
  end

  index '/$' do
    render 'index.rhtml', :posts => posts[0, 20]
  end

  page '/(.*)' do |path|
    path = path.gsub('..', '')

    if page = pages[path]
      render 'page.rhtml', :page => page      
    elsif File.exist?("public/#{path}")
      file = Rack::File.new(nil)
      file.path = "public/#{path}"
      response.body = file
    else
      render '404.rhtml', :path => path
    end
  end
  
end
