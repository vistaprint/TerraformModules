require 'rspec'

namespace 'api_method' do
  load '../../scripts/tasks.rake'

  module ApiMethodShould
    extend ::RSpec::Matchers

    def self.distinguish_query_string_values(api_url)
      response = request("#{api_url}?q=existing")
      expect(response.status[0]).to eq('200')
      expect(response.read).to eq('Found')

      response = request("#{api_url}?q=nonexisting")
      expect(response.status[0]).to eq('404')
      expect(response.read).to eq('Not found')
    end

    def self.validate_query_string_existance(api_url)
      response = request(api_url)
      expect(response.status[0]).to eq('400')
      expect(response.read).to match(/Missing required request parameters: \[q\]/)
    end

    def self.return_headers(api_url)
      response = request("#{api_url}/redirect")
      expect(response.status[0]).to eq('301')
      expect(response.meta['location']).to eq('http://www.example.com')
    end

    def self.reject_invalid_content_type(api_url)
      response = request(
        "#{api_url}/passthrough",
        headers: { 'Content-Type' => 'text/plain' }
      )
      expect(response.status[0]).to eq('415')

      response = request(
        "#{api_url}/passthrough",
        headers: { 'Content-Type' => 'application/json' }
      )
      expect(response.status[0]).to eq('200')
    end

    def self.request(url, headers: {})
      TDK.with_retry(10, sleep_time: 5) do
        TDK::Request
          .new(url, headers: headers)
          .execute(raise_on_codes: ['500'])
      end
    end
  end

  task :validate, [:prefix] do
    api_url = TDK::TerraformLogFilter.filter(
      TDK::Command.run('terraform output api_url'))[0]

    ApiMethodShould.distinguish_query_string_values(api_url)
    ApiMethodShould.validate_query_string_existance(api_url)
    ApiMethodShould.return_headers(api_url)
    ApiMethodShould.reject_invalid_content_type(api_url)
  end
end
