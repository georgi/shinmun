Shinmun::Blog.map do
  
  get '/categories/(.*)\.rss' do |category|
    render 'category.rxml', find_category(category)
  end
 
  get '/categories/(.*)' do |category|
    render 'category.rhtml', find_category(category)
  end

  get '/(\d+)/(\d+)/(.*)' do |year, month, name|
    post = find_post(year.to_i, month.to_i, name)
    render 'post.rhtml', :post => post, :comments => comments_for(post.path)
  end

  get '/(\d+)/(\d+)' do |year, month|
    render 'archive.rhtml', :year => year.to_i, :month => month.to_i, :posts => posts_for_month(year.to_i, month.to_i)
  end

  get '/index\.rss' do
    render 'index.rxml'
  end

  post '/comments' do
    if params['preview']
      render '_comments.rhtml', :comments => [Shinmun::Comment.new(params)]
    else
      post_comment(params['path'], params)
      render '_comments.rhtml', :comments => comments_for(path)
    end    
  end

  get '/assets/javascripts\.js' do
    scripts = assets['javascripts'].to_a.join
    if_none_match(etag(scripts)) { scripts }    
  end

  get '/assets/stylesheets\.css' do
    styles = assets['stylesheets'].to_a.join
    if_none_match(etag(styles)) { styles }
  end

  get '/assets/(.*)' do |path|
    file = assets[path] or raise "#{path} not found"
    if_none_match(etag(file)) { file }
  end

  map '/admin' do
    use Rack::Auth::Basic do |username, password|
      File.read(File.join(File.dirname(__FILE__), "password")).chomp("\n") == password
    end

    get '/posts/(.*)' do |page|
      session[:admin] = true
      render 'admin/posts.rhtml', :posts => posts_by_date, :page => page.to_i, :page_size => 10
    end

    get '/pages' do
      render 'admin/pages.rhtml'
    end

    get '/commits/(.*)' do |id|    
      render 'admin/commit.rhtml', :commit => repo.commit(id)
    end

    get '/commits' do
      render 'admin/commits.rhtml'
    end

    map '/edit/(.*)' do
      get do |path|
        render 'admin/edit.rhtml', :post => store[path]
      end

      post do |path|
        post = store[path]
        update_post(post, params['data'])
        redirect(post.date ? '/admin/posts/' : '/admin/pages')
      end
    end

    post '/delete/(.*)' do |path|
      post = store[path]
      delete_post post
      redirect(post.date ? '/admin/posts/' : '/admin/pages/')
    end

    post '/create' do
      post = create_post(params)
      redirect "/admin/edit/#{post.path}"
    end

    get '' do
      redirect '/admin/posts/'
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
