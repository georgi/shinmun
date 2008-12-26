module Shinmun

  class PostHandler
    def read(name, data)
      Post.new(:filename => name, :src => data)
    end

    def write(post)
      post.dump
    end    
  end
  
end

GitStore::Handler['md'] = Shinmun::PostHandler.new


