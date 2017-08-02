require 'open-uri'
require 'openssl'

namespace 'api_method' do
  load '../../scripts/tasks.rake'

  module ApiMethodTest
    def self.fetch(api_url, q)
      url = "#{api_url}?q=#{q}"
      puts("Fetching #{url}")
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    rescue OpenURI::HTTPError => error
      error.io.read
    end

    def self.fetch_no_query_strings(api_url)
      puts("Fetching #{api_url}")
      open(api_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
    rescue OpenURI::HTTPError => error
      { status: error.io.status[0], message: error.io.read }
    else
      {}
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

    def self.fetch_with_content_type(api_url, content_type)
      url = "#{api_url}/passthrough"
      puts("Fetching #{url}")
      open(url,
           'Content-Type' => content_type,
           ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).status[0]
    rescue OpenURI::HTTPError => error
      error.io.status[0]
    end
  end

  task :validate, [:prefix] do
    api_url = TDK::TerraformLogFilter.filter(
      TDK::Command.run('terraform output api_url'))[0]

    result = ApiMethodTest.fetch(api_url, 'existing')
    raise "Error while querying the API (got: #{result})" if result != 'Found'

    result = ApiMethodTest.fetch(api_url, 'nonexisting')
    raise "Error while querying the API (got: #{result})" if result != 'Not found'

    result = ApiMethodTest.fetch_no_query_strings(api_url)
    if result[:status] != '400' ||
       result[:message] !~ /Missing required request parameters: \[q\]/
      raise "Error while querying the API (got: #{result})"
    end

    result = ApiMethodTest.fetch_redirect(api_url)
    if result[:status] != '301' || result[:location] != 'http://www.example.com'
      raise "Error while querying the API (got: #{result})"
    end

    status = ApiMethodTest.fetch_with_content_type(api_url, 'text/plain')
    raise "Expected 415 status code, got #{status}" if status != '415'

    status = ApiMethodTest.fetch_with_content_type(api_url, 'application/json')
    raise "Expected 200 status code, got #{status}" if status != '200'
  end
end
