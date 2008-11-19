module Shinmun

  # A simple hashtable, which loads only changed files by calling reload.
  class Cache

    # Call with a block to specify how the data is loaded.
    # This is the default behaviour: Cache.new {|file| File.read(file) }
    def initialize(&block)
      @map = {}
      @callback = block || proc { |file| File.read(file) }
    end

    # Load a file into the cache, transform it according to callback
    # and remember the modification time.
    def real_load(file)
      Shinmun.log.debug("loading #{file}")
      @map[file] = [@callback.call(file), File.mtime(file)]
    end

    def remove(file)
      @map.delete(file)
    end

    def dirty_files
      @map.map { |file, (data, mtime)| mtime != File.mtime(file) ? file : nil }.compact
    end

    def reload!
      @map.keys.each { |file| real_load file }
    end
    
    def reload_dirty!
      dirty_files.each { |file| real_load file }
    end    

    # Access the cache by filename.
    def load(file)
      (@map[file] || real_load(file)).first
    end

    alias [] load

    def values
      @map.values.map { |data, | data }
    end

    # Are there any files loaded?
    def empty?
      @map.empty?
    end

    # Is there any file in this cache, which has changed?
    def dirty?
      dirty_files.size > 0
    end

  end

end
