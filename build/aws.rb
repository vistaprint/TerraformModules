require 'aws-sdk'

Aws.use_bundled_cert!

class AwsConfig
  def initialize(config)
    unless config.nil?
      @profile = config.fetch('profile', nil)
      @region = config.fetch('region', nil)
      @access_key_id = config.fetch('access_key_id', nil)
      @secret_access_key = config.fetch('secret_access_key', nil)
    end
  end

  def credentials
    unless profile.nil?
      credentials = Aws::SharedCredentials.new(profile_name: profile)
      return credentials if credentials.set?
    end

    return Aws::Credentials.new(*access_keys) if access_keys_available?

    raise 'Cannot find AWS credentials'
  end

  def region
    @region || ENV['AWS_REGION']
  end

  def profile
    @profile || ENV['AWS_PROFILE']
  end

  private

  def access_keys
    return config_access_keys if config_has_access_keys?
    return environment_access_keys if environment_has_access_keys?
    nil
  end

  def access_keys_available?
    config_has_access_keys? || environment_has_access_keys?
  end

  def config_has_access_keys?
    !@access_key_id.nil? && !@secret_access_key.nil?
  end

  def config_access_keys
    return @access_key_id, @secret_access_key
  end

  def environment_has_access_keys?
    ENV.key?('AWS_ACCESS_KEY_ID') && ENV.key?('AWS_SECRET_ACCESS_KEY')
  end

  def environment_access_keys
    return ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']
  end
end
