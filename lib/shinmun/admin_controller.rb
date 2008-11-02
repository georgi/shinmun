require 'rack'
require 'json'

module Shinmun

  class AdminController

    def initialize(blog)
      @blog = blog
    end

    def tree(request)
      file_node(request.path_info[1..-1], 1).to_json
    end

    def get_page(request, path)
      page = @blog.find_page(path)

      { :title => page.title,
        :date => page.date,
        :category => page.category,
        :tags => page.tags ? page.tags.join(',') : nil,
        :body => page.body }.to_json
    end

    def put_page(request, path)
      params = request.params
      page = @blog.find_page(path)

      page.title     = params['title']
      page.author    = params['author']
      page.date      = Date.parse(params['date']) rescue nil
      page.category  = params['category']
      page.tags      = params['tags']
      page.languages = params['languages']
      page.body      = params['body']
      page.save

      git_add(page.filename, 'changed')

      return ''
    end

    def get_file(request, path)
      File.read(path)
    end

    def put_file(request, path)
      File.open(path, 'w') do |io|
        io << request.params['body']
      end
      git_add(path, 'changed')
      return ''
    end

    def data(request)
      path = request.path_info[1..-1]
      match = path.match(/^posts\/(.*)\.(.*)$/)
      method = request.request_method.downcase

      if match
        send("#{method}_page", request, match[1])
      else
        send("#{method}_file", request, path)
      end
    end

    def new_folder(request)
      path = request.path_info[1..-1] + '/' + request.params['name']

      unless File.exist?(path)
        Dir.mkdir(path) 
      end

      return ''
    end

    def new_file(request)
      path = request.path_info[1..-1] + '/' + request.params['name']

      unless File.exist?(path)
        File.open(path, "w").close
        git_add(path, 'created')
      end

      return ''
    end

    def rename(request)
      path = request.path_info[1..-1]
      dest = File.basename(path) + '/' + request.params['name']

      if File.exist?(path) and !File.exist?(dest)
        `git mv #{path} #{dest}`
        `git commit -m 'moved #{path} to #{dest}'`
      end

      return ''
    end

    def delete(request)
      path = request.path_info[1..-1]

      if File.file?(path)
        `git rm #{path}`
        `git commit -m 'deleted #{path}'`
      end

      return ''
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      action = request.params['action']

      response.body = send(action, request) if self.class.public_instance_methods.include?(action)

      response.status = 200
      response.finish
    end

    protected

    def git_add(file, message)
      `git add #{file}`
      `git commit -m '#{message} #{file}'`
    end

    def entries_for(path)
      Dir.entries(path).reject { |f| f.match /(\.|~)$/ }.sort
    end

    def root
      { :children => ['config', 'posts', 'public', 'templates'].map { |f| file_node(f, 1) } }
    end

    def file_node(path, depth)
      return root if path.empty?

      stat = File.stat(path)

      hash = {
        :id => path,
        :cls => stat.file? ? 'file' : 'folder',
        :text => File.basename(path),
        :leaf => stat.file?
      }

      unless stat.file?
        hash[:children] = entries_for(path).map do |entry| 
          file_node(File.join(path, entry), depth - 1)
        end
      end

      hash
    end
    
  end

end
