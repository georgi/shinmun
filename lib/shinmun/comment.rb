module Shinmun

  unless defined?(Comment)
    class Comment < Struct.new(:time, :name, :website, :text)
    end
  end

  class Comment
               
    def self.from_json(s)
      new(*JSON.parse(s))
    end

    def to_json
      [ time.strftime('%Y-%m-%d %H:%M:%S'), name, website, text ].to_json
    end

    def self.read(guid)
      comment_file = "comments/#{guid}"
      body = ''

      if File.exist?(comment_file)
        File.open(comment_file, "r") do |io|
          io.flock(File::LOCK_SH)
          body = io.read
          io.flock(File::LOCK_UN)
        end
      end

      body.split("\n").map do |line|
        from_json(line)
      end
    end

    def self.write(guid, comment)
      comment_file = "comments/#{guid}"

      File.open(comment_file, "a") do |io|
        io.flock(File::LOCK_EX)
        io.puts(comment.to_json)
        io.flock(File::LOCK_UN)
      end
    end

  end

end
