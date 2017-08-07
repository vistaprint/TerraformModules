require 'aws-sdk'
require 'rspec'
require 'zip'

Zip.setup do |c|
  c.continue_on_exists_proc = true
end

namespace 'lambda' do
  load '../../scripts/tasks.rake'

  module LambdaShould
    extend ::RSpec::Matchers

    def self.return_a_value(api_url)
      response = request("#{api_url}/hello/Steve")
      expect(response.status[0]).to eq('200')
      expect(response.read).to eq('Hello Steve')
    end

    def self.access_environment_variables(api_url)
      response = request("#{api_url}/printvar/foo")
      expect(response.status[0]).to eq('200')
      expect(response.read).to eq('FOO')

      response = request("#{api_url}/printvar/bar")
      expect(response.status[0]).to eq('200')
      expect(response.read).to eq('BAR')
    end

    def self.use_specified_memory_size(function_name)
      expect(memory_size(function_name)).to eq(256)
    end

    def self.request(url)
      TDK.with_retry(10, sleep_time: 5) do
        TDK::Request.new(url).execute(raise_on_codes: ['500'])
      end
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

    LambdaShould.return_a_value(api_url)
    LambdaShould.access_environment_variables(api_url)
    LambdaShould.use_specified_memory_size("#{args.prefix}LambdaTestHello")
  end
end
