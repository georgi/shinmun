module Shinmun

  class Comment

    attr_accessor :time, :name, :email, :website, :text

    def initialize(attributes)
      for k, v in attributes
        send "#{k}=", v
      end
    end
               
    def self.read(path)
      file = "comments/#{path}"
      comments = []

      if File.exist?(file)
        File.open(file, "r") do |io|
          io.flock(File::LOCK_SH)
          YAML.each_document(io) do |comment|
            comments << comment
          end
          io.flock(File::LOCK_UN)
        end
      end

      comments
    end

    def self.write(path, comment)
      file = "comments/#{path}"

      FileUtils.mkdir_p(File.dirname(file))

      File.open(file, "a") do |io|
        io.flock(File::LOCK_EX)
        io.puts(comment.to_yaml)
        io.flock(File::LOCK_UN)
      end
    end

  end

end
