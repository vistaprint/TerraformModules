require_relative '../build/aws'

describe AwsConfig do
  PROFILE_NAME = 'profile'.freeze
  ANOTHER_PROFILE_NAME = 'another_profile'.freeze

  REGION = 'region'.freeze
  ANOTHER_REGION = 'another_region'.freeze

  SECRET_KEY = 'secret_key'.freeze
  ACCESS_KEY = 'access_key'.freeze
  SHARED_SECRET_KEY = 'shared_secret_key'.freeze
  SHARED_ACCESS_KEY = 'shared_access_key'.freeze

  let(:aws_config) { AwsConfig.new(@config) }

  before(:example) do
    @config = {}

    ENV.delete('AWS_PROFILE')
    ENV.delete('AWS_REGION')
  end

  describe '#profile' do
    it 'returns nil if profile name is not provided' do
      expect(aws_config.profile).to be_nil
    end

    it 'returns profile name from configuration if it exists' do
      given_profile_name_in_configuration(PROFILE_NAME)
      given_profile_name_in_env_vars(ANOTHER_PROFILE_NAME)
      expect(aws_config.profile).to eq(PROFILE_NAME)
    end

    it 'falls back to env vars if profile name not in configuration' do
      given_profile_name_in_env_vars
      expect(aws_config.profile).to eq(PROFILE_NAME)
    end
  end

  describe '#region' do
    it 'returns nil if region is not provided' do
      expect(aws_config.region).to be_nil
    end

    it 'returns region from configuration if it exists' do
      given_region_in_configuration(REGION)
      given_region_in_env_vars(ANOTHER_REGION)
      expect(aws_config.region).to eq(REGION)
    end

    it 'falls back to env vars if region name not in configuration' do
      given_region_in_env_vars
      expect(aws_config.region).to eq(REGION)
    end
  end

  describe '#credentials' do
    it 'returns shared credentials if found' do
      given_valid_profile_and_access_keys
      given_valid_shared_credentials
      credentials = aws_config.credentials
      expect(credentials.credentials.access_key_id)
        .to eq(SHARED_ACCESS_KEY)
      expect(credentials.credentials.secret_access_key)
        .to eq(SHARED_SECRET_KEY)
    end

    it 'falls back to access keys if profile is not defined' do
      # If profile_name is nil Aws::SharedCredentials uses the default profile.
      # AwsConfig does not automatically use the default profile if the
      # profile name is nil. Either a profile name is provided or AwsConfig
      # will not attempt to look for shared credentials.
      given_valid_access_keys
      given_valid_shared_credentials
      credentials = aws_config.credentials
      expect(credentials.access_key_id)
        .to eq(ACCESS_KEY)
      expect(credentials.secret_access_key)
        .to eq(SECRET_KEY)
    end

    it 'throws an exception if no credentials are found' do
      expect { aws_config.credentials }
        .to raise_error('Cannot find AWS credentials')
    end
  end

  def given_profile_name_in_configuration(profile = PROFILE_NAME)
    @config = { 'profile' => profile }
  end

  def given_profile_name_in_env_vars(profile = PROFILE_NAME)
    ENV['AWS_PROFILE'] = profile
  end

  def given_region_in_configuration(region = REGION)
    @config = { 'region' => region }
  end

  def given_region_in_env_vars(region = REGION)
    ENV['AWS_REGION'] = region
  end

  def given_valid_access_keys
    @config = {
      'access_key_id' => ACCESS_KEY,
      'secret_access_key' => SECRET_KEY
    }
  end

  def given_valid_profile_and_access_keys
    @config = {
      'access_key_id' => ACCESS_KEY,
      'secret_access_key' => SECRET_KEY,
      'profile' => PROFILE_NAME
    }
  end

  def given_valid_shared_credentials
    shared_credentials = instance_double(Aws::SharedCredentials)
    allow(shared_credentials)
      .to receive(:set?)
      .and_return(true)
    allow(shared_credentials)
      .to receive(:credentials)
      .and_return(Aws::Credentials.new(SHARED_ACCESS_KEY, SHARED_SECRET_KEY))

    allow(Aws::SharedCredentials)
      .to receive(:new).with(profile_name: PROFILE_NAME)
      .and_return(shared_credentials)
  end
end
