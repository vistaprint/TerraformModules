require 'open-uri'
require 'openssl'

require_relative '../../build/command'

namespace 'api_method' do
  load '../../build/tasks.rake'

  module ApiMethodTest
    def self.fetch(api_url, q)
      url = "#{api_url}?q=#{q}"
      puts("Fetching #{url}")
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    rescue OpenURI::HTTPError => error
      error.io.read
    end

    def self.fetch_redirect(api_url)
      url = "#{api_url}/redirect"
      puts("Fetching #{url}")
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, redirect: false)
    rescue OpenURI::HTTPRedirect => error
      { status: error.io.status[0], location: error.uri.to_s }
    else
      {}
    end
  end

  task :validate, [:prefix] do
    api_url = Command.run('terraform output api_url').tr("\r\n", '')

    if ApiMethodTest.fetch(api_url, 'existing') != 'Found'
      raise 'Error while querying the API'
    end

    if ApiMethodTest.fetch(api_url, 'nonexisting') != 'Not found'
      raise 'Error while querying the API'
    end

    result = ApiMethodTest.fetch_redirect(api_url)
    if result[:status] != '301' || result[:location] != 'http://www.example.com'
      raise 'Error while querying the API'
    end
  end
end
