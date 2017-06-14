require 'zip'

require_relative 'download'
require_relative 'os'
require_relative 'command'

module TerraformInstaller
  LOCAL_FILE_NAME = 'terraform.zip'.freeze

  def self.installed_terraform_version
    version = Command.run('terraform --version').tr("\r\n", '')
    match = /Terraform v(\d+\.\d+\.\d+)/.match(version)
    match[1] unless match.nil?
  rescue
    nil
  end

  def self.download_terraform(version)
    download_file(
      "https://releases.hashicorp.com/terraform/#{version}/terraform_#{version}_#{OS.host_os}_amd64.zip",
      LOCAL_FILE_NAME,
      force_download: true
    )
  end

  def self.unzip_terraform
    Zip::File.open(LOCAL_FILE_NAME) do |zip_file|
      zip_file.each do |entry|
        puts "Extracting #{entry.name}"
        entry.restore_permissions = true
        entry.extract { true }
      end
    end
  end

  def self.install_local(version)
    if installed_terraform_version == version
      puts 'Terraform already installed'
      return
    end

    download_terraform(version)
    unzip_terraform
  end
end
