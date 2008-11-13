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

    def self.read(path)
      file = "comments/#{path}"
      body = ''

      FileUtils.mkdir_p(File.dirname(file))

      if File.exist?(file)
        File.open(file, "r") do |io|
          io.flock(File::LOCK_SH)
          body = io.read
          io.flock(File::LOCK_UN)
        end
      end

      body.split("\n").map do |line|
        from_json(line)
      end
    end

    def self.write(path, comment)
      file = "comments/#{path}"

      FileUtils.mkdir_p(File.dirname(file))

      File.open(file, "a") do |io|
        io.flock(File::LOCK_EX)
        io.puts(comment.to_json)
        io.flock(File::LOCK_UN)
      end
    end

  end

end
