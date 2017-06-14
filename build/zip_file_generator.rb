require 'zip'

# Adapted from the rubyzip repo for recursively zipping a folder: https://github.com/rubyzip/rubyzip
class ZipFileGenerator
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  def write
    entries = Dir.entries(@input_dir)
    entries.delete('.')
    entries.delete('..')
    Zip::File.open(@output_file, Zip::File::CREATE) do |zipfile|
      write_entries(entries, '', zipfile)
    end
  end

  private

  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zip_file_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zip_file_path)
      if File.directory?(disk_file_path)
        zipfile.mkdir(zip_file_path)
        subdir = Dir.entries(disk_file_path)
        subdir.delete('.')
        subdir.delete('..')
        write_entries(subdir, zip_file_path, zipfile)
      else
        zipfile.get_output_stream(zip_file_path) do |f|
          f.puts(File.open(disk_file_path, 'rb').read)
        end
      end
    end
  end
end
