Shinmun::Blog.map do
  
  category_feed '/categories/(.*)\.rss' do |category|
    render 'category.rxml', find_category(category).merge(:layout => false)
  end
 
  category '/categories/(.*)' do |category|
    render 'category.rhtml', find_category(category)
  end

  tag '/tags/(.*)' do |tag|
    render 'category.rhtml', :name => "Tag: #{tag}", :posts => posts.select { |p| p.tag_list.include?(tag)  }
  end

  post '/(\d+)/(\d+)/(.*)' do |year, month, name|
    post = find_post(year.to_i, month.to_i, name)
    render 'post.rhtml', :post => post, :comments => comments_for(post.path)
  end

  archive '/(\d+)/(\d+)' do |year, month|
    render 'archive.rhtml', :year => year.to_i, :month => month.to_i, :posts => posts_for_month(year.to_i, month.to_i)
  end

  feed '/index\.rss' do
    render 'index.rxml', :layout => false
  end

  comments '/comments' do
    if params['preview'] == 'true'
      render '_comments.rhtml', :comments => [Shinmun::Comment.new(params)]
    else
      post_comment(params['path'], params)
      render '_comments.rhtml', :comments => comments_for(params['path'])
    end    
  end

  javascripts '/assets/javascripts\.js' do
    scripts = assets['javascripts'].to_a.join
    if_none_match(etag(scripts)) do
      text scripts
    end
  end

  stylesheets '/assets/stylesheets\.css' do
    styles = assets['stylesheets'].to_a.join
    if_none_match(etag(styles)) do
      text styles
    end
  end

  assets '/assets/(.*)' do |path|
    file = assets[path] or raise "#{path} not found"
    if_none_match(etag(file)) do
      text file
    end
  end

  get '/$' do
    render 'index.rhtml'
  end

  get '/(.*)' do |path|
    page = find_page(path)
          
    if page
      render 'page.rhtml', :page => page
    else
      raise "page '#{path}' not found"
    end
  end
  
end
