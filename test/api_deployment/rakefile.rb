require 'open-uri'
require 'openssl'
require 'time'
require 'zip'

require_relative '../../build/command'

Zip.setup do |c|
  c.continue_on_exists_proc = true
end

namespace 'api_deployment' do
  load '../../build/tasks.rake'

  module ApiDeploymentTest
    def self.fetch(url)
      puts("Fetching #{url}")
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    end
  end

  task :prepare, [:prefix] do
    Zip::File.open('lambda.zip', Zip::File::CREATE) do |zipfile|
      zipfile.add('lambda.py', 'lambda.py')
    end
  end

  # TODO: test that caching is enabled
  task :validate, [:prefix] do
    api_url = Command.run('terraform output api_url').tr("\r\n", '')

    result = ApiDeploymentTest.fetch(api_url)

    # just do matching on date, as time might be in slighlty different format
    if /\d{4}-\d{2}-\d{2}/.match(result[0..9]).nil?
      raise 'Error while querying the API'
    end
  end
end
