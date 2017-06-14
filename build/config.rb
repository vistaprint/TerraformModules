require 'yaml'

class Configuration
  @config = nil

  def self.init(path)
    @config = YAML.safe_load(File.read(path))
  end

  def self.get(key)
    @config[key] unless @config.nil?
  end
end
