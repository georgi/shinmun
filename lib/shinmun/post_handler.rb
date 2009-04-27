module Shinmun

  class PostHandler
    def read(data)
      Post.new(:src => data)
    end

    def write(post)
      post.dump      
    end    
  end
  
end
