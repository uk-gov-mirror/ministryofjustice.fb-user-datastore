class FileCacheAdapter
  def self.get(key)
    create_cache_dir_if_needed!
    File.read(file_path(key)) rescue nil
  end

  def self.put(key, value)
    create_cache_dir_if_needed!
    File.open(file_path(key), 'w') do |f|
      f << value + "\n"
    end
  end

  private

  def self.create_cache_dir_if_needed!
    FileUtils.mkdir_p(cache_dir) unless Dir.exists?(cache_dir)
  end

  def self.file_path(key)
    File.join(cache_dir, filename(key))
  end

  def self.filename(key)
    [key, 'tmp'].join('.')
  end

  def self.cache_dir
    Rails.root.join('tmp', 'cache')
  end
end
