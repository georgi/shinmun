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
    if params['preview']
      render '_comments.rhtml', :comments => [Shinmun::Comment.new(params)]
    else
      post_comment(post, params)
      render '_comments.rhtml', :comments => comments_for(post)
    end    
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
        render 'admin/edit.rhtml', :post => find_by_path(path)
      end

      post do |path|        
        update_post(post = find_by_path(path), params['data'])
        redirect(post.date ? '/admin/posts/' : '/admin/pages')
      end
    end

    post '/delete/(.*)' do |path|
      delete_post(post = find_by_path(path))
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
    post = find_page(path)
    render 'page.rhtml', :post => post if post
  end
end
