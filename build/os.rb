module OS
  def self.host_os
    case RUBY_PLATFORM
    when /linux/
      'linux'
    when /darwin/
      'darwin'
    when /mingw/
      'windows'
    else
      raise 'Cannot determine OS'
    end
  end

  def self.env_path_separator
    case host_os
    when 'linux' || 'darwin'
      ':'
    when 'windows'
      ';'
    end
  end

  def self.join_env_path(path1, path2)
    "#{path1}#{env_path_separator}#{path2}"
  end
end
