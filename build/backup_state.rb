require 'fileutils'

require_relative 'zip_file_generator'

module BackupState
  def self.backup(prefix)
    backup_path = ENV['TM_STATE_BACKUP_PATH']
    return if backup_path.nil?

    filename = "#{prefix}failure_state.zip"
    ZipFileGenerator.new('.', filename).write

    FileUtils.cp(filename, backup_path)
    puts "Copied state to #{File.join(backup_path, filename)}"
  end
end
