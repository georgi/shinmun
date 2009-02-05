module Shinmun

  class PostHandler
    def read(path, data)
      Post.new(:path => path, :src => data)
    end

    def write(path, post)
      post.dump
    end    
  end
  
end

GitStore::Handler['md'] = Shinmun::PostHandler.new
GitStore::Handler['html'] = Shinmun::PostHandler.new
