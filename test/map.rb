Kontrol.map do
  get '/categories/(.*)\.rss' do |category|
    render 'category.rxml', find_category(category)
  end

  get '/categories/(.*)' do |category|
    render 'category.rhtml', find_category(category)
  end

  get '/(\d+)/(\d+)/(.*)' do |year, month, name|
    post = find_post(year.to_i, month.to_i, name)
    render 'post.rhtml', :post => post, :comments => comments_for(post)
  end

  get '/(\d+)/(\d+)' do |year, month|
    render 'archive.rhtml', :year => year.to_i, :month => month.to_i
  end

  get '/index\.rss' do
    render 'index.rxml'
  end

  post '/comments' do
    post = find_by_path(params['path'])
    post_comment(post, params)
    render '_comments.rhtml', :comments => comments_for(post)
  end

  get '/assets/javascripts\.js' do
    render_javascripts
  end

  get '/assets/stylesheets\.css' do
    render_stylesheets
  end

  get '/assets/(.*)' do |path|
    if_modified_since do
      assets[path] or raise "#{path} not found"
    end
  end

  get '/$' do
    render 'index.rhtml'
  end

  get '/(.*)' do |name|
    post = find_page(name)
    render 'page.rhtml', :post => post if post
  end
end
