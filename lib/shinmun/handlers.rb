module Shinmun

  class ERBHandler
    def read(data)
      ERB.new(data)
    end
  end

  class PostHandler
    def read(data)
      Post.new(:src => data)
    end

    def write(post)
      post.dump      
    end    
  end
  
end
