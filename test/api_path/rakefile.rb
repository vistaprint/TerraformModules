require 'open-uri'
require 'openssl'
require 'zip'

Zip.setup do |c|
  c.continue_on_exists_proc = true
end

namespace 'api_path' do
  load '../../scripts/tasks.rake'

  module ApiPathTest
    def self.fetch(api_url, name)
      url = "#{api_url}/hello/#{name}"
      puts("Fetching #{url}")
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    end
  end

  task :prepare, [:prefix] do
    Zip::File.open('sample_lambda.zip', Zip::File::CREATE) do |zipfile|
      zipfile.add('hello.py', 'hello.py')
    end
  end

  task :validate, [:prefix] do
    api_url = TDK::Command.run('terraform output api_url')[0]
    if ApiPathTest.fetch(api_url, 'Steve') != 'Hello Steve'
      raise 'Error while querying the API'
    end
  end
end
