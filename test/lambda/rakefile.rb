require 'aws-sdk'
require 'open-uri'
require 'openssl'
require 'zip'

Zip.setup do |c|
  c.continue_on_exists_proc = true
end

namespace 'lambda' do
  load '../../scripts/tasks.rake'

  module LambdaTest
    def self.fetch(api_url, cmd, name)
      url = "#{api_url}/#{cmd}/#{name}"
      puts("Fetching #{url}")
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    end

    def self.memory_size(function_name)
      aws_config = TDK::AwsConfig.new(TDK::Configuration.get('aws'))
      client = Aws::Lambda::Client.new(
        region: aws_config.region,
        credentials: aws_config.credentials
      )
      lambda_config = client.get_function_configuration(
        function_name: function_name
      )
      lambda_config.memory_size
    end
  end

  task :prepare, [:prefix] do
    Zip::File.open('sample_lambda.zip', Zip::File::CREATE) do |zipfile|
      zipfile.add('package.py', 'package.py')
    end
  end

  task :validate, [:prefix] do |_, args|
    api_url = TDK::TerraformLogFilter.filter(
      TDK::Command.run('terraform output api_url'))[0]

    if LambdaTest.fetch(api_url, 'hello', 'Steve') != 'Hello Steve'
      raise 'Error while querying the API'
    end

    if LambdaTest.fetch(api_url, 'printvar', 'foo') != 'FOO'
      raise 'Error while querying the API'
    end

    if LambdaTest.fetch(api_url, 'printvar', 'bar') != 'BAR'
      raise 'Error while querying the API'
    end

    size = LambdaTest.memory_size("#{args.prefix}LambdaTestHello")
    raise "Incorrect memory size. Expected 256, got #{size}" if size != 256
  end
end
