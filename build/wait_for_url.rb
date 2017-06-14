require 'open-uri'
require 'openssl'

# Interval between retries (in seconds)
INTERVAL_LENGTH = 5.0

# Maximum amount of time to keep retrying (in seconds)
MAX_TIME_TO_RETRY = 300.0

if ARGV.length != 1
  puts 'USAGE: wait_for_url.rb <url>'
  exit
end

url = ARGV[0]
retries = (MAX_TIME_TO_RETRY / INTERVAL_LENGTH).ceil

begin
  puts "Fetching #{url}"
  open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, redirect: false)
rescue OpenURI::HTTPError => error
  response = error.io
  puts "Response status code: #{response.status[0]}"
  unless (retries -= 1).zero? || response.status[0] != '500'
    sleep(INTERVAL_LENGTH)
    retry
  end
rescue OpenURI::HTTPRedirect => error
  puts "Redirect to: #{error.uri}"
end
