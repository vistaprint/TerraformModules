require 'open-uri'
require 'openssl'

def download_file(url, filename, force_download: false)
  unless File.exist?(filename) && !force_download
    dirname = File.dirname(filename)
    FileUtils.mkdir_p(dirname) unless Dir.exist?(dirname)

    puts "Downloading #{url} to #{filename}..."

    open(filename, 'wb') do |file|
      file << open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    end
  end
end
