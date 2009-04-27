Shinmun::Blog.map do
  
  category_feed '/categories/(.*)\.rss' do |category|
    render 'category.rxml', find_category(category).merge(:layout => false)
  end
 
  category '/categories/(.*)' do |category|
    render 'category.rhtml', find_category(category)
  end

  tag '/tags/(.*)' do |tag|
    render 'category.rhtml', :name => "Tag: #{tag}", :posts => posts_with_tags(tag)
  end

  comments '/(\d+)/(\d+)/(.*)/comments' do |year, month, name|
    post = find_post(year.to_i, month.to_i, name) or raise "post not found #{request.path_info}"
    
    if params['preview']
      comments = comments_for(post).push(Shinmun::Comment.new(params))
      render 'post.rhtml', :post => post, :comments => comments
    else
      create_comment(post, params)
      render 'post.rhtml', :post => post, :comments => comments_for(post)
    end
  end

  post '/(\d+)/(\d+)/(.*)' do |year, month, name|
    post = find_post(year.to_i, month.to_i, name) or raise "post not found #{request.path_info}"
    render 'post.rhtml', :post => post, :comments => comments_for(post)
  end

  archive '/(\d+)/(\d+)' do |year, month|
    render 'archive.rhtml', :year => year.to_i, :month => month.to_i, :posts => posts_for_month(year.to_i, month.to_i)
  end

  feed '/index\.rss' do
    render 'index.rxml', :layout => false
  end

  index '/$' do
    render 'index.rhtml'
  end

  page '/(.*)' do |path|
    path = path.gsub('..', '')
    page = find_page(path)
          
    if page
      render 'page.rhtml', :page => page
      
    elsif file = store[path]
      text file
    else
      render '404.rhtml', :path => path
    end
  end
  
end
