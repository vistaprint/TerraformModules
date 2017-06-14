require 'open-uri'
require 'openssl'
require 'zip'

require_relative '../../build/command'

Zip.setup do |c|
  c.continue_on_exists_proc = true
end

namespace 'lambda' do
  load '../../build/tasks.rake'

  module LambdaTest
    def self.fetch(api_url, cmd, name)
      url = "#{api_url}/#{cmd}/#{name}"
      puts("Fetching #{url}")
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    end
  end

  task :prepare, [:prefix] do
    Zip::File.open('sample_lambda.zip', Zip::File::CREATE) do |zipfile|
      zipfile.add('package.py', 'package.py')
    end
  end

  task :validate, [:prefix] do
    api_url = Command.run('terraform output api_url').tr("\r\n", '')

    if LambdaTest.fetch(api_url, 'hello', 'Steve') != 'Hello Steve'
      raise 'Error while querying the API'
    end

    if LambdaTest.fetch(api_url, 'goodbye', 'Steve') != 'Goodbye Steve'
      raise 'Error while querying the API'
    end
  end
end
